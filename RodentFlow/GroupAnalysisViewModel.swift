import Foundation
import Combine

enum GroupChartStyle: String, CaseIterable, Identifiable {
    case barDots = "Bar + points"
    case boxDots = "Box + points"
    case meanDots = "Mean ± SEM"
    var id: String { rawValue }
    var displayName: String { loc(rawValue) }
}

/// State of the Groups tab: which assay / measure / design is analyzed, group order, colors and
/// inclusion (persisted per assay), and the latest analysis result.
@MainActor
final class GroupAnalysisViewModel: ObservableObject {
    @Published private(set) var assay: AssayKind?
    @Published var request = GroupAnalysisRequest(assay: .openField)
    @Published private(set) var result: GroupAnalysisResult?
    @Published private(set) var availableGroups: [String] = []
    @Published var chartStyle: GroupChartStyle = .barDots
    @Published var showNonSignificant = false

    private var records: [ExperimentResult] = []
    /// Changes whenever the records change; with the request it identifies an analysis.
    private var recordsVersion = 0
    private var lastRun: (request: GroupAnalysisRequest, recordsVersion: Int)?
    private var styles: [String: [String: GroupStyle]] = GroupSettingsStore.load()

    var assayRecords: [ExperimentResult] {
        guard let assay else { return [] }
        return records.filter { $0.assay == assay }
    }

    var availableAssays: [AssayKind] {
        AssayKind.allCases.filter { a in records.contains { $0.assay == a } }
    }

    var designs: [GroupDesign] {
        guard let assay else { return [.betweenGroups] }
        return GroupAnalysisEngine.availableDesigns(assay: assay, records: assayRecords)
    }

    var metricOptions: [MetricDefinition] {
        guard let assay else { return [] }
        return GroupAnalysisEngine.metricOptions(assay: assay, records: assayRecords)
    }

    var seriesOptions: [SeriesOption] { GroupAnalysisEngine.seriesOptions(assayRecords) }
    var phases: [String] { GroupAnalysisEngine.phases(assayRecords) }

    var pairOptions: [MetricPair] {
        guard let assay else { return [] }
        return assay.withinPairs.filter { pair in
            assayRecords.contains { $0.metrics[pair.metricA] != nil && $0.metrics[pair.metricB] != nil }
        }
    }

    var currentMetric: MetricDefinition? { metricOptions.first { $0.key == request.metricKey } }

    var summaryLine: String {
        let recs = assayRecords
        let animals = Set(recs.map { $0.displayGroup + "|" + GroupAnalysisEngine.subjectKey($0) }).count
        let groups = Set(recs.map(\.displayGroup)).count
        return locf("%ld record(s) · %ld animal(s) · %ld group(s)", recs.count, animals, groups)
    }

    // MARK: Data flow

    func update(records all: [ExperimentResult]) {
        // The tab calls this every time it appears; nothing to do when the records are unchanged.
        if all == records && assay != nil && result != nil { return }
        if all != records { recordsVersion += 1 }
        records = all
        let assays = availableAssays
        if let current = assay, assays.contains(current) {
            refreshGroups()
            sanitizeRequest()
        } else if let first = assays.first {
            configure(first)
        } else {
            assay = nil
            result = nil
            availableGroups = []
            return
        }
        run()
    }

    func select(_ newAssay: AssayKind) {
        guard newAssay != assay else { return }
        configure(newAssay)
        run()
    }

    private func configure(_ newAssay: AssayKind) {
        assay = newAssay
        var req = GroupAnalysisEngine.defaultRequest(assay: newAssay, records: records.filter { $0.assay == newAssay })
        req.groups = []
        request = req
        refreshGroups()
    }

    /// Keeps the request valid when the underlying records change.
    private func sanitizeRequest() {
        if !designs.contains(request.design) { request.design = .betweenGroups }
        if !metricOptions.contains(where: { $0.key == request.metricKey }) {
            request.metricKey = metricOptions.first?.key ?? ""
        }
        if let phase = request.phaseFilter, !phases.contains(phase) { request.phaseFilter = nil }
        if request.seriesKey.isEmpty || !seriesOptions.contains(where: { $0.key == request.seriesKey }) {
            request.seriesKey = seriesOptions.first?.key ?? ""
        }
    }

    /// When the phase filter changes, show that phase's primary measure (e.g. probe → target quadrant %).
    func didChangePhase() {
        guard let assay else { return }
        let inPhase = assayRecords.filter { request.phaseFilter == nil || $0.phase == request.phaseFilter }
        let primary = assay.primaryMetricKey(phase: request.phaseFilter ?? "")
        if !primary.isEmpty, inPhase.contains(where: { $0.metrics[primary] != nil }) {
            request.metricKey = primary
        } else if !inPhase.contains(where: { $0.metrics[request.metricKey] != nil }),
                  let first = metricOptions.first(where: { m in inPhase.contains { $0.metrics[m.key] != nil } }) {
            request.metricKey = first.key
        }
        // A probe test is a single session per animal: compare groups rather than days.
        if request.phaseFilter == "Probe" && request.design == .byDay { request.design = .betweenGroups }
    }

    func run() {
        guard assay != nil else {
            result = nil
            lastRun = nil
            return
        }
        // Skip repeated runs of the same analysis (the request and the record list both trigger runs).
        if let lastRun, result != nil, lastRun.request == request, lastRun.recordsVersion == recordsVersion { return }
        result = GroupAnalysisEngine.run(request, records: records)
        lastRun = (request, recordsVersion)
    }

    // MARK: Groups (order, inclusion, colors)

    private var assayKey: String { assay?.rawValue ?? "" }

    func refreshGroups() {
        let defaults = GroupAnalysisEngine.orderedGroups(assayRecords)
        var table = styles[assayKey] ?? [:]
        var changed = false
        for (i, g) in defaults.enumerated() where table[g] == nil {
            let used = Set(table.values.map(\.colorIndex))
            let color = (0..<64).first { !used.contains($0) } ?? i
            table[g] = GroupStyle(order: 1000 + i, colorIndex: color, included: true)
            changed = true
        }
        if changed {
            styles[assayKey] = table
            GroupSettingsStore.save(styles)
        }
        availableGroups = defaults.sorted { (table[$0]?.order ?? 0) < (table[$1]?.order ?? 0) }
        let included = availableGroups.filter { table[$0]?.included ?? true }
        if request.groups != included { request.groups = included }
    }

    func colorIndex(_ group: String) -> Int { styles[assayKey]?[group]?.colorIndex ?? 0 }
    func isIncluded(_ group: String) -> Bool { styles[assayKey]?[group]?.included ?? true }

    func toggle(_ group: String) {
        mutateStyle(group) { $0.included.toggle() }
    }

    func cycleColor(_ group: String, paletteCount: Int) {
        mutateStyle(group) { $0.colorIndex = ($0.colorIndex + 1) % max(1, paletteCount) }
    }

    func move(_ group: String, by offset: Int) {
        var order = availableGroups
        guard let i = order.firstIndex(of: group) else { return }
        let j = i + offset
        guard order.indices.contains(j) else { return }
        order.swapAt(i, j)
        var table = styles[assayKey] ?? [:]
        for (k, g) in order.enumerated() {
            var s = table[g] ?? GroupStyle(order: k, colorIndex: k, included: true)
            s.order = k
            table[g] = s
        }
        styles[assayKey] = table
        GroupSettingsStore.save(styles)
        refreshGroups()
    }

    private func mutateStyle(_ group: String, _ change: (inout GroupStyle) -> Void) {
        var table = styles[assayKey] ?? [:]
        var s = table[group] ?? GroupStyle(order: availableGroups.count, colorIndex: 0, included: true)
        change(&s)
        table[group] = s
        styles[assayKey] = table
        GroupSettingsStore.save(styles)
        refreshGroups()
        objectWillChange.send()
    }

    // MARK: Text summary

    func summaryText() -> String {
        guard let r = result, let assay else { return "" }
        var lines: [String] = []
        lines.append("\(assay.displayName) — \(r.metricName)\(r.unit.isEmpty ? "" : " (\(r.unit))")")
        if let phase = r.request.phaseFilter, r.request.design != .phaseChange { lines.append(locf("Phase: %@", AssayKind.phaseTitle(phase))) }
        for g in r.groups {
            if let d = r.descriptives[g], d.n > 0 {
                lines.append(locf("%@: n = %ld, mean ± SEM = %@ ± %@, median = %@", g, d.n, StatsFormat.number(d.mean), StatsFormat.number(d.sem), StatsFormat.number(d.median)))
            }
        }
        lines.append(r.report.methodSummary)
        if let omnibus = r.report.omnibus { lines.append("\(omnibus.name): \(omnibus.reportLine)") }
        if let m = r.report.mixed {
            if let g = m.group { lines.append(locf("Group: %@", g.reportLine)) }
            lines.append("\(r.levelLabel.isEmpty ? loc("Within") : r.levelLabel): \(m.level.reportLine)")
            if let i = m.interaction { lines.append(locf("Interaction: %@", i.reportLine)) }
        }
        for c in r.report.pairwise {
            let level = c.level.map { " [\($0)]" } ?? ""
            lines.append(locf("%@ vs %@%@: %@ = %@, adjusted %@ %@", c.groupA, c.groupB, level, c.statisticName, StatsFormat.number(c.statistic), StatsFormat.p(c.pAdjusted), StatsFormat.stars(c.pAdjusted)))
        }
        for g in r.report.perGroup.keys.sorted() {
            if let t = r.report.perGroup[g] { lines.append("\(g) (\(r.report.perGroupLabel)): \(t.reportLine)") }
        }
        lines.append(contentsOf: r.notes)
        lines.append(loc("n = animals. Generated with RodentFlow."))
        return lines.joined(separator: "\n")
    }
}
