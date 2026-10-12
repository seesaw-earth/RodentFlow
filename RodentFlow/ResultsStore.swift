import Foundation

// MARK: - Saved tracking file (full_tracking.json)

struct TrackingFileDocument: Decodable {
    struct Sample: Decodable {
        let videoTimeSeconds: Double
        let xCentimeters: Double
        let yCentimeters: Double
        let interpolated: Bool
        let zone: String
        let motionIndex: Double?
        let blobAreaFraction: Double?
    }

    let samples: [Sample]

    var analysisSamples: [AnalysisSample] {
        samples.map {
            AnalysisSample(t: $0.videoTimeSeconds, x: $0.xCentimeters, y: $0.yCentimeters, detected: !$0.interpolated,
                           zone: $0.zone, motion: $0.motionIndex, blobArea: $0.blobAreaFraction)
        }
    }
}

/// Subset of a run's metadata.json needed to re-analyze an earlier run.
struct RunMetadataDocument: Decodable {
    let assay: String?
    let mouseID: String?
    let group: String?
    let experimentDate: Date?
    let arenaShape: String?
    let arenaWidthCM: Double?
    let arenaHeightCM: Double?
    let mazeArmWidthCM: Double?
}

// MARK: - Results library on disk

enum ResultsStore {
    private static var fm: FileManager { FileManager.default }

    static func documentsDirectory() throws -> URL {
        try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    /// Documents/Results/<assay>/<uuid>.json — visible in the Files app.
    static func resultsDirectory() throws -> URL {
        let url = try documentsDirectory().appendingPathComponent("Results", isDirectory: true)
        try fm.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func experimentsDirectory() throws -> URL {
        try documentsDirectory().appendingPathComponent("Experiments", isDirectory: true)
    }

    static func fileURL(for result: ExperimentResult) throws -> URL {
        let folder = try resultsDirectory().appendingPathComponent(result.assay.rawValue, isDirectory: true)
        try fm.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(result.id.uuidString).appendingPathExtension("json")
    }

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    static func save(_ result: ExperimentResult) throws {
        let data = try encoder.encode(result)
        try data.write(to: fileURL(for: result), options: .atomic)
    }

    static func delete(_ result: ExperimentResult) throws {
        let url = try fileURL(for: result)
        if fm.fileExists(atPath: url.path) { try fm.removeItem(at: url) }
    }

    static func loadAll() -> [ExperimentResult] {
        guard let root = try? resultsDirectory(),
              let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { return [] }
        var out: [ExperimentResult] = []
        for case let url as URL in enumerator where url.pathExtension == "json" {
            if let data = try? Data(contentsOf: url), let r = try? decoder.decode(ExperimentResult.self, from: data) {
                out.append(r)
            }
        }
        return out.sorted { $0.experimentDate > $1.experimentDate }
    }

    // MARK: Tracking data for re-analysis

    static func runFolder(named name: String) throws -> URL {
        try experimentsDirectory().appendingPathComponent(name, isDirectory: true)
    }

    static func loadTrackingSamples(runFolderName: String) throws -> [AnalysisSample] {
        let url = try runFolder(named: runFolderName).appendingPathComponent("full_tracking.json")
        let doc = try decoder.decode(TrackingFileDocument.self, from: Data(contentsOf: url))
        return doc.analysisSamples
    }

    static func hasTrackingData(runFolderName: String?) -> Bool {
        guard let runFolderName, let url = try? runFolder(named: runFolderName).appendingPathComponent("full_tracking.json") else { return false }
        return fm.fileExists(atPath: url.path)
    }

    /// Writes `result.json` next to the tracking files so the run folder is self-describing.
    static func writeResultIntoRunFolder(_ result: ExperimentResult) {
        guard let name = result.runFolderName, let folder = try? runFolder(named: name),
              fm.fileExists(atPath: folder.path), let data = try? encoder.encode(result) else { return }
        try? data.write(to: folder.appendingPathComponent("result.json"), options: .atomic)
    }

    /// Run folders created by v1.0 (or interrupted saves) that have tracking data but no result record yet.
    static func unlinkedRunFolders(known: Set<String>) -> [URL] {
        guard let root = try? experimentsDirectory(),
              let children = try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { return [] }
        return children.filter { folder in
            !known.contains(folder.lastPathComponent)
                && fm.fileExists(atPath: folder.appendingPathComponent("full_tracking.json").path)
                && fm.fileExists(atPath: folder.appendingPathComponent("metadata.json").path)
        }.sorted { $0.lastPathComponent > $1.lastPathComponent }
    }

    /// Re-analyzes a v1.0 run folder (Open Field, T-maze, Y-maze) with the 1.1 metric engine.
    static func resultFromLegacyRun(_ folder: URL) -> ExperimentResult? {
        guard let metaData = try? Data(contentsOf: folder.appendingPathComponent("metadata.json")),
              let meta = try? decoder.decode(RunMetadataDocument.self, from: metaData),
              let samples = try? loadTrackingSamples(runFolderName: folder.lastPathComponent) else { return nil }
        let shape = ArenaShape(rawValue: meta.arenaShape ?? "rectangle") ?? .rectangle
        var assay: AssayKind
        switch shape {
        case .tMaze: assay = .tMaze
        case .yMaze: assay = .yMaze
        case .plusMaze: assay = .elevatedPlusMaze
        default: assay = .openField
        }
        // v1.1 run folders record the assay; zone positions are not stored there, so assays that
        // need them (NOR, MWM, Barnes) come back with defaults and should be checked in the result view.
        if let raw = meta.assay, let recorded = AssayKind(rawValue: raw), recorded.videoArenaShapes.contains(shape) {
            assay = recorded
        }
        var config = ZoneConfig.defaults(for: assay, shape: shape, widthCM: meta.arenaWidthCM ?? 40, heightCM: meta.arenaHeightCM ?? 40)
        if let w = meta.mazeArmWidthCM { config.plusArmWidthCM = w }
        var result = ExperimentResult(assay: assay, subjectID: meta.mouseID ?? "", group: meta.group ?? "", source: .video)
        result.experimentDate = meta.experimentDate ?? Date()
        result.runFolderName = folder.lastPathComponent
        result.zoneConfig = config
        result.apply(AssayEngine.compute(assay: assay, phase: "", samples: samples, config: config))
        result.notes = loc("Re-analyzed from a RodentFlow 1.0 run folder.")
        return result
    }

    // MARK: Export helpers

    static func temporaryURL(_ name: String, ext: String) -> URL {
        let safe = name.replacingOccurrences(of: "[^A-Za-z0-9_-]", with: "_", options: .regularExpression)
        return fm.temporaryDirectory.appendingPathComponent(safe.isEmpty ? "RodentFlow" : safe).appendingPathExtension(ext)
    }

    static func exportBundle(_ results: [ExperimentResult], name: String) throws -> URL {
        let bundle = DataImporter.ResultsBundle(results: results)
        let url = temporaryURL(name, ext: "json")
        try encoder.encode(bundle).write(to: url, options: .atomic)
        return url
    }

    static func exportAnalysis(_ analysis: GroupAnalysisResult, name: String) throws -> URL {
        let url = temporaryURL(name, ext: "json")
        try encoder.encode(analysis).write(to: url, options: .atomic)
        return url
    }

    static func writeTemplate(for assay: AssayKind) throws -> URL {
        let url = temporaryURL("RodentFlow_template_\(assay.rawValue)", ext: "csv")
        try DataImporter.template(for: assay).write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}

// MARK: - Group display settings (order, colors, inclusion)

struct GroupStyle: Codable, Hashable {
    var order: Int
    var colorIndex: Int
    var included: Bool
}

enum GroupSettingsStore {
    private static func url() throws -> URL {
        let support = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let root = support.appendingPathComponent("RodentFlow", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return root.appendingPathComponent("group_settings.json")
    }

    static func load() -> [String: [String: GroupStyle]] {
        guard let u = try? url(), let data = try? Data(contentsOf: u),
              let value = try? JSONDecoder().decode([String: [String: GroupStyle]].self, from: data) else { return [:] }
        return value
    }

    static func save(_ value: [String: [String: GroupStyle]]) {
        guard let u = try? url(), let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: u, options: .atomic)
    }
}
