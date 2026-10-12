import Foundation
import Combine

/// Observable wrapper around `ResultsStore` shared by both tabs.
@MainActor
final class ResultsLibrary: ObservableObject {
    @Published private(set) var results: [ExperimentResult] = []
    @Published private(set) var unlinkedRunCount = 0
    @Published var lastError: String?

    init() {
        reload()
    }

    func reload() {
        results = ResultsStore.loadAll()
        refreshUnlinkedRuns()
    }

    func refreshUnlinkedRuns() {
        unlinkedRunCount = ResultsStore.unlinkedRunFolders(known: Set(results.compactMap(\.runFolderName))).count
    }

    func result(id: UUID) -> ExperimentResult? {
        results.first { $0.id == id }
    }

    func records(for assay: AssayKind) -> [ExperimentResult] {
        results.filter { $0.assay == assay }
    }

    var assaysWithData: [AssayKind] {
        AssayKind.allCases.filter { assay in results.contains { $0.assay == assay } }
    }

    func groups(for assay: AssayKind) -> [String] {
        GroupAnalysisEngine.orderedGroups(records(for: assay)).filter { $0 != ExperimentResult.ungroupedLabel }
    }

    @discardableResult
    func save(_ result: ExperimentResult) -> Bool {
        var r = result
        r.updatedAt = Date()
        do {
            try ResultsStore.save(r)
            if let index = results.firstIndex(where: { $0.id == r.id }) {
                results[index] = r
            } else {
                results.insert(r, at: 0)
            }
            ResultsStore.writeResultIntoRunFolder(r)
            return true
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func add(_ list: [ExperimentResult]) -> Int {
        var count = 0
        for r in list where save(r) { count += 1 }
        results.sort { $0.experimentDate > $1.experimentDate }
        return count
    }

    func delete(_ result: ExperimentResult) {
        do {
            try ResultsStore.delete(result)
        } catch {
            lastError = error.localizedDescription
        }
        results.removeAll { $0.id == result.id }
        refreshUnlinkedRuns()
    }

    /// Creates results for run folders that have tracking data but no result record.
    @discardableResult
    func reanalyzeEarlierRuns() -> Int {
        let known = Set(results.compactMap(\.runFolderName))
        var count = 0
        for folder in ResultsStore.unlinkedRunFolders(known: known) {
            if let r = ResultsStore.resultFromLegacyRun(folder), save(r) { count += 1 }
        }
        refreshUnlinkedRuns()
        return count
    }
}
