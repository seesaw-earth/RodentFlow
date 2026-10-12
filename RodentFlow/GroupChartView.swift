import SwiftUI
import Charts

/// Publication-style group figure: individual animals are always shown.
struct GroupChartView: View {
    let result: GroupAnalysisResult
    let colorFor: (String) -> Color
    var style: GroupChartStyle = .barDots
    var showNonSignificant = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch result.request.design {
            case .betweenGroups, .phaseChange:
                IndependentGroupsChart(result: result, colorFor: colorFor, style: style, showNonSignificant: showNonSignificant)
            case .byDay, .withinSession:
                CurveChart(result: result, colorFor: colorFor)
            case .pairedMeasures:
                PairedMeasuresChart(result: result, colorFor: colorFor)
            }
            GroupLegend(result: result, colorFor: colorFor)
        }
    }
}

struct GroupLegend: View {
    let result: GroupAnalysisResult
    let colorFor: (String) -> Color

    private func count(_ group: String) -> Int {
        switch result.request.design {
        case .betweenGroups, .phaseChange: return result.points.filter { $0.group == group }.count
        case .byDay, .withinSession: return result.subjectSeries.filter { $0.group == group }.count
        case .pairedMeasures: return result.paired.filter { $0.group == group }.count
        }
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) { items }
            VStack(alignment: .leading, spacing: 4) { items }
        }
        .font(.system(size: 11.5))
    }

    @ViewBuilder
    private var items: some View {
        ForEach(result.groups, id: \.self) { g in
            HStack(spacing: 5) {
                Circle().fill(colorFor(g)).frame(width: 9, height: 9)
                Text("\(g) (n = \(count(g)))")
            }
        }
    }
}

// MARK: - One value per animal

struct IndependentGroupsChart: View {
    let result: GroupAnalysisResult
    let colorFor: (String) -> Color
    let style: GroupChartStyle
    let showNonSignificant: Bool

    struct Dot: Identifiable {
        let id: String
        let x: Double
        let y: Double
        let group: String
    }

    struct Summary: Identifiable {
        let id: Int
        let x: Double
        let group: String
        let d: Descriptives
        let lowWhisker: Double
        let highWhisker: Double
    }

    struct Bracket: Identifiable {
        let id: Int
        let x1: Double
        let x2: Double
        let y: Double
        let tick: Double
        let label: String
    }

    private var groups: [String] { result.groups }
    private var yLabel: String { result.axisTitle }

    private var dots: [Dot] {
        var out: [Dot] = []
        let offsets: [Double] = [0, -0.09, 0.09, -0.18, 0.18, -0.045, 0.045, -0.135, 0.135, -0.225, 0.225]
        for (gi, g) in groups.enumerated() {
            let values = result.points.filter { $0.group == g }.sorted { $0.value < $1.value }
            let span = max(1e-9, (values.last?.value ?? 0) - (values.first?.value ?? 0))
            var lastY = -Double.infinity
            var cluster = 0
            for p in values {
                // Spread points that are close in value; keep isolated points centered.
                if (p.value - lastY) / span < 0.04 { cluster += 1 } else { cluster = 0 }
                lastY = p.value
                out.append(Dot(id: p.id, x: Double(gi) + offsets[cluster % offsets.count], y: p.value, group: g))
            }
        }
        return out
    }

    private var summaries: [Summary] {
        var out: [Summary] = []
        for (gi, g) in groups.enumerated() {
            guard let d = result.descriptives[g], d.n > 0 else { continue }
            let values = result.points.filter { $0.group == g }.map(\.value)
            let iqr = d.q3 - d.q1
            let low = values.filter { $0 >= d.q1 - 1.5 * iqr }.min() ?? d.min
            let high = values.filter { $0 <= d.q3 + 1.5 * iqr }.max() ?? d.max
            out.append(Summary(id: gi, x: Double(gi), group: g, d: d, lowWhisker: low, highWhisker: high))
        }
        return out
    }

    private var dataExtent: (Double, Double) {
        var values = result.points.map(\.value)
        for s in summaries {
            values.append(s.d.mean + s.d.sem)
            values.append(s.d.mean - s.d.sem)
        }
        if style == .barDots { values.append(0) }
        if let chance = result.chance, result.request.testAgainstChance { values.append(chance) }
        let lo = values.min() ?? 0
        let hi = values.max() ?? 1
        return (lo, hi == lo ? lo + 1 : hi)
    }

    private var brackets: [Bracket] {
        let (lo, hi) = dataExtent
        let span = hi - lo
        let comparisons = result.report.pairwise
            .filter { $0.level == nil && (showNonSignificant || $0.pAdjusted < 0.05) }
            .compactMap { c -> (Int, Int, String)? in
                guard let a = groups.firstIndex(of: c.groupA), let b = groups.firstIndex(of: c.groupB) else { return nil }
                return (min(a, b), max(a, b), StatsFormat.stars(c.pAdjusted))
            }
            .sorted { ($0.1 - $0.0) < ($1.1 - $1.0) }
        var out: [Bracket] = []
        for (k, c) in comparisons.enumerated() {
            let y = hi + span * (0.10 + 0.11 * Double(k))
            out.append(Bracket(id: k, x1: Double(c.0), x2: Double(c.1), y: y, tick: span * 0.03, label: c.2))
        }
        return out
    }

    private var yDomain: ClosedRange<Double> {
        let (lo, hi) = dataExtent
        let span = hi - lo
        let top = (brackets.map(\.y).max() ?? hi) + span * 0.10
        let bottom = style == .barDots && lo >= 0 ? 0 : lo - span * 0.06
        return bottom...max(top, bottom + 1e-6)
    }

    private func axisLabel(_ value: AxisValue) -> String {
        guard let v = value.as(Double.self) else { return "" }
        let i = Int(v.rounded())
        return groups.indices.contains(i) ? groups[i] : ""
    }

    var body: some View {
        Chart {
            ForEach(summaries) { s in
                if style == .barDots {
                    RectangleMark(xStart: .value("Group", s.x - 0.32), xEnd: .value("Group", s.x + 0.32),
                                  yStart: .value(yLabel, 0.0), yEnd: .value(yLabel, s.d.mean))
                        .foregroundStyle(colorFor(s.group).opacity(0.28))
                    RuleMark(x: .value("Group", s.x), yStart: .value(yLabel, s.d.mean - s.d.sem), yEnd: .value(yLabel, s.d.mean + s.d.sem))
                        .foregroundStyle(colorFor(s.group))
                        .lineStyle(StrokeStyle(lineWidth: 1.6))
                    RuleMark(xStart: .value("Group", s.x - 0.1), xEnd: .value("Group", s.x + 0.1), y: .value(yLabel, s.d.mean + s.d.sem))
                        .foregroundStyle(colorFor(s.group))
                        .lineStyle(StrokeStyle(lineWidth: 1.6))
                } else if style == .boxDots {
                    RectangleMark(xStart: .value("Group", s.x - 0.28), xEnd: .value("Group", s.x + 0.28),
                                  yStart: .value(yLabel, s.d.q1), yEnd: .value(yLabel, s.d.q3))
                        .foregroundStyle(colorFor(s.group).opacity(0.22))
                    RuleMark(xStart: .value("Group", s.x - 0.28), xEnd: .value("Group", s.x + 0.28), y: .value(yLabel, s.d.median))
                        .foregroundStyle(colorFor(s.group))
                        .lineStyle(StrokeStyle(lineWidth: 2.2))
                    RuleMark(x: .value("Group", s.x), yStart: .value(yLabel, s.lowWhisker), yEnd: .value(yLabel, s.d.q1))
                        .foregroundStyle(colorFor(s.group))
                    RuleMark(x: .value("Group", s.x), yStart: .value(yLabel, s.d.q3), yEnd: .value(yLabel, s.highWhisker))
                        .foregroundStyle(colorFor(s.group))
                } else {
                    RuleMark(xStart: .value("Group", s.x - 0.26), xEnd: .value("Group", s.x + 0.26), y: .value(yLabel, s.d.mean))
                        .foregroundStyle(colorFor(s.group))
                        .lineStyle(StrokeStyle(lineWidth: 2.4))
                    RuleMark(x: .value("Group", s.x), yStart: .value(yLabel, s.d.mean - s.d.sem), yEnd: .value(yLabel, s.d.mean + s.d.sem))
                        .foregroundStyle(colorFor(s.group))
                        .lineStyle(StrokeStyle(lineWidth: 1.6))
                }
            }

            ForEach(dots) { d in
                PointMark(x: .value("Group", d.x), y: .value(yLabel, d.y))
                    .foregroundStyle(colorFor(d.group))
                    .symbolSize(32)
            }

            if let chance = result.chance, result.request.testAgainstChance {
                RuleMark(y: .value(yLabel, chance))
                    .foregroundStyle(Color.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
            }

            ForEach(brackets) { b in
                RuleMark(xStart: .value("Group", b.x1), xEnd: .value("Group", b.x2), y: .value(yLabel, b.y))
                    .foregroundStyle(Color.primary)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .annotation(position: .top, spacing: 0) {
                        Text(b.label).font(.system(size: 11, weight: .semibold))
                    }
                RuleMark(x: .value("Group", b.x1), yStart: .value(yLabel, b.y - b.tick), yEnd: .value(yLabel, b.y))
                    .foregroundStyle(Color.primary)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                RuleMark(x: .value("Group", b.x2), yStart: .value(yLabel, b.y - b.tick), yEnd: .value(yLabel, b.y))
                    .foregroundStyle(Color.primary)
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }
        }
        .chartXScale(domain: -0.6...(Double(max(1, groups.count)) - 0.4))
        .chartYScale(domain: yDomain)
        .chartXAxis {
            AxisMarks(values: groups.indices.map { Double($0) }) { value in
                AxisValueLabel {
                    Text(axisLabel(value))
                }
            }
        }
        .chartYAxisLabel(yLabel)
    }
}

// MARK: - Learning curves / time courses

struct CurveChart: View {
    let result: GroupAnalysisResult
    let colorFor: (String) -> Color

    struct CurvePlotPoint: Identifiable {
        let id: String
        let group: String
        let x: Double
        let mean: Double
        let low: Double
        let high: Double
    }

    struct StarMark: Identifiable {
        let id: Int
        let x: Double
        let y: Double
        let label: String
    }

    private var dodge: Double {
        let levels = result.levels
        guard levels.count >= 2 else { return 0.05 }
        var minGap = Double.infinity
        for i in 1..<levels.count { minGap = min(minGap, levels[i] - levels[i - 1]) }
        return minGap.isFinite ? minGap * 0.06 : 0.05
    }

    private var points: [CurvePlotPoint] {
        let k = Double(result.groups.count)
        let d = dodge
        var out: [CurvePlotPoint] = []
        for c in result.curves {
            guard let gi = result.groups.firstIndex(of: c.group) else { continue }
            let offset = (Double(gi) - (k - 1) / 2) * d
            out.append(CurvePlotPoint(id: c.id, group: c.group, x: c.level + offset, mean: c.mean, low: c.mean - c.sem, high: c.mean + c.sem))
        }
        return out
    }

    private var stars: [StarMark] {
        var out: [StarMark] = []
        let all = points
        let span = max(1e-9, (all.map(\.high).max() ?? 1) - (all.map(\.low).min() ?? 0))
        for (j, level) in result.levels.enumerated() {
            let name = GroupAnalysisEngine.levelName(level, label: result.levelLabel)
            let sig = result.report.pairwise.filter { $0.level == name && $0.pAdjusted < 0.05 }
            guard let best = sig.map(\.pAdjusted).min() else { continue }
            let top = result.curves.filter { $0.level == level }.map { $0.mean + $0.sem }.max() ?? 0
            out.append(StarMark(id: j, x: level, y: top + span * 0.05, label: StatsFormat.stars(best)))
        }
        return out
    }

    var body: some View {
        Chart {
            ForEach(points) { p in
                LineMark(x: .value(result.levelLabel, p.x), y: .value(result.axisTitle, p.mean), series: .value("Group", p.group))
                    .foregroundStyle(colorFor(p.group))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                PointMark(x: .value(result.levelLabel, p.x), y: .value(result.axisTitle, p.mean))
                    .foregroundStyle(colorFor(p.group))
                    .symbolSize(40)
                RuleMark(x: .value(result.levelLabel, p.x), yStart: .value(result.axisTitle, p.low), yEnd: .value(result.axisTitle, p.high))
                    .foregroundStyle(colorFor(p.group))
                    .lineStyle(StrokeStyle(lineWidth: 1.4))
            }
            ForEach(stars) { s in
                PointMark(x: .value(result.levelLabel, s.x), y: .value(result.axisTitle, s.y))
                    .opacity(0)
                    .annotation(position: .top, spacing: 0) {
                        Text(s.label).font(.system(size: 11, weight: .semibold))
                    }
            }
        }
        .chartXAxisLabel(result.levelLabel)
        .chartYAxisLabel(result.axisTitle)
        .chartXAxis {
            AxisMarks(values: result.levels) { value in
                AxisGridLine()
                AxisValueLabel {
                    Text(value.as(Double.self).map { SeriesChartView.label($0) } ?? "")
                }
            }
        }
    }
}

// MARK: - Paired measures (e.g. novel vs familiar)

struct PairedMeasuresChart: View {
    let result: GroupAnalysisResult
    let colorFor: (String) -> Color

    struct LinePoint: Identifiable {
        let id: String
        let x: Double
        let y: Double
        let series: String
        let group: String
    }

    struct MeanMark: Identifiable {
        let id: String
        let x: Double
        let y: Double
        let group: String
    }

    struct Bracket: Identifiable {
        let id: String
        let x1: Double
        let x2: Double
        let y: Double
        let label: String
    }

    private func position(_ groupIndex: Int, second: Bool) -> Double { Double(groupIndex) * 3 + (second ? 1 : 0) }

    private var linePoints: [LinePoint] {
        var out: [LinePoint] = []
        for p in result.paired {
            guard let gi = result.groups.firstIndex(of: p.group) else { continue }
            out.append(LinePoint(id: p.id + "|a", x: position(gi, second: false), y: p.a, series: p.id, group: p.group))
            out.append(LinePoint(id: p.id + "|b", x: position(gi, second: true), y: p.b, series: p.id, group: p.group))
        }
        return out
    }

    private var means: [MeanMark] {
        var out: [MeanMark] = []
        for (gi, g) in result.groups.enumerated() {
            let pts = result.paired.filter { $0.group == g }
            guard !pts.isEmpty else { continue }
            out.append(MeanMark(id: g + "a", x: position(gi, second: false), y: Stats.mean(pts.map(\.a)), group: g))
            out.append(MeanMark(id: g + "b", x: position(gi, second: true), y: Stats.mean(pts.map(\.b)), group: g))
        }
        return out
    }

    private var brackets: [Bracket] {
        let values = result.paired.flatMap { [$0.a, $0.b] }
        let hi = values.max() ?? 1
        let span = max(1e-9, hi - (values.min() ?? 0))
        var out: [Bracket] = []
        for (gi, g) in result.groups.enumerated() {
            guard let test = result.report.perGroup[g] else { continue }
            out.append(Bracket(id: g, x1: position(gi, second: false), x2: position(gi, second: true), y: hi + span * 0.1, label: StatsFormat.stars(test.p)))
        }
        return out
    }

    private var axisPositions: [Double] {
        result.groups.indices.flatMap { [position($0, second: false), position($0, second: true)] }
    }

    private func axisLabel(_ value: AxisValue) -> String {
        guard let v = value.as(Double.self) else { return "" }
        let i = Int(v.rounded())
        return i % 3 == 0 ? result.pairLabelA : result.pairLabelB
    }

    var body: some View {
        Chart {
            ForEach(linePoints) { p in
                LineMark(x: .value("Measure", p.x), y: .value(result.axisTitle, p.y), series: .value("Animal", p.series))
                    .foregroundStyle(colorFor(p.group).opacity(0.45))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                PointMark(x: .value("Measure", p.x), y: .value(result.axisTitle, p.y))
                    .foregroundStyle(colorFor(p.group))
                    .symbolSize(26)
            }
            ForEach(means) { m in
                RuleMark(xStart: .value("Measure", m.x - 0.28), xEnd: .value("Measure", m.x + 0.28), y: .value(result.axisTitle, m.y))
                    .foregroundStyle(colorFor(m.group))
                    .lineStyle(StrokeStyle(lineWidth: 2.6))
            }
            ForEach(brackets) { b in
                RuleMark(xStart: .value("Measure", b.x1), xEnd: .value("Measure", b.x2), y: .value(result.axisTitle, b.y))
                    .foregroundStyle(Color.primary)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .annotation(position: .top, spacing: 0) {
                        Text(b.label).font(.system(size: 11, weight: .semibold))
                    }
            }
        }
        .chartXScale(domain: -0.6...(Double(max(1, result.groups.count)) * 3 - 1.4))
        .chartXAxis {
            AxisMarks(values: axisPositions) { value in
                AxisValueLabel {
                    Text(axisLabel(value))
                }
            }
        }
        .chartYAxisLabel(result.axisTitle)
    }
}

// MARK: - Export figure

/// Self-contained figure (title, chart, legend, test summary) rendered to PNG.
struct GroupFigureView: View {
    let result: GroupAnalysisResult
    let colorFor: (String) -> Color
    let style: GroupChartStyle
    let showNonSignificant: Bool

    private var mainTest: String {
        if let o = result.report.omnibus { return "\(o.name): \(o.reportLine)" }
        if let m = result.report.mixed {
            var parts: [String] = []
            if let g = m.group { parts.append(loc("group") + " " + g.reportLine) }
            parts.append((result.levelLabel.isEmpty ? loc("within") : result.levelLabel.lowercased()) + " " + m.level.reportLine)
            if let i = m.interaction { parts.append(loc("interaction") + " " + i.reportLine) }
            return parts.joined(separator: "; ")
        }
        return ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(result.request.assay.displayName) · \(result.metricName)")
                .font(.system(size: 13, weight: .semibold))
            if let phase = result.request.phaseFilter, result.request.design != .phaseChange {
                Text(AssayKind.phaseTitle(phase)).font(.system(size: 11)).foregroundStyle(.secondary)
            }
            GroupChartView(result: result, colorFor: colorFor, style: style, showNonSignificant: showNonSignificant)
            if !mainTest.isEmpty {
                Text(mainTest)
                    .font(.system(size: 9.5))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text("Points = individual animals; error bars = SEM. * p < 0.05, ** p < 0.01, *** p < 0.001, **** p < 0.0001.")
                .font(.system(size: 8.5))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.white)
    }
}
