import SwiftUI
import Charts

// MARK: - Arena plot (trajectory / heatmap + zones)

enum ArenaPlotMode: String, CaseIterable, Identifiable {
    case trajectory = "Path"
    case heatmap = "Heatmap"
    var id: String { rawValue }
}

struct ArenaMarker: Identifiable, Hashable {
    var id: String
    var label: String
    var point: ArenaPoint
}

struct ArenaPlotView: View {
    let samples: [AnalysisSample]
    let config: ZoneConfig
    let overlays: [ZoneOverlay]
    var mode: ArenaPlotMode = .trajectory
    var markers: [ArenaMarker] = []
    var onMoveMarker: ((String, ArenaPoint) -> Void)?

    private struct Frame {
        var origin: CGPoint
        var scale: CGFloat
    }

    private var arenaWidth: Double { max(1, config.arenaWidthCM) }
    private var arenaHeight: Double { max(1, config.arenaShape == .circle ? config.arenaWidthCM : config.arenaHeightCM) }

    var body: some View {
        GeometryReader { geo in
            let frame = makeFrame(geo.size)
            ZStack {
                Canvas { context, _ in
                    drawArena(&context, frame)
                    drawOverlays(&context, frame)
                    if mode == .trajectory {
                        drawTrajectory(&context, frame)
                    } else {
                        drawHeatmap(&context, frame)
                    }
                    drawOverlayLabels(&context, frame)
                }
                ForEach(markers) { marker in
                    markerHandle(marker.label)
                        .position(viewPoint(marker.point.x, marker.point.y, frame))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    onMoveMarker?(marker.id, arenaPoint(value.location, frame))
                                }
                        )
                }
            }
        }
        .aspectRatio(CGFloat(arenaWidth / arenaHeight), contentMode: .fit)
        .frame(maxHeight: 340)
    }

    private func makeFrame(_ size: CGSize) -> Frame {
        let pad: CGFloat = 12
        let s = min((size.width - 2 * pad) / CGFloat(arenaWidth), (size.height - 2 * pad) / CGFloat(arenaHeight))
        let scale = max(0.01, s)
        let origin = CGPoint(x: (size.width - CGFloat(arenaWidth) * scale) / 2, y: (size.height - CGFloat(arenaHeight) * scale) / 2)
        return Frame(origin: origin, scale: scale)
    }

    private func viewPoint(_ x: Double, _ y: Double, _ f: Frame) -> CGPoint {
        CGPoint(x: f.origin.x + CGFloat(x) * f.scale, y: f.origin.y + CGFloat(y) * f.scale)
    }

    private func viewRect(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ f: Frame) -> CGRect {
        CGRect(x: f.origin.x + CGFloat(x) * f.scale, y: f.origin.y + CGFloat(y) * f.scale,
               width: CGFloat(w) * f.scale, height: CGFloat(h) * f.scale)
    }

    private func arenaPoint(_ p: CGPoint, _ f: Frame) -> ArenaPoint {
        let x = Double((p.x - f.origin.x) / f.scale)
        let y = Double((p.y - f.origin.y) / f.scale)
        return ArenaPoint(x: min(max(0, x), arenaWidth), y: min(max(0, y), arenaHeight))
    }

    private func drawArena(_ context: inout GraphicsContext, _ f: Frame) {
        let rect = viewRect(0, 0, arenaWidth, arenaHeight, f)
        let path: Path
        switch config.arenaShape {
        case .circle:
            path = Path(ellipseIn: rect)
        case .rectangle:
            path = Path(rect)
        default:
            path = Path(roundedRect: rect, cornerRadius: 4)
        }
        if config.arenaShape == .rectangle || config.arenaShape == .circle {
            context.fill(path, with: .color(Color(uiColor: .tertiarySystemGroupedBackground)))
            context.stroke(path, with: .color(.secondary.opacity(0.6)), lineWidth: 1.2)
        } else {
            context.stroke(path, with: .color(.secondary.opacity(0.35)), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
    }

    private func roleColor(_ role: ZoneOverlay.Role) -> Color {
        switch role {
        case .center: return .blue
        case .target: return .green
        case .novel: return .orange
        case .familiar: return .gray
        case .paired: return .purple
        case .neutral: return .gray
        case .dark: return .black
        case .open: return .yellow
        case .closed: return .gray
        case .hole: return .gray
        case .divider: return .secondary
        case .wall: return .teal
        }
    }

    private func drawOverlays(_ context: inout GraphicsContext, _ f: Frame) {
        for o in overlays {
            let color = roleColor(o.role)
            switch o.shape {
            case .rect(let x, let y, let w, let h):
                let path = Path(viewRect(x, y, w, h, f))
                let fillOpacity = o.role == .dark ? 0.22 : (o.role == .open ? 0.22 : 0.13)
                context.fill(path, with: .color(color.opacity(fillOpacity)))
                context.stroke(path, with: .color(color.opacity(0.7)), lineWidth: 1)
            case .circle(let cx, let cy, let r):
                let path = Path(ellipseIn: viewRect(cx - r, cy - r, 2 * r, 2 * r, f))
                if o.role == .wall {
                    context.stroke(path, with: .color(color.opacity(0.6)), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                } else if o.role == .hole {
                    context.stroke(path, with: .color(color.opacity(0.7)), lineWidth: 1)
                } else {
                    context.fill(path, with: .color(color.opacity(0.22)))
                    context.stroke(path, with: .color(color), lineWidth: 1.4)
                }
            case .line(let x1, let y1, let x2, let y2):
                var path = Path()
                path.move(to: viewPoint(x1, y1, f))
                path.addLine(to: viewPoint(x2, y2, f))
                context.stroke(path, with: .color(color.opacity(0.7)), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
            }
        }
    }

    private func drawOverlayLabels(_ context: inout GraphicsContext, _ f: Frame) {
        for o in overlays where !o.label.isEmpty {
            let anchor: CGPoint
            switch o.shape {
            case .rect(let x, let y, let w, let h): anchor = viewPoint(x + w / 2, y + h / 2, f)
            case .circle(let cx, let cy, let r): anchor = viewPoint(cx, cy - r - 2.5, f)
            case .line(let x1, let y1, _, _): anchor = viewPoint(x1, y1, f)
            }
            context.draw(Text(o.label).font(.system(size: 9.5, weight: .semibold)).foregroundColor(.primary.opacity(0.75)), at: anchor)
        }
    }

    private func drawTrajectory(_ context: inout GraphicsContext, _ f: Frame) {
        guard samples.count > 1 else { return }
        let stride = max(1, samples.count / 4000)
        var path = Path()
        var penDown = false
        var i = 0
        while i < samples.count {
            let s = samples[i]
            if s.detected {
                let p = viewPoint(s.x, s.y, f)
                if penDown { path.addLine(to: p) } else { path.move(to: p); penDown = true }
            } else {
                penDown = false
            }
            i += stride
        }
        context.stroke(path, with: .color(.orange.opacity(0.78)), style: StrokeStyle(lineWidth: 1.1, lineCap: .round, lineJoin: .round))
        if let first = samples.first(where: { $0.detected }) {
            let p = viewPoint(first.x, first.y, f)
            context.fill(Path(ellipseIn: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8)), with: .color(.green))
        }
        if let last = samples.last(where: { $0.detected }) {
            let p = viewPoint(last.x, last.y, f)
            context.fill(Path(ellipseIn: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8)), with: .color(.red))
        }
    }

    private func drawHeatmap(_ context: inout GraphicsContext, _ f: Frame) {
        let columns = 32
        let rows = max(4, Int((Double(columns) * arenaHeight / arenaWidth).rounded()))
        var counts = [Double](repeating: 0, count: columns * rows)
        for s in samples where s.detected {
            let c = min(columns - 1, max(0, Int(s.x / arenaWidth * Double(columns))))
            let r = min(rows - 1, max(0, Int(s.y / arenaHeight * Double(rows))))
            counts[r * columns + c] += 1
        }
        guard let maxCount = counts.max(), maxCount > 0 else { return }
        let cw = arenaWidth / Double(columns)
        let ch = arenaHeight / Double(rows)
        for r in 0..<rows {
            for c in 0..<columns {
                let v = counts[r * columns + c]
                guard v > 0 else { continue }
                // Square-root scaling keeps short visits visible next to long dwell spots.
                let t = (v / maxCount).squareRoot()
                let rect = viewRect(Double(c) * cw, Double(r) * ch, cw + 0.05, ch + 0.05, f)
                context.fill(Path(rect), with: .color(HeatPalette.color(t).opacity(0.25 + 0.75 * t)))
            }
        }
    }

    private func markerHandle(_ label: String) -> some View {
        ZStack {
            Circle().fill(.black.opacity(0.7)).frame(width: 26, height: 26)
            Circle().stroke(.yellow, lineWidth: 2.5).frame(width: 22, height: 22)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

enum HeatPalette {
    /// Viridis-like ramp.
    private static let stops: [(Double, Double, Double)] = [
        (0.267, 0.005, 0.329), (0.231, 0.322, 0.546), (0.128, 0.567, 0.551), (0.369, 0.789, 0.383), (0.993, 0.906, 0.144)
    ]

    static func color(_ t: Double) -> Color {
        let x = min(1, max(0, t)) * Double(stops.count - 1)
        let i = min(stops.count - 2, Int(x))
        let f = x - Double(i)
        let a = stops[i], b = stops[i + 1]
        return Color(red: a.0 + (b.0 - a.0) * f, green: a.1 + (b.1 - a.1) * f, blue: a.2 + (b.2 - a.2) * f)
    }
}

// MARK: - Series (time bins, CS, days, reversals)

struct SeriesChartView: View {
    let series: ResultSeries

    private struct Point: Identifiable {
        let id: Int
        let x: Double
        let y: Double
        let label: String
    }

    private var points: [Point] {
        zip(series.x, series.y).enumerated().map { index, pair in
            Point(id: index, x: pair.0, y: pair.1, label: Self.label(pair.0))
        }
    }

    private var useBars: Bool { series.key.hasSuffix("by_bin") || series.key.hasSuffix("by_cs") }

    static func label(_ x: Double) -> String {
        abs(x - x.rounded()) < 1e-9 ? String(format: "%.0f", x) : String(format: "%.1f", x)
    }

    var body: some View {
        // Series names are stored in English and translated for display.
        let name = loc(series.name)
        let xLabel = loc(series.xLabel)
        VStack(alignment: .leading, spacing: 6) {
            Text(series.unit.isEmpty ? name : "\(name) (\(series.unit))")
                .appFont(14, weight: .semibold)
            if useBars {
                Chart(points) { p in
                    BarMark(x: .value(xLabel, p.label), y: .value(name, p.y))
                        .foregroundStyle(Color.accentColor.gradient)
                }
                .chartXAxisLabel(xLabel)
                .frame(height: 150)
            } else {
                Chart(points) { p in
                    LineMark(x: .value(xLabel, p.x), y: .value(name, p.y))
                        .foregroundStyle(Color.accentColor)
                    PointMark(x: .value(xLabel, p.x), y: .value(name, p.y))
                        .foregroundStyle(Color.accentColor)
                        .symbolSize(24)
                }
                .chartXAxisLabel(xLabel)
                .frame(height: 150)
            }
        }
    }
}

// MARK: - Freezing timeline

struct FreezingTimelineView: View {
    let trace: FreezingTrace
    let config: ZoneConfig

    private struct Bin: Identifiable {
        let id: Int
        let minute: Double
        let motion: Double
    }

    private struct Window: Identifiable {
        let id: Int
        let start: Double
        let end: Double
    }

    private var bins: [Bin] {
        guard let first = trace.times.first, let last = trace.times.last, last > first else { return [] }
        let count = min(700, max(1, trace.times.count))
        let width = (last - first) / Double(count)
        var sums = [Double](repeating: 0, count: count)
        var ns = [Double](repeating: 0, count: count)
        for (t, m) in zip(trace.times, trace.bodyMotionPct) {
            guard let m else { continue }
            let i = min(count - 1, max(0, Int((t - first) / max(width, 1e-9))))
            sums[i] += m
            ns[i] += 1
        }
        return (0..<count).compactMap { i in
            ns[i] > 0 ? Bin(id: i, minute: (first + (Double(i) + 0.5) * width) / 60, motion: sums[i] / ns[i]) : nil
        }
    }

    private var csWindows: [Window] {
        config.csOnsetsSeconds.sorted().enumerated().map { i, onset in
            Window(id: i, start: onset / 60, end: (onset + config.csDurationSeconds) / 60)
        }
    }

    private var yMax: Double {
        let values = trace.bodyMotionPct.compactMap { $0 }
        let p95 = Stats.quantile(values, 0.95)
        return max(config.freezeThresholdPct * 3, p95.isFinite ? p95 * 1.1 : 10, 1)
    }

    var body: some View {
        let top = yMax
        VStack(alignment: .leading, spacing: 6) {
            Text(loc("Motion (body-area %) and freezing"))
                .appFont(14, weight: .semibold)
            Chart {
                ForEach(csWindows) { w in
                    RectangleMark(xStart: .value("Time", w.start), xEnd: .value("Time", w.end),
                                  yStart: .value("Motion", 0.0), yEnd: .value("Motion", top))
                        .foregroundStyle(.orange.opacity(0.16))
                }
                ForEach(bins) { b in
                    LineMark(x: .value("Time", b.minute), y: .value("Motion", min(b.motion, top)))
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 1))
                }
                RuleMark(y: .value("Threshold", config.freezeThresholdPct))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
            }
            .chartYScale(domain: 0...top)
            .chartXAxisLabel("Time (min, from protocol start)")
            .frame(height: 170)

            FreezingRaster(trace: trace, config: config)
                .frame(height: 18)
            HStack(spacing: 12) {
                legendSwatch(.blue, "Freezing bouts")
                legendSwatch(.orange.opacity(0.5), "CS")
                legendSwatch(.red, "Threshold")
            }
            .appFont(12)
            .foregroundStyle(.secondary)
        }
    }

    private func legendSwatch(_ color: Color, _ text: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 12, height: 8)
            Text(loc(text))
        }
    }
}

/// Thin strip showing freezing bouts along the session.
struct FreezingRaster: View {
    let trace: FreezingTrace
    let config: ZoneConfig

    var body: some View {
        Canvas { context, size in
            guard let first = trace.times.first, let last = trace.times.last, last > first else { return }
            let span = last - first
            func x(_ t: Double) -> CGFloat { CGFloat((t - first) / span) * size.width }
            context.fill(Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 3), with: .color(.secondary.opacity(0.12)))
            for onset in config.csOnsetsSeconds {
                let rect = CGRect(x: x(onset), y: 0, width: max(1, x(onset + config.csDurationSeconds) - x(onset)), height: size.height)
                context.fill(Path(rect), with: .color(.orange.opacity(0.35)))
            }
            var i = 0
            while i < trace.frozen.count {
                guard trace.frozen[i] else { i += 1; continue }
                var j = i
                while j < trace.frozen.count && trace.frozen[j] { j += 1 }
                let end = j < trace.times.count ? trace.times[j] : last
                let rect = CGRect(x: x(trace.times[i]), y: 3, width: max(1, x(end) - x(trace.times[i])), height: size.height - 6)
                context.fill(Path(rect), with: .color(.blue))
                i = j
            }
        }
    }
}

// MARK: - Two-armed bandit session

struct BanditSessionChart: View {
    let rows: [ManualRow]

    private struct Point: Identifiable {
        let id: Int
        let trial: Double
        let value: Double
        let series: String
    }

    private struct Tick: Identifiable {
        let id: Int
        let trial: Double
        let y: Double
    }

    private var lines: [Point] {
        let trials = Bandit.trials(rows)
        guard !trials.isEmpty else { return [] }
        let window = 10
        var out: [Point] = []
        let stride = max(1, trials.count / 1500)
        var running: [Double] = []
        for (i, t) in trials.enumerated() {
            running.append(Double(t.choice))
            if running.count > window { running.removeFirst() }
            guard i % stride == 0 else { continue }
            out.append(Point(id: out.count, trial: Double(i + 1), value: Stats.mean(running), series: loc("P(choose right), 10-trial avg")))
            if let pr = t.pRight {
                out.append(Point(id: out.count, trial: Double(i + 1), value: pr, series: loc("P(reward | right)")))
            }
        }
        return out
    }

    private var rewardTicks: [Tick] {
        let trials = Bandit.trials(rows)
        guard trials.count <= 800 else { return [] }
        return trials.enumerated().compactMap { i, t in
            t.reward > 0 ? Tick(id: i, trial: Double(i + 1), y: t.choice == 1 ? 1.07 : -0.07) : nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choices across the session")
                .appFont(14, weight: .semibold)
            Chart {
                ForEach(lines) { p in
                    LineMark(x: .value("Trial", p.trial), y: .value("Probability", p.value), series: .value("Series", p.series))
                        .foregroundStyle(by: .value("Series", p.series))
                        .lineStyle(StrokeStyle(lineWidth: p.series == loc("P(reward | right)") ? 1 : 1.6))
                }
                ForEach(rewardTicks) { tick in
                    PointMark(x: .value("Trial", tick.trial), y: .value("Probability", tick.y))
                        .symbolSize(6)
                        .foregroundStyle(.green)
                }
            }
            .chartYScale(domain: -0.12...1.12)
            .chartLegend(position: .bottom)
            .frame(height: 190)
            Text("Green ticks: rewarded trials (top = right, bottom = left).")
                .appFont(12)
                .foregroundStyle(.secondary)
        }
    }
}
