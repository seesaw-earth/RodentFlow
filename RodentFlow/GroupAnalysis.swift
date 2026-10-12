import Foundation

// MARK: - Request / result types

enum GroupDesign: String, CaseIterable, Codable, Identifiable {
    case betweenGroups = "between_groups"
    case byDay = "by_day"
    case withinSession = "within_session"
    case pairedMeasures = "paired_measures"
    case phaseChange = "phase_change"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .betweenGroups: return loc("Compare groups")
        case .byDay: return loc("Across days")
        case .withinSession: return loc("Time course")
        case .pairedMeasures: return loc("Paired measures")
        case .phaseChange: return loc("Change between phases")
        }
    }

    var explanation: String {
        switch self {
        case .betweenGroups: return loc("One value per animal (sessions averaged within animal).")
        case .byDay: return loc("Learning curve: one value per animal per day (trials averaged within day).")
        case .withinSession: return loc("Series stored in each record: time bins, CS presentations, trials or days.")
        case .pairedMeasures: return loc("Two measures from the same animal, e.g. novel vs familiar.")
        case .phaseChange: return loc("Per-animal difference between two phases, e.g. test − pre-test.")
        }
    }
}

enum StatMode: String, CaseIterable, Codable, Identifiable {
    case parametric
    case nonparametric
    var id: String { rawValue }
    var displayName: String { self == .parametric ? loc("Parametric") : loc("Non-parametric") }
}

enum ComparisonMode: String, CaseIterable, Codable, Identifiable {
    case allPairs = "all_pairs"
    case versusControl = "versus_control"
    var id: String { rawValue }
    var displayName: String { self == .allPairs ? loc("All pairs") : loc("Vs. first group") }
}

struct GroupAnalysisRequest: Codable, Hashable {
    var assay: AssayKind
    var design: GroupDesign = .betweenGroups
    var metricKey: String = ""
    var seriesKey: String = ""
    var pairKey: String = ""
    /// nil = all phases.
    var phaseFilter: String?
    var phaseA: String = ""
    var phaseB: String = ""
    /// Included groups in display order; the first one is treated as the control.
    var groups: [String] = []
    var includeExcluded = false
    var mode: StatMode = .parametric
    var comparison: ComparisonMode = .allPairs
    var testAgainstChance = false
}

struct SubjectPoint: Codable, Hashable, Identifiable {
    var subject: String
    var group: String
    var value: Double
    var records: Int
    var id: String { group + "|" + subject }
}

struct CurvePoint: Codable, Hashable, Identifiable {
    var group: String
    var level: Double
    var mean: Double
    var sem: Double
    var n: Int
    var id: String { "\(group)|\(level)" }
}

struct SubjectSeries: Codable, Hashable, Identifiable {
    var subject: String
    var group: String
    var values: [Double?]
    var id: String { group + "|" + subject }
}

struct PairedPoint: Codable, Hashable, Identifiable {
    var subject: String
    var group: String
    var a: Double
    var b: Double
    var id: String { group + "|" + subject }
}

struct GroupTestReport: Codable, Hashable {
    var omnibus: TestResult?
    var mixed: StatTests.MixedANOVAOutput?
    var pairwise: [PairwiseComparison] = []
    var perGroup: [String: TestResult] = [:]
    var perGroupLabel = ""
    var methodSummary = ""
}

struct GroupAnalysisResult: Codable {
    var request: GroupAnalysisRequest
    var metricName = ""
    var unit = ""
    var levelLabel = ""
    var groups: [String] = []
    var points: [SubjectPoint] = []
    var descriptives: [String: Descriptives] = [:]
    var levels: [Double] = []
    var curves: [CurvePoint] = []
    var subjectSeries: [SubjectSeries] = []
    var paired: [PairedPoint] = []
    var pairLabelA = ""
    var pairLabelB = ""
    var chance: Double?
    var report = GroupTestReport()
    var notes: [String] = []
    var generatedAt = Date()

    var animalCount: Int {
        switch request.design {
        case .betweenGroups, .phaseChange: return points.count
        case .byDay, .withinSession: return subjectSeries.count
        case .pairedMeasures: return paired.count
        }
    }

    var isEmpty: Bool { animalCount == 0 }

    var axisTitle: String { unit.isEmpty ? metricName : "\(metricName) (\(unit))" }
}

struct SeriesOption: Hashable, Identifiable {
    var key: String
    var name: String
    var unit: String
    var xLabel: String
    var id: String { key }
}

// MARK: - Engine

enum GroupAnalysisEngine {
    static let controlHints = ["control", "ctrl", "wt", "wild", "vehicle", "veh", "saline", "sham", "naive", "con"]

    /// Groups ordered with a likely control first, then alphabetically.
    static func orderedGroups(_ records: [ExperimentResult]) -> [String] {
        let names = Set(records.map(\.displayGroup))
        return names.sorted { a, b in
            let ca = isLikelyControl(a), cb = isLikelyControl(b)
            if ca != cb { return ca }
            return a.localizedStandardCompare(b) == .orderedAscending
        }
    }

    static func isLikelyControl(_ name: String) -> Bool {
        let lower = name.lowercased()
        return controlHints.contains { lower == $0 || lower.hasPrefix($0 + " ") || lower.hasPrefix($0 + "-") || lower.hasPrefix($0 + "_") || lower.hasPrefix($0 + "/") }
    }

    static func phases(_ records: [ExperimentResult]) -> [String] {
        var seen: [String] = []
        let assayPhases = records.first?.assay.phases ?? []
        for p in assayPhases where records.contains(where: { $0.phase == p }) { seen.append(p) }
        for r in records where !r.phase.isEmpty && !seen.contains(r.phase) { seen.append(r.phase) }
        return seen
    }

    static func days(_ records: [ExperimentResult]) -> [Int] {
        Array(Set(records.compactMap(\.day))).sorted()
    }

    static func metricOptions(assay: AssayKind, records: [ExperimentResult]) -> [MetricDefinition] {
        let present = Set(records.flatMap { $0.metrics.keys })
        var defs = AssayCatalog.metrics(for: assay).filter { present.contains($0.key) }
        let known = Set(defs.map(\.key))
        var customNames: [String: String] = [:]
        for r in records { for (k, v) in r.customMetricNames ?? [:] { customNames[k] = v } }
        let catalogKeys = Set(AssayCatalog.metrics(for: assay).map(\.key))
        for key in present.sorted() where !known.contains(key) && !catalogKeys.contains(key) {
            defs.append(MetricDefinition(key, customNames[key] ?? key, "", "Imported value.", decimals: 3))
        }
        return defs
    }

    static func seriesOptions(_ records: [ExperimentResult]) -> [SeriesOption] {
        var out: [SeriesOption] = []
        for r in records {
            for s in r.series where !out.contains(where: { $0.key == s.key }) {
                out.append(SeriesOption(key: s.key, name: loc(s.name), unit: s.unit, xLabel: loc(s.xLabel)))
            }
        }
        return out
    }

    static func availableDesigns(assay: AssayKind, records: [ExperimentResult]) -> [GroupDesign] {
        var designs: [GroupDesign] = [.betweenGroups]
        if days(records).count >= 2 { designs.append(.byDay) }
        if !seriesOptions(records).isEmpty { designs.append(.withinSession) }
        let pairs = assay.withinPairs.filter { pair in records.contains { $0.metrics[pair.metricA] != nil && $0.metrics[pair.metricB] != nil } }
        if !pairs.isEmpty { designs.append(.pairedMeasures) }
        if phases(records).count >= 2 { designs.append(.phaseChange) }
        return designs
    }

    /// A reasonable starting request for an assay and the records available.
    static func defaultRequest(assay: AssayKind, records: [ExperimentResult]) -> GroupAnalysisRequest {
        var req = GroupAnalysisRequest(assay: assay)
        let ph = phases(records)
        if !assay.phases.isEmpty, !ph.isEmpty {
            // Never pool different phases by default (e.g. acquisition and probe trials).
            if let preferred = assay.analysisDefaultPhase, ph.contains(preferred) {
                req.phaseFilter = preferred
            } else {
                req.phaseFilter = ph[0]
            }
        }
        let primaryPhase = req.phaseFilter ?? (ph.count == 1 ? ph[0] : "")
        let metrics = metricOptions(assay: assay, records: records)
        let primary = assay.primaryMetricKey(phase: primaryPhase)
        req.metricKey = metrics.contains(where: { $0.key == primary }) ? primary : (metrics.first?.key ?? "")
        req.groups = orderedGroups(records)
        if assay.usesDays && days(records).count >= 2 && assay != .custom { req.design = .byDay }
        if ph.count >= 2 {
            req.phaseA = ph.first(where: { $0.lowercased().contains("pre") }) ?? ph[0]
            req.phaseB = ph.first(where: { $0 == "Test" }) ?? ph[ph.count - 1]
        }
        req.seriesKey = seriesOptions(records).first?.key ?? ""
        req.pairKey = assay.withinPairs.first?.key ?? ""
        return req
    }

    // MARK: Run

    static func run(_ req: GroupAnalysisRequest, records allRecords: [ExperimentResult]) -> GroupAnalysisResult {
        var result = GroupAnalysisResult(request: req)
        var records = allRecords.filter { $0.assay == req.assay }
        let excludedCount = records.filter(\.excluded).count
        if !req.includeExcluded {
            records.removeAll(where: \.excluded)
            if excludedCount > 0 { result.notes.append(locf("%ld excluded record(s) left out.", excludedCount)) }
        }
        if req.design != .phaseChange, let phase = req.phaseFilter {
            records = records.filter { $0.phase == phase }
        }
        let groupSet = Set(req.groups)
        records = records.filter { groupSet.contains($0.displayGroup) }
        result.groups = req.groups.filter { g in records.contains { $0.displayGroup == g } }

        let def = metricOptions(assay: req.assay, records: allRecords).first { $0.key == req.metricKey }
        result.metricName = def?.name ?? req.metricKey
        result.unit = def?.unit ?? ""
        result.chance = def?.chance

        let flagged = records.filter { !$0.qcFlags.isEmpty }
        if !flagged.isEmpty {
            let names = flagged.prefix(4).map(\.displaySubject).joined(separator: ", ") + (flagged.count > 4 ? "…" : "")
            result.notes.append(locf("%ld included record(s) have QC warnings (%@). Open them in the Experiment tab and mark as excluded if your criteria require it.", flagged.count, names))
        }
        let unnamed = records.filter { $0.subjectID.trimmingCharacters(in: .whitespaces).isEmpty }.count
        if unnamed > 0 { result.notes.append(locf("%ld record(s) without a subject ID were treated as separate animals.", unnamed)) }

        switch req.design {
        case .betweenGroups:
            result.points = subjectMeans(records, metric: req.metricKey)
            noteAveraging(&result)
            analyzeIndependent(&result)
        case .phaseChange:
            result.metricName = "Δ " + result.metricName + " (\(AssayKind.phaseTitle(req.phaseB)) − \(AssayKind.phaseTitle(req.phaseA)))"
            result.points = phaseDifferences(records, metric: req.metricKey, phaseA: req.phaseA, phaseB: req.phaseB, notes: &result.notes)
            result.chance = 0
            analyzeIndependent(&result)
        case .byDay:
            result.levelLabel = loc("Day")
            let rows = records.compactMap { r -> (String, String, Double, Double)? in
                guard let day = r.day, let v = r.metrics[req.metricKey], v.isFinite else { return nil }
                return (r.displayGroup, subjectKey(r), Double(day), v)
            }
            if rows.count < records.count { result.notes.append(locf("%ld record(s) without a day or value were skipped.", records.count - rows.count)) }
            buildRepeated(&result, rows: rows)
        case .withinSession:
            let option = seriesOptions(records).first { $0.key == req.seriesKey }
            result.metricName = option?.name ?? req.seriesKey
            result.unit = option?.unit ?? ""
            result.levelLabel = option?.xLabel ?? loc("Level")
            result.chance = nil
            var rows: [(String, String, Double, Double)] = []
            for r in records {
                guard let s = r.series.first(where: { $0.key == req.seriesKey }) else { continue }
                for (x, y) in zip(s.x, s.y) where x.isFinite && y.isFinite { rows.append((r.displayGroup, subjectKey(r), x, y)) }
            }
            buildRepeated(&result, rows: rows)
        case .pairedMeasures:
            analyzePaired(&result, records: records)
        }
        return result
    }

    static func subjectKey(_ r: ExperimentResult) -> String {
        let s = r.subjectID.trimmingCharacters(in: .whitespaces)
        return s.isEmpty ? "record-" + r.id.uuidString.prefix(8) : s
    }

    static func subjectMeans(_ records: [ExperimentResult], metric: String) -> [SubjectPoint] {
        var sums: [String: (group: String, subject: String, sum: Double, n: Int)] = [:]
        var order: [String] = []
        for r in records {
            guard let v = r.metrics[metric], v.isFinite else { continue }
            let key = r.displayGroup + "|" + subjectKey(r)
            if sums[key] == nil {
                sums[key] = (r.displayGroup, subjectKey(r), 0, 0)
                order.append(key)
            }
            sums[key]!.sum += v
            sums[key]!.n += 1
        }
        return order.compactMap { key in
            guard let e = sums[key] else { return nil }
            return SubjectPoint(subject: e.subject, group: e.group, value: e.sum / Double(e.n), records: e.n)
        }
    }

    static func noteAveraging(_ result: inout GroupAnalysisResult) {
        let multi = result.points.filter { $0.records > 1 }
        if !multi.isEmpty {
            result.notes.append(locf("%ld animal(s) had several sessions; their values were averaged so n = animals. Filter by phase or day to analyze one session.", multi.count))
        }
        let subjects = Dictionary(grouping: result.points, by: \.subject).filter { $0.value.count > 1 }
        if !subjects.isEmpty {
            result.notes.append(locf("Subject ID(s) appearing in more than one group: %@. Check the group labels.", subjects.keys.sorted().joined(separator: ", ")))
        }
    }

    static func phaseDifferences(_ records: [ExperimentResult], metric: String, phaseA: String, phaseB: String, notes: inout [String]) -> [SubjectPoint] {
        let a = subjectMeans(records.filter { $0.phase == phaseA }, metric: metric)
        let b = subjectMeans(records.filter { $0.phase == phaseB }, metric: metric)
        var out: [SubjectPoint] = []
        var unmatched = 0
        for pb in b {
            if let pa = a.first(where: { $0.subject == pb.subject && $0.group == pb.group }) {
                out.append(SubjectPoint(subject: pb.subject, group: pb.group, value: pb.value - pa.value, records: pa.records + pb.records))
            } else {
                unmatched += 1
            }
        }
        unmatched += a.filter { pa in !b.contains { $0.subject == pa.subject && $0.group == pa.group } }.count
        if unmatched > 0 { notes.append(locf("%ld animal(s) had only one of the two phases and were left out.", unmatched)) }
        return out
    }

    // MARK: Independent groups (one value per animal)

    static func analyzeIndependent(_ result: inout GroupAnalysisResult) {
        let req = result.request
        let groups = result.groups
        var values: [[Double]] = []
        for g in groups {
            let v = result.points.filter { $0.group == g }.map(\.value)
            values.append(v)
            result.descriptives[g] = Stats.describe(v)
        }
        let present = zip(groups, values).filter { !$0.1.isEmpty }
        let names = present.map { $0.0 }
        let data = present.map { $0.1 }
        var report = GroupTestReport()
        let k = data.count

        if k == 2 {
            if req.mode == .parametric {
                if let t = StatTests.welchT(data[0], data[1]) {
                    report.omnibus = t
                    report.pairwise = [PairwiseComparison(groupA: names[0], groupB: names[1], level: nil,
                                                          difference: Stats.mean(data[0]) - Stats.mean(data[1]),
                                                          statisticName: "t", statistic: t.statistic, p: t.p, pAdjusted: t.p, method: t.name)]
                    report.methodSummary = loc("Two-tailed Welch's t-test (unequal variances).")
                    if let ci = StatTests.welchDifferenceCI(data[0], data[1]) {
                        result.notes.append(String(format: loc("Mean difference (%@ − %@) = %@, 95%% CI [%@, %@]."), names[0], names[1],
                                                   StatsFormat.number(Stats.mean(data[0]) - Stats.mean(data[1])),
                                                   StatsFormat.number(ci.low), StatsFormat.number(ci.high)))
                    }
                }
            } else if let u = StatTests.mannWhitney(data[0], data[1]) {
                report.omnibus = u
                report.pairwise = [PairwiseComparison(groupA: names[0], groupB: names[1], level: nil,
                                                      difference: Stats.quantile(data[0], 0.5) - Stats.quantile(data[1], 0.5),
                                                      statisticName: "U", statistic: u.statistic, p: u.p, pAdjusted: u.p, method: u.name)]
                report.methodSummary = locf("Two-tailed Mann–Whitney U test (%@).", u.note ?? loc("exact"))
            }
        } else if k >= 3 {
            let control = req.comparison == .versusControl ? 0 : nil
            if req.mode == .parametric {
                report.omnibus = StatTests.oneWayANOVA(data)?.test
                if control == nil {
                    report.pairwise = StatTests.tukeyHSD(data, names: names)
                    report.methodSummary = loc("One-way ANOVA followed by Tukey–Kramer HSD for all pairwise comparisons.")
                } else {
                    var comps: [PairwiseComparison] = []
                    for j in 1..<k {
                        if let t = StatTests.welchT(data[0], data[j]) {
                            comps.append(PairwiseComparison(groupA: names[0], groupB: names[j], level: nil,
                                                            difference: Stats.mean(data[0]) - Stats.mean(data[j]),
                                                            statisticName: "t", statistic: t.statistic, p: t.p, pAdjusted: t.p, method: loc("Welch's t (Holm)")))
                        }
                    }
                    let adj = Stats.holm(comps.map(\.p))
                    for i in comps.indices { comps[i].pAdjusted = adj[i] }
                    report.pairwise = comps
                    report.methodSummary = locf("One-way ANOVA followed by Welch's t-tests of each group against %@ with Holm correction.", names[0])
                }
            } else {
                report.omnibus = StatTests.kruskalWallis(data)
                report.pairwise = StatTests.dunn(data, names: names, controlIndex: control)
                report.methodSummary = control == nil
                    ? loc("Kruskal–Wallis test followed by Dunn's test with Holm correction.")
                    : locf("Kruskal–Wallis test followed by Dunn's test with Holm correction (each group vs %@).", names[0])
            }
        } else if k == 1 {
            report.methodSummary = loc("Single group: descriptive statistics only.")
        }
        if k >= 2 && report.omnibus == nil {
            result.notes.append(loc("No test result: each group needs at least 2 animals with values that differ (identical values give no variability to test)."))
        }

        if req.testAgainstChance, let chance = result.chance {
            for (name, v) in zip(names, data) {
                let test: TestResult?
                if req.mode == .parametric {
                    test = StatTests.oneSampleT(v, mu: chance)
                } else {
                    test = StatTests.wilcoxonSignedRank(v.map { $0 - chance })
                }
                if let test { report.perGroup[name] = test }
            }
            report.perGroupLabel = locf("vs %@", StatsFormat.number(chance))
            report.methodSummary += req.mode == .parametric
                ? " " + locf("One-sample t-tests against %@.", StatsFormat.number(chance))
                : " " + locf("Wilcoxon signed-rank tests against %@.", StatsFormat.number(chance))
        }
        result.report = report
    }

    // MARK: Repeated (days, bins, CS)

    static func buildRepeated(_ result: inout GroupAnalysisResult, rows: [(String, String, Double, Double)]) {
        let req = result.request
        let levels = Array(Set(rows.map { $0.2 })).sorted()
        result.levels = levels
        guard !levels.isEmpty else { return }
        let levelIndex = Dictionary(uniqueKeysWithValues: levels.enumerated().map { ($1, $0) })

        // Average within animal × level (e.g. trials within a day).
        var cell: [String: [Double]] = [:]
        var subjectsByGroup: [String: [String]] = [:]
        for (g, s, x, y) in rows {
            let key = g + "|" + s + "|" + String(levelIndex[x] ?? 0)
            cell[key, default: []].append(y)
            if !(subjectsByGroup[g]?.contains(s) ?? false) { subjectsByGroup[g, default: []].append(s) }
        }
        var series: [SubjectSeries] = []
        for g in result.groups {
            for s in subjectsByGroup[g] ?? [] {
                let values: [Double?] = levels.indices.map { j in
                    cell[g + "|" + s + "|" + String(j)].map { Stats.mean($0) }
                }
                series.append(SubjectSeries(subject: s, group: g, values: values))
            }
        }
        result.subjectSeries = series

        var curves: [CurvePoint] = []
        for g in result.groups {
            let gs = series.filter { $0.group == g }
            for (j, level) in levels.enumerated() {
                let v = gs.compactMap { $0.values[j] }
                guard !v.isEmpty else { continue }
                let d = Stats.describe(v)
                curves.append(CurvePoint(group: g, level: level, mean: d.mean, sem: d.sem, n: d.n))
            }
            result.descriptives[g] = Stats.describe(gs.compactMap { s -> Double? in
                let v = s.values.compactMap { $0 }
                return v.isEmpty ? nil : Stats.mean(v)
            })
        }
        result.curves = curves

        var report = GroupTestReport()
        let groupsWithData = result.groups.filter { g in series.contains { $0.group == g } }
        let complete = series.filter { $0.values.allSatisfy { $0 != nil } }
        let dropped = series.count - complete.count

        if levels.count >= 2 {
            if req.mode == .parametric {
                let data = groupsWithData.map { g in complete.filter { $0.group == g }.map { $0.values.map { $0 ?? 0 } } }
                if let mixed = StatTests.mixedANOVA(data, levelCount: levels.count, dropped: dropped) {
                    report.mixed = mixed
                    report.methodSummary = groupsWithData.count >= 2
                        ? locf("Two-way mixed ANOVA (group × %@, animal as the repeated unit) with Greenhouse–Geisser correction for the within-animal factor.", result.levelLabel.lowercased())
                        : loc("One-way repeated-measures ANOVA with Greenhouse–Geisser correction.")
                }
                if dropped > 0 {
                    result.notes.append(locf("%ld animal(s) missing at least one %@ were left out of the ANOVA (still shown in the plot).", dropped, result.levelLabel.lowercased()))
                }
            } else if groupsWithData.count == 1 {
                let rowsComplete = complete.map { $0.values.map { $0 ?? 0 } }
                report.omnibus = StatTests.friedman(rowsComplete)
                report.methodSummary = locf("Friedman test across %@s.", result.levelLabel.lowercased())
            } else {
                report.methodSummary = locf("Non-parametric: per-%@ Mann–Whitney tests with Holm correction (no omnibus test).", result.levelLabel.lowercased())
            }
        }

        // Post-hoc: groups compared at each level.
        if groupsWithData.count >= 2 {
            var comps: [PairwiseComparison] = []
            for (j, level) in levels.enumerated() {
                let byGroup = groupsWithData.map { g in series.filter { $0.group == g }.compactMap { $0.values[j] } }
                for a in 0..<groupsWithData.count {
                    for b in (a + 1)..<groupsWithData.count {
                        if req.comparison == .versusControl && a != 0 { continue }
                        let x = byGroup[a], y = byGroup[b]
                        let label = levelName(level, label: result.levelLabel)
                        if req.mode == .parametric, let t = StatTests.welchT(x, y) {
                            comps.append(PairwiseComparison(groupA: groupsWithData[a], groupB: groupsWithData[b], level: label,
                                                            difference: Stats.mean(x) - Stats.mean(y), statisticName: "t",
                                                            statistic: t.statistic, p: t.p, pAdjusted: t.p, method: loc("Welch's t (Holm)")))
                        } else if req.mode == .nonparametric, let u = StatTests.mannWhitney(x, y) {
                            comps.append(PairwiseComparison(groupA: groupsWithData[a], groupB: groupsWithData[b], level: label,
                                                            difference: Stats.quantile(x, 0.5) - Stats.quantile(y, 0.5), statisticName: "U",
                                                            statistic: u.statistic, p: u.p, pAdjusted: u.p, method: loc("Mann–Whitney (Holm)")))
                        }
                    }
                }
            }
            let adj = Stats.holm(comps.map(\.p))
            for i in comps.indices { comps[i].pAdjusted = adj[i] }
            report.pairwise = comps
            if !comps.isEmpty {
                report.methodSummary += " " + (req.mode == .parametric
                    ? locf("Group differences at each %@: Welch's t-tests, Holm-corrected across all comparisons.", result.levelLabel.lowercased())
                    : locf("Group differences at each %@: Mann–Whitney tests, Holm-corrected across all comparisons.", result.levelLabel.lowercased()))
            }
        }
        result.report = report
    }

    static func levelName(_ level: Double, label: String) -> String {
        let number = abs(level - level.rounded()) < 1e-9 ? String(format: "%.0f", level) : String(format: "%.1f", level)
        if label == loc("Day") { return locf("Day %@", number) }   // "Day 3" / "第 3 天"
        return label.isEmpty ? number : "\(label) \(number)"
    }

    // MARK: Paired measures

    static func analyzePaired(_ result: inout GroupAnalysisResult, records: [ExperimentResult]) {
        let req = result.request
        guard let pair = req.assay.withinPairs.first(where: { $0.key == req.pairKey }) ?? req.assay.withinPairs.first else { return }
        let defA = AssayCatalog.metrics(for: req.assay).first { $0.key == pair.metricA }
        result.metricName = pair.name
        result.unit = defA?.unit ?? ""
        result.pairLabelA = pair.labelA
        result.pairLabelB = pair.labelB
        result.chance = nil

        let a = subjectMeans(records, metric: pair.metricA)
        let b = subjectMeans(records, metric: pair.metricB)
        var paired: [PairedPoint] = []
        for pa in a {
            if let pb = b.first(where: { $0.subject == pa.subject && $0.group == pa.group }) {
                paired.append(PairedPoint(subject: pa.subject, group: pa.group, a: pa.value, b: pb.value))
            }
        }
        result.paired = paired

        var report = GroupTestReport()
        report.perGroupLabel = locf("%@ vs %@", pair.labelA, pair.labelB)
        var differencesByGroup: [[Double]] = []
        var groupsWithData: [String] = []
        for g in result.groups {
            let pts = paired.filter { $0.group == g }
            guard !pts.isEmpty else { continue }
            groupsWithData.append(g)
            differencesByGroup.append(pts.map { $0.a - $0.b })
            result.descriptives[g] = Stats.describe(pts.map { $0.a - $0.b })
            let test = req.mode == .parametric
                ? StatTests.pairedT(pts.map(\.a), pts.map(\.b))
                : StatTests.wilcoxonSignedRank(pts.map { $0.a - $0.b })
            if let test { report.perGroup[g] = test }
        }
        report.methodSummary = req.mode == .parametric
            ? locf("Within each group: paired t-test (%@ vs %@).", pair.labelA, pair.labelB)
            : locf("Within each group: Wilcoxon signed-rank test (%@ vs %@).", pair.labelA, pair.labelB)

        if groupsWithData.count >= 2 {
            if req.mode == .parametric {
                let data = groupsWithData.map { g in paired.filter { $0.group == g }.map { [$0.a, $0.b] } }
                report.mixed = StatTests.mixedANOVA(data, levelCount: 2)
                report.methodSummary += " " + locf("Between groups: two-way mixed ANOVA (group × measure); the interaction tests whether the %@–%@ difference differs between groups.", pair.labelA, pair.labelB)
            } else {
                report.omnibus = groupsWithData.count == 2
                    ? StatTests.mannWhitney(differencesByGroup[0], differencesByGroup[1])
                    : StatTests.kruskalWallis(differencesByGroup)
                report.methodSummary += " " + (groupsWithData.count == 2
                    ? locf("Between groups: the %@ − %@ differences were compared with a Mann–Whitney test.", pair.labelA, pair.labelB)
                    : locf("Between groups: the %@ − %@ differences were compared with a Kruskal–Wallis test.", pair.labelA, pair.labelB))
            }
        }
        result.report = report
    }
}
