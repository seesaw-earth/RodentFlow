import Foundation
import Combine
import UIKit

// MARK: - Recoverable full-analysis persistence

struct FullAnalysisRecoveryRecord: Codable, Identifiable {
    enum Status: String, Codable {
        case inProgress = "in_progress"
        case paused
    }

    let schemaVersion: String
    let runID: String
    var id: String { runID }
    var status: Status
    let sourceVideoFilename: String
    let originalVideoFilename: String
    let videoSource: VideoSource
    let videoMetadata: VideoMetadata
    let importedAt: Date
    let mouseID: String
    let group: String
    let experimentDate: Date
    let experimentDateSource: ExperimentDateSource
    let arenaShape: ArenaShape
    let arenaWidthCM: Double
    let arenaHeightCM: Double
    let mazeArmWidthCM: Double
    let tStartArmLengthCM: Double
    let tChoiceArmLengthCM: Double
    let yArmLengthCM: Double
    let calibration: ArenaCalibration
    let previewStartSeconds: Double
    let previewResult: TrackingPreviewResult
    let createdAt: Date
    var updatedAt: Date
    var completedSamples: Int
    var lastVideoTimeSeconds: Double
    var lastCheckpointIndex: Int
    /// v1.1: assay, session labels and analysis settings. Absent in v1.0 records.
    var assayContext: AssayRunContext? = nil
}

/// Everything about the assay that must survive a pause / relaunch of a long analysis.
struct AssayRunContext: Codable, Hashable {
    var assay: AssayKind
    var phase: String
    var sex: String
    var day: Int?
    var trial: Int?
    var zoneConfig: ZoneConfig
    var plusArmLengthCM: Double
    var plusArmWidthCM: Double
}

private struct FullAnalysisCheckpointFile: Codable {
    let schemaVersion: String
    let checkpointIndex: Int
    let points: [TrackingPoint]
    let completedSamples: Int
    let lastVideoTimeSeconds: Double
    let nextTargetTimeSeconds: Double
    let trackerState: NativeMouseTracker.SessionState
    let savedAt: Date
}

enum FullAnalysisRecoveryStore {
    private static let fm = FileManager.default

    static func applicationRoot() throws -> URL {
        let support = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let root = support.appendingPathComponent("RodentFlow", isDirectory: true)
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }

    static func importedVideosDirectory() throws -> URL {
        let url = try applicationRoot().appendingPathComponent("ImportedVideos", isDirectory: true)
        try fm.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private static func activeRunsDirectory() throws -> URL {
        let url = try applicationRoot().appendingPathComponent("ActiveAnalysis", isDirectory: true)
        try fm.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private static func runDirectory(_ runID: String) throws -> URL {
        try activeRunsDirectory().appendingPathComponent(runID, isDirectory: true)
    }

    private static func checkpointsDirectory(_ runID: String) throws -> URL {
        let url = try runDirectory(runID).appendingPathComponent("checkpoints", isDirectory: true)
        try fm.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private static func stateURL(_ runID: String) throws -> URL {
        try runDirectory(runID).appendingPathComponent("run_state.json")
    }

    static func sourceURL(for record: FullAnalysisRecoveryRecord) throws -> URL {
        try importedVideosDirectory().appendingPathComponent(record.sourceVideoFilename)
    }

    static func create(
        sourceVideoURL: URL,
        originalVideoFilename: String,
        videoSource: VideoSource,
        videoMetadata: VideoMetadata,
        importedAt: Date,
        mouseID: String,
        group: String,
        experimentDate: Date,
        experimentDateSource: ExperimentDateSource,
        arenaShape: ArenaShape,
        arenaWidthCM: Double,
        arenaHeightCM: Double,
        mazeArmWidthCM: Double,
        tStartArmLengthCM: Double,
        tChoiceArmLengthCM: Double,
        yArmLengthCM: Double,
        calibration: ArenaCalibration,
        previewStartSeconds: Double,
        previewResult: TrackingPreviewResult,
        assayContext: AssayRunContext? = nil
    ) throws -> FullAnalysisRecoveryRecord {
        let runID = UUID().uuidString
        let folder = try runDirectory(runID)
        try fm.createDirectory(at: folder, withIntermediateDirectories: true)
        _ = try checkpointsDirectory(runID)
        let now = Date()
        var record = FullAnalysisRecoveryRecord(
            schemaVersion: "1.0",
            runID: runID,
            status: .inProgress,
            sourceVideoFilename: sourceVideoURL.lastPathComponent,
            originalVideoFilename: originalVideoFilename,
            videoSource: videoSource,
            videoMetadata: videoMetadata,
            importedAt: importedAt,
            mouseID: mouseID,
            group: group,
            experimentDate: experimentDate,
            experimentDateSource: experimentDateSource,
            arenaShape: arenaShape,
            arenaWidthCM: arenaWidthCM,
            arenaHeightCM: arenaHeightCM,
            mazeArmWidthCM: mazeArmWidthCM,
            tStartArmLengthCM: tStartArmLengthCM,
            tChoiceArmLengthCM: tChoiceArmLengthCM,
            yArmLengthCM: yArmLengthCM,
            calibration: calibration,
            previewStartSeconds: previewStartSeconds,
            previewResult: previewResult,
            createdAt: now,
            updatedAt: now,
            completedSamples: 0,
            lastVideoTimeSeconds: 0,
            lastCheckpointIndex: 0
        )
        record.assayContext = assayContext
        try writeJSON(record, to: stateURL(runID))
        return record
    }

    static func saveCheckpoint(runID: String, snapshot: FullVideoAnalyzer.CheckpointSnapshot) throws {
        let checkpoint = FullAnalysisCheckpointFile(
            schemaVersion: "1.0",
            checkpointIndex: snapshot.checkpointIndex,
            points: snapshot.points,
            completedSamples: snapshot.completedSamples,
            lastVideoTimeSeconds: snapshot.lastVideoTimeSeconds,
            nextTargetTimeSeconds: snapshot.nextTargetTimeSeconds,
            trackerState: snapshot.trackerState,
            savedAt: Date()
        )
        let filename = String(format: "checkpoint_%06d.json", snapshot.checkpointIndex)
        let checkpointURL = try checkpointsDirectory(runID).appendingPathComponent(filename)
        // Chunk first, state second. If power is lost between these two atomic writes,
        // resume scans the chunks and still recovers the newer completed chunk.
        try writeJSON(checkpoint, to: checkpointURL)

        var record = try loadRecord(runID: runID)
        record.status = .inProgress
        record.updatedAt = Date()
        record.completedSamples = max(record.completedSamples, snapshot.completedSamples)
        record.lastVideoTimeSeconds = max(record.lastVideoTimeSeconds, snapshot.lastVideoTimeSeconds)
        record.lastCheckpointIndex = max(record.lastCheckpointIndex, snapshot.checkpointIndex)
        try writeJSON(record, to: stateURL(runID))
    }

    static func markPaused(runID: String) throws {
        var record = try loadRecord(runID: runID)
        record.status = .paused
        record.updatedAt = Date()
        if let latest = try loadCheckpointFiles(runID: runID).last {
            record.completedSamples = latest.completedSamples
            record.lastVideoTimeSeconds = latest.lastVideoTimeSeconds
            record.lastCheckpointIndex = latest.checkpointIndex
        }
        try writeJSON(record, to: stateURL(runID))
    }

    static func markInProgress(runID: String) throws {
        var record = try loadRecord(runID: runID)
        record.status = .inProgress
        record.updatedAt = Date()
        try writeJSON(record, to: stateURL(runID))
    }

    static func loadRecord(runID: String) throws -> FullAnalysisRecoveryRecord {
        try readJSON(FullAnalysisRecoveryRecord.self, from: stateURL(runID))
    }

    static func loadResumeSnapshot(runID: String) throws -> FullVideoAnalyzer.ResumeSnapshot? {
        let chunks = try loadCheckpointFiles(runID: runID)
        guard let latest = chunks.last else { return nil }
        var points: [TrackingPoint] = []
        points.reserveCapacity(latest.completedSamples)
        for chunk in chunks { points.append(contentsOf: chunk.points) }
        return FullVideoAnalyzer.ResumeSnapshot(
            existingPoints: points,
            nextTargetTimeSeconds: latest.nextTargetTimeSeconds,
            trackerState: latest.trackerState,
            nextCheckpointIndex: latest.checkpointIndex + 1
        )
    }

    static func latestRecoverable() -> FullAnalysisRecoveryRecord? {
        guard let root = try? activeRunsDirectory(),
              let children = try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return nil
        }
        let records = children.compactMap { folder -> FullAnalysisRecoveryRecord? in
            let state = folder.appendingPathComponent("run_state.json")
            guard let record = try? readJSON(FullAnalysisRecoveryRecord.self, from: state),
                  let source = try? sourceURL(for: record),
                  fm.fileExists(atPath: source.path) else { return nil }
            // Refresh displayed progress from the newest valid checkpoint, even when the app died
            // after the chunk write but before run_state.json was updated.
            if let chunks = try? loadCheckpointFiles(runID: record.runID), let latest = chunks.last {
                var refreshed = record
                refreshed.completedSamples = latest.completedSamples
                refreshed.lastVideoTimeSeconds = latest.lastVideoTimeSeconds
                refreshed.lastCheckpointIndex = latest.checkpointIndex
                refreshed.updatedAt = max(refreshed.updatedAt, latest.savedAt)
                return refreshed
            }
            return record
        }
        return records.max(by: { $0.updatedAt < $1.updatedAt })
    }

    static func deleteRun(runID: String, deleteSourceVideo: Bool) throws {
        let record = try? loadRecord(runID: runID)
        let folder = try runDirectory(runID)
        if fm.fileExists(atPath: folder.path) { try fm.removeItem(at: folder) }
        if deleteSourceVideo, let record, let source = try? sourceURL(for: record), fm.fileExists(atPath: source.path) {
            try? fm.removeItem(at: source)
        }
    }

    private static func loadCheckpointFiles(runID: String) throws -> [FullAnalysisCheckpointFile] {
        let dir = try checkpointsDirectory(runID)
        let urls = try fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            .filter { $0.lastPathComponent.hasPrefix("checkpoint_") && $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        var output: [FullAnalysisCheckpointFile] = []
        var expectedIndex = 1
        for url in urls {
            guard let checkpoint = try? readJSON(FullAnalysisCheckpointFile.self, from: url),
                  checkpoint.checkpointIndex == expectedIndex else {
                break
            }
            output.append(checkpoint)
            expectedIndex += 1
        }
        return output
    }

    private static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

    private static func readJSON<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: Data(contentsOf: url))
    }
}

// MARK: - App state

@MainActor
final class AppState: ObservableObject {
    enum Stage { case home, setup, preview }

    @Published var stage: Stage = .home
    @Published var isBusy = false
    @Published var errorMessage: String?
    @Published var fullAnalysisNotice: String?
    @Published var recoverableRun: FullAnalysisRecoveryRecord?

    @Published var videoURL: URL?
    @Published var originalVideoFilename = ""
    @Published var videoSource: VideoSource = .photos
    @Published var videoMetadata: VideoMetadata?
    @Published var importedAt = Date()

    @Published var mouseID = ""
    @Published var group = ""
    @Published var experimentDate = Date()
    @Published var experimentDateSource: ExperimentDateSource = .importTimeFallback

    @Published var arenaShape: ArenaShape = .rectangle
    @Published var arenaWidthCM: Double = 40
    @Published var arenaHeightCM: Double = 40
    @Published var mazeArmWidthCM: Double = 10
    @Published var tStartArmLengthCM: Double = 40
    @Published var tChoiceArmLengthCM: Double = 30
    @Published var yArmLengthCM: Double = 35
    @Published var calibration = ArenaCalibration()
    @Published var calibrationImage: UIImage?

    @Published var previewStartSeconds: Double = 0
    @Published var previewResult: TrackingPreviewResult?
    @Published var previewJSONURL: URL?
    @Published var previewAnalysisProgress: AnalysisProgressSnapshot = .zero

    @Published var fullAnalysisResult: FullAnalysisResult?
    @Published var fullTrackingJSONURL: URL?
    @Published var summaryJSONURL: URL?
    @Published var mazeEventsJSONURL: URL?
    @Published var isFullAnalysisRunning = false
    @Published var fullAnalysisProgress: AnalysisProgressSnapshot = .zero

    @Published var metadataJSONURL: URL?
    @Published var videoInfoJSONURL: URL?
    @Published var savedRunFolderURL: URL?

    // v1.1 — assay context and results library
    let library: ResultsLibrary
    @Published var assay: AssayKind = .openField
    @Published var phase = ""
    @Published var sex = ""
    @Published var day: Int?
    @Published var trial: Int?
    @Published var zoneConfig = ZoneConfig()
    @Published var plusArmLengthCM: Double = 30
    @Published var plusArmWidthCM: Double = 5
    @Published var latestResultID: UUID?

    // v1.2 — workflow navigation
    /// Setup fingerprint at the time the current preview was generated (nil = unknown).
    @Published var previewSetupSignature: Int?
    /// Result to open as soon as the preview screen is shown (step bar "Result").
    @Published var pendingResultPush: UUID?
    /// One-line notice for the start screen (e.g. after "Next animal").
    @Published var homeNotice: String?
    /// Arena, calibration and analysis settings of the last previewed video, offered for reuse
    /// when the next video of the same assay and resolution is set up.
    @Published private(set) var previousSetup: ReusableSetup?

    struct ReusableSetup: Equatable {
        var assay: AssayKind
        var pixelWidth: Double
        var pixelHeight: Double
        var arenaShape: ArenaShape
        var arenaWidthCM: Double
        var arenaHeightCM: Double
        var mazeArmWidthCM: Double
        var tStartArmLengthCM: Double
        var tChoiceArmLengthCM: Double
        var yArmLengthCM: Double
        var plusArmLengthCM: Double
        var plusArmWidthCM: Double
        var calibration: ArenaCalibration
        var zoneConfig: ZoneConfig
        var videoName: String
    }

    private var fullAnalysisTask: Task<Void, Never>?
    private var activeCheckpointSignal: FullVideoAnalyzer.CheckpointSignal?
    private var activeRecoveryRunID: String?
    private var lifecycleBackgroundTask: UIBackgroundTaskIdentifier = .invalid

    init() {
        library = ResultsLibrary()
        recoverableRun = FullAnalysisRecoveryStore.latestRecoverable()
    }

    /// Called when the user picks an assay: keeps the arena shape valid and resets assay defaults.
    func selectAssay(_ newAssay: AssayKind) {
        let changed = newAssay != assay
        assay = newAssay
        if let first = newAssay.videoArenaShapes.first, !newAssay.videoArenaShapes.contains(arenaShape) {
            arenaShape = first
        }
        if changed || (!newAssay.phases.isEmpty && !newAssay.phases.contains(phase)) {
            phase = newAssay.defaultPhase
        }
        if changed { resetZoneDefaults() }
    }

    func resetZoneDefaults() {
        zoneConfig = ZoneConfig.defaults(for: assay, shape: arenaShape, widthCM: effectiveArenaWidthCM, heightCM: effectiveArenaHeightCM)
    }

    var assayRunContext: AssayRunContext {
        AssayRunContext(assay: assay, phase: phase, sex: sex, day: day, trial: trial, zoneConfig: zoneConfig,
                        plusArmLengthCM: plusArmLengthCM, plusArmWidthCM: plusArmWidthCM)
    }

    private func restore(_ context: AssayRunContext) {
        assay = context.assay
        phase = context.phase
        sex = context.sex
        day = context.day
        trial = context.trial
        zoneConfig = context.zoneConfig
        plusArmLengthCM = context.plusArmLengthCM
        plusArmWidthCM = context.plusArmWidthCM
    }

    /// Builds the per-animal assay result from a finished full-video analysis.
    private func makeExperimentResult(from analysis: FullAnalysisResult, runFolder: URL) -> ExperimentResult {
        var config = zoneConfig
        config.arenaShape = arenaShape
        config.arenaWidthCM = effectiveArenaWidthCM
        config.arenaHeightCM = effectiveArenaHeightCM
        config.plusArmLengthCM = plusArmLengthCM
        config.plusArmWidthCM = plusArmWidthCM
        switch assay {
        case .novelObject:
            if let a = analysis.markersCM["A"] { config.objectA = a }
            if let b = analysis.markersCM["B"] { config.objectB = b }
        case .morrisWaterMaze, .barnesMaze:
            if let t = analysis.markersCM["T"] { config.target = t }
        default:
            break
        }
        var result = ExperimentResult(assay: assay, subjectID: mouseID, group: group, source: .video)
        result.sex = sex
        result.phase = phase
        result.day = day
        result.trial = trial
        result.experimentDate = experimentDate
        result.runFolderName = runFolder.lastPathComponent
        result.zoneConfig = config
        let samples = analysis.points.map {
            AnalysisSample(t: $0.videoTimeSeconds, x: $0.xCentimeters, y: $0.yCentimeters, detected: !$0.interpolated,
                           zone: $0.zone, motion: $0.motionIndex, blobArea: $0.blobAreaFraction)
        }
        result.apply(AssayEngine.compute(assay: assay, phase: phase, samples: samples, config: config))
        result.parameters["video"] = originalVideoFilename
        return result
    }

    var hasRecoverableRunForCurrentVideo: Bool {
        guard let videoURL, let recoverableRun,
              let source = try? FullAnalysisRecoveryStore.sourceURL(for: recoverableRun) else { return false }
        return source.standardizedFileURL == videoURL.standardizedFileURL
    }

    var effectiveArenaWidthCM: Double {
        switch arenaShape {
        case .rectangle: return arenaWidthCM
        case .circle: return arenaWidthCM
        case .tMaze: return 2 * tChoiceArmLengthCM + mazeArmWidthCM
        case .yMaze: return sqrt(3.0) * yArmLengthCM + mazeArmWidthCM
        case .plusMaze: return 2 * (plusArmLengthCM + plusArmWidthCM)
        }
    }

    var effectiveArenaHeightCM: Double {
        switch arenaShape {
        case .rectangle: return arenaHeightCM
        case .circle: return arenaWidthCM
        case .tMaze: return tStartArmLengthCM + mazeArmWidthCM
        case .yMaze: return 1.5 * yArmLengthCM + mazeArmWidthCM
        case .plusMaze: return 2 * (plusArmLengthCM + plusArmWidthCM)
        }
    }

    func importVideo(url: URL, source: VideoSource) async {
        guard !isFullAnalysisRunning else { return }
        isBusy = true
        errorMessage = nil
        fullAnalysisNotice = nil
        homeNotice = nil
        defer { isBusy = false }
        let previousVideoURL = videoURL

        do {
            originalVideoFilename = url.lastPathComponent
            // Copying a large video (Files, iCloud Drive, USB) can take seconds: never on the main thread.
            let localURL = try await Task.detached(priority: .userInitiated) {
                try AppState.copyIntoPersistentWorkingDirectory(url)
            }.value
            let metadata = try await VideoMetadataReader.read(url: localURL)
            let defaultStart = max(0, min(metadata.durationSeconds - 10, metadata.durationSeconds * 0.5 - 5))
            let image = try await FrameExtractor.singleFrame(url: localURL, at: defaultStart)

            videoURL = localURL
            if let previousVideoURL, previousVideoURL != localURL, !isVideoNeededByRecovery(previousVideoURL) {
                // The new video replaces the one that was still open (start screen keeps it until then).
                AppState.removeFileInBackground(previousVideoURL)
            }
            videoSource = source
            videoMetadata = metadata
            importedAt = Date()
            previewStartSeconds = defaultStart
            calibrationImage = image
            calibration = ArenaCalibration()
            clearAnalysisOutputs()
            if let first = assay.videoArenaShapes.first, !assay.videoArenaShapes.contains(arenaShape) {
                arenaShape = first
            }
            if !assay.phases.isEmpty && !assay.phases.contains(phase) { phase = assay.defaultPhase }
            let keptFear = (zoneConfig.csOnsetsSeconds, zoneConfig.csDurationSeconds, zoneConfig.baselineSeconds, zoneConfig.protocolOffsetSeconds)
            resetZoneDefaults()
            if assay == .fearConditioning {
                // Fear protocols are usually identical across animals — keep the timing.
                zoneConfig.csOnsetsSeconds = keptFear.0
                zoneConfig.csDurationSeconds = keptFear.1
                zoneConfig.baselineSeconds = keptFear.2
                zoneConfig.protocolOffsetSeconds = keptFear.3
            }

            if let creation = metadata.creationDate {
                experimentDate = creation
                experimentDateSource = .videoMetadata
            } else {
                experimentDate = importedAt
                experimentDateSource = .importTimeFallback
            }
            stage = .setup
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markExperimentDateEdited() { experimentDateSource = .userEntered }

    func randomizePreviewStart() async {
        guard let metadata = videoMetadata else { return }
        let maxStart = max(0, metadata.durationSeconds - 10)
        previewStartSeconds = maxStart > 0 ? Double.random(in: 0...maxStart) : 0
        await refreshCalibrationFrame()
    }

    func refreshCalibrationFrame() async {
        guard let videoURL else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            calibrationImage = try await FrameExtractor.singleFrame(url: videoURL, at: previewStartSeconds)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func generatePreview() async {
        guard let videoURL, let metadata = videoMetadata else { return }
        isBusy = true
        errorMessage = nil
        fullAnalysisNotice = nil
        previewAnalysisProgress = .zero
        defer { isBusy = false }

        do {
            let maxStart = max(0, metadata.durationSeconds - 10)
            previewStartSeconds = min(max(0, previewStartSeconds), maxStart)
            let previewDuration = min(10.0, max(0.5, metadata.durationSeconds - previewStartSeconds))

            let result = try await PreviewAnalyzer.analyze(
                videoURL: videoURL,
                startSeconds: previewStartSeconds,
                durationSeconds: previewDuration,
                arenaShape: arenaShape,
                arenaWidthCM: effectiveArenaWidthCM,
                arenaHeightCM: effectiveArenaHeightCM,
                calibration: calibration,
                mazeArmWidthCM: mazeArmWidthCM,
                tStartArmLengthCM: tStartArmLengthCM,
                tChoiceArmLengthCM: tChoiceArmLengthCM,
                yArmLengthCM: yArmLengthCM,
                plusArmLengthCM: plusArmLengthCM,
                plusArmWidthCM: plusArmWidthCM,
                progress: { [throttle = ProgressThrottle()] snapshot in
                    guard throttle.allow(snapshot) else { return }
                    Task { @MainActor [weak self] in self?.previewAnalysisProgress = snapshot }
                }
            )

            previewResult = result
            fullAnalysisResult = nil
            fullTrackingJSONURL = nil
            summaryJSONURL = nil
            mazeEventsJSONURL = nil
            savedRunFolderURL = nil
            fullAnalysisProgress = .zero

            previewJSONURL = try ExportService.makePreviewJSON(
                result: result,
                sourceNominalFPS: metadata.nominalFPS,
                mouseID: mouseID
            )
            metadataJSONURL = try ExportService.makeMetadataJSON(
                metadata: metadata,
                originalVideoFilename: originalVideoFilename,
                mouseID: mouseID,
                group: group,
                experimentDate: experimentDate,
                experimentDateSource: experimentDateSource,
                importedAt: importedAt,
                videoSource: videoSource,
                arenaShape: arenaShape,
                arenaWidthCM: effectiveArenaWidthCM,
                arenaHeightCM: effectiveArenaHeightCM,
                mazeArmWidthCM: mazeArmWidthCM,
                tStartArmLengthCM: tStartArmLengthCM,
                tChoiceArmLengthCM: tChoiceArmLengthCM,
                yArmLengthCM: yArmLengthCM,
                calibration: calibration,
                preview: result
            )
            videoInfoJSONURL = try ExportService.makeVideoInfoJSON(
                metadata: metadata,
                originalVideoFilename: originalVideoFilename,
                videoSource: videoSource,
                importedAt: importedAt,
                mouseID: mouseID,
                group: group,
                experimentDate: experimentDate,
                arenaShape: arenaShape
            )
            previewSetupSignature = setupSignature
            previousSetup = currentReusableSetup(metadata: metadata)
            stage = .preview
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func startFullVideoAnalysis() {
        startFullVideoAnalysis(resumingRunID: nil)
    }

    func resumeSavedFullAnalysis() {
        guard let record = recoverableRun else { return }
        Task { await resumeInterruptedAnalysis(record) }
    }

    func resumeInterruptedAnalysis(_ record: FullAnalysisRecoveryRecord? = nil) async {
        guard !isFullAnalysisRunning, let record = record ?? recoverableRun else { return }
        isBusy = true
        errorMessage = nil
        fullAnalysisNotice = nil
        homeNotice = nil
        defer { isBusy = false }
        let previousVideoURL = videoURL

        do {
            let source = try FullAnalysisRecoveryStore.sourceURL(for: record)
            guard FileManager.default.fileExists(atPath: source.path) else {
                throw RecoveryError.sourceVideoMissing
            }

            videoURL = source
            if let previousVideoURL, previousVideoURL.standardizedFileURL != source.standardizedFileURL,
               !isVideoNeededByRecovery(previousVideoURL) {
                // A different video was still open on the start screen; it is replaced now.
                AppState.removeFileInBackground(previousVideoURL)
            }
            originalVideoFilename = record.originalVideoFilename
            videoSource = record.videoSource
            videoMetadata = record.videoMetadata
            importedAt = record.importedAt
            mouseID = record.mouseID
            group = record.group
            experimentDate = record.experimentDate
            experimentDateSource = record.experimentDateSource
            arenaShape = record.arenaShape
            arenaWidthCM = record.arenaWidthCM
            arenaHeightCM = record.arenaHeightCM
            mazeArmWidthCM = record.mazeArmWidthCM
            tStartArmLengthCM = record.tStartArmLengthCM
            tChoiceArmLengthCM = record.tChoiceArmLengthCM
            yArmLengthCM = record.yArmLengthCM
            calibration = record.calibration
            previewStartSeconds = record.previewStartSeconds
            previewResult = record.previewResult
            if let context = record.assayContext {
                restore(context)
            } else {
                assay = record.arenaShape == .tMaze ? .tMaze : (record.arenaShape == .yMaze ? .yMaze : .openField)
                phase = ""
                resetZoneDefaults()
            }
            calibrationImage = try? await FrameExtractor.singleFrame(url: source, at: record.previewStartSeconds)

            previewJSONURL = try ExportService.makePreviewJSON(
                result: record.previewResult,
                sourceNominalFPS: record.videoMetadata.nominalFPS,
                mouseID: record.mouseID
            )
            metadataJSONURL = try ExportService.makeMetadataJSON(
                metadata: record.videoMetadata,
                originalVideoFilename: record.originalVideoFilename,
                mouseID: record.mouseID,
                group: record.group,
                experimentDate: record.experimentDate,
                experimentDateSource: record.experimentDateSource,
                importedAt: record.importedAt,
                videoSource: record.videoSource,
                arenaShape: record.arenaShape,
                arenaWidthCM: effectiveArenaWidthCM,
                arenaHeightCM: effectiveArenaHeightCM,
                mazeArmWidthCM: record.mazeArmWidthCM,
                tStartArmLengthCM: record.tStartArmLengthCM,
                tChoiceArmLengthCM: record.tChoiceArmLengthCM,
                yArmLengthCM: record.yArmLengthCM,
                calibration: record.calibration,
                preview: record.previewResult
            )
            videoInfoJSONURL = try ExportService.makeVideoInfoJSON(
                metadata: record.videoMetadata,
                originalVideoFilename: record.originalVideoFilename,
                videoSource: record.videoSource,
                importedAt: record.importedAt,
                mouseID: record.mouseID,
                group: record.group,
                experimentDate: record.experimentDate,
                arenaShape: record.arenaShape
            )

            let fraction = record.videoMetadata.durationSeconds > 0
                ? min(1, max(0, record.lastVideoTimeSeconds / record.videoMetadata.durationSeconds))
                : 0
            fullAnalysisProgress = AnalysisProgressSnapshot(
                fraction: fraction,
                processedSamples: record.completedSamples,
                estimatedTotalSamples: Int(ceil(record.videoMetadata.durationSeconds * FullVideoAnalyzer.analysisHz)),
                elapsedSeconds: 0,
                remainingSeconds: nil
            )
            previewSetupSignature = setupSignature
            stage = .preview
            startFullVideoAnalysis(resumingRunID: record.runID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func pauseFullVideoAnalysis() {
        guard isFullAnalysisRunning else { return }
        fullAnalysisNotice = loc("Saving checkpoint…")
        activeCheckpointSignal?.request()
        beginLifecycleBackgroundTaskIfNeeded()
        fullAnalysisTask?.cancel()
    }

    func handleAppEnteredBackground() {
        guard isFullAnalysisRunning else { return }
        // Pause rather than betting completed experiment data on background execution time.
        pauseFullVideoAnalysis()
    }

    func discardRecoverableRun() {
        guard let record = recoverableRun else { return }
        do {
            try FullAnalysisRecoveryStore.deleteRun(runID: record.runID, deleteSourceVideo: true)
            recoverableRun = FullAnalysisRecoveryStore.latestRecoverable()
            fullAnalysisNotice = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restartFullVideoAnalysisFromBeginning() {
        guard !isFullAnalysisRunning else { return }
        if let record = recoverableRun, hasRecoverableRunForCurrentVideo {
            try? FullAnalysisRecoveryStore.deleteRun(runID: record.runID, deleteSourceVideo: false)
            recoverableRun = FullAnalysisRecoveryStore.latestRecoverable()
        }
        fullAnalysisNotice = nil
        fullAnalysisProgress = .zero
        startFullVideoAnalysis(resumingRunID: nil)
    }

    private func startFullVideoAnalysis(resumingRunID: String?) {
        guard !isFullAnalysisRunning, fullAnalysisTask == nil else { return }
        fullAnalysisTask = Task { @MainActor [weak self] in
            await self?.runFullVideoAnalysis(resumingRunID: resumingRunID)
        }
    }

    private func runFullVideoAnalysis(resumingRunID: String?) async {
        guard let videoURL, let metadata = videoMetadata, let previewResult else {
            fullAnalysisTask = nil
            return
        }

        isFullAnalysisRunning = true
        if resumingRunID == nil { fullAnalysisProgress = .zero }
        errorMessage = nil
        fullAnalysisNotice = nil
        savedRunFolderURL = nil

        let checkpointSignal = FullVideoAnalyzer.CheckpointSignal()
        activeCheckpointSignal = checkpointSignal

        var runID = resumingRunID
        defer {
            isFullAnalysisRunning = false
            activeCheckpointSignal = nil
            activeRecoveryRunID = nil
            fullAnalysisTask = nil
            endLifecycleBackgroundTaskIfNeeded()
        }

        do {
            // Recovery bookkeeping copies the source video and reads checkpoints: off the main thread.
            if let existingRunID = runID {
                try await Task.detached(priority: .userInitiated) {
                    try FullAnalysisRecoveryStore.markInProgress(runID: existingRunID)
                }.value
            } else {
                let source = videoURL, name = originalVideoFilename, from = videoSource, imported = importedAt
                let id = mouseID, grp = group, date = experimentDate, dateSource = experimentDateSource
                let shape = arenaShape, width = arenaWidthCM, height = arenaHeightCM, armWidth = mazeArmWidthCM
                let tStart = tStartArmLengthCM, tChoice = tChoiceArmLengthCM, yArm = yArmLengthCM
                let cal = calibration, start = previewStartSeconds, preview = previewResult, context = assayRunContext
                let record = try await Task.detached(priority: .userInitiated) {
                    try FullAnalysisRecoveryStore.create(
                        sourceVideoURL: source,
                        originalVideoFilename: name,
                        videoSource: from,
                        videoMetadata: metadata,
                        importedAt: imported,
                        mouseID: id,
                        group: grp,
                        experimentDate: date,
                        experimentDateSource: dateSource,
                        arenaShape: shape,
                        arenaWidthCM: width,
                        arenaHeightCM: height,
                        mazeArmWidthCM: armWidth,
                        tStartArmLengthCM: tStart,
                        tChoiceArmLengthCM: tChoice,
                        yArmLengthCM: yArm,
                        calibration: cal,
                        previewStartSeconds: start,
                        previewResult: preview,
                        assayContext: context
                    )
                }.value
                runID = record.runID
                recoverableRun = record
            }

            guard let runID else { throw RecoveryError.couldNotCreateRun }
            activeRecoveryRunID = runID
            let resume = try await Task.detached(priority: .userInitiated) {
                try FullAnalysisRecoveryStore.loadResumeSnapshot(runID: runID)
            }.value

            let result = try await FullVideoAnalyzer.analyze(
                videoURL: videoURL,
                arenaShape: arenaShape,
                arenaWidthCM: effectiveArenaWidthCM,
                arenaHeightCM: effectiveArenaHeightCM,
                calibration: calibration,
                mazeArmWidthCM: mazeArmWidthCM,
                tStartArmLengthCM: tStartArmLengthCM,
                tChoiceArmLengthCM: tChoiceArmLengthCM,
                yArmLengthCM: yArmLengthCM,
                plusArmLengthCM: plusArmLengthCM,
                plusArmWidthCM: plusArmWidthCM,
                resume: resume,
                checkpointSignal: checkpointSignal,
                checkpointEverySamples: FullVideoAnalyzer.defaultCheckpointSamples,
                checkpoint: { snapshot in
                    try FullAnalysisRecoveryStore.saveCheckpoint(runID: runID, snapshot: snapshot)
                },
                progress: { [throttle = ProgressThrottle()] snapshot in
                    guard throttle.allow(snapshot) else { return }
                    Task { @MainActor [weak self] in self?.fullAnalysisProgress = snapshot }
                }
            )

            // Writing the JSON outputs (the full tracking file can be several MB) and archiving the
            // run folder happen off the main thread; only the finished URLs come back.
            guard let previewJSONURL else { throw ArchiveError.missingOutput }
            let id = mouseID, grp = group, date = experimentDate, dateSource = experimentDateSource
            let imported = importedAt, from = videoSource, name = originalVideoFilename
            let shape = arenaShape, width = effectiveArenaWidthCM, height = effectiveArenaHeightCM
            let armWidth = mazeArmWidthCM, tStart = tStartArmLengthCM, tChoice = tChoiceArmLengthCM, yArm = yArmLengthCM
            let cal = calibration, currentAssay = assay
            let outputs = try await Task.detached(priority: .userInitiated) { () throws -> ArchivedOutputs in
                let fullTracking = try ExportService.makeFullTrackingJSON(
                    result: result,
                    sourceNominalFPS: metadata.nominalFPS,
                    mouseID: id
                )
                let summary = try ExportService.makeSummaryJSON(
                    result: result,
                    mouseID: id,
                    group: grp,
                    experimentDate: date,
                    experimentDateSource: dateSource,
                    videoCreationDate: metadata.creationDate,
                    importedAt: imported,
                    videoSource: from,
                    arenaShape: shape,
                    arenaWidthCM: width,
                    arenaHeightCM: height
                )
                let mazeEvents = shape.isMaze
                    ? try ExportService.makeMazeEventsJSON(result: result, arenaShape: shape, mouseID: id)
                    : nil
                let metadataJSON = try ExportService.makeMetadataJSON(
                    metadata: metadata,
                    originalVideoFilename: name,
                    mouseID: id,
                    group: grp,
                    experimentDate: date,
                    experimentDateSource: dateSource,
                    importedAt: imported,
                    videoSource: from,
                    arenaShape: shape,
                    arenaWidthCM: width,
                    arenaHeightCM: height,
                    mazeArmWidthCM: armWidth,
                    tStartArmLengthCM: tStart,
                    tChoiceArmLengthCM: tChoice,
                    yArmLengthCM: yArm,
                    calibration: cal,
                    preview: previewResult,
                    fullAnalysis: result,
                    assay: currentAssay
                )
                let videoInfo = try ExportService.makeVideoInfoJSON(
                    metadata: metadata,
                    originalVideoFilename: name,
                    videoSource: from,
                    importedAt: imported,
                    mouseID: id,
                    group: grp,
                    experimentDate: date,
                    arenaShape: shape
                )
                let folder = try ExperimentArchiveService.ensureFolder(
                    existing: nil,
                    mouseID: id,
                    experimentDate: date,
                    arenaShape: shape
                )
                try ExperimentArchiveService.savePreview(
                    folder: folder,
                    previewJSONURL: previewJSONURL,
                    metadataJSONURL: metadataJSON,
                    videoInfoJSONURL: videoInfo
                )
                try ExperimentArchiveService.saveFull(
                    folder: folder,
                    fullTrackingJSONURL: fullTracking,
                    summaryJSONURL: summary,
                    metadataJSONURL: metadataJSON,
                    videoInfoJSONURL: videoInfo,
                    mazeEventsJSONURL: mazeEvents
                )
                return ArchivedOutputs(fullTracking: fullTracking, summary: summary, mazeEvents: mazeEvents,
                                       metadata: metadataJSON, videoInfo: videoInfo, folder: folder)
            }.value

            fullAnalysisResult = result
            fullTrackingJSONURL = outputs.fullTracking
            summaryJSONURL = outputs.summary
            mazeEventsJSONURL = outputs.mazeEvents
            metadataJSONURL = outputs.metadata
            videoInfoJSONURL = outputs.videoInfo
            let folder = outputs.folder
            savedRunFolderURL = folder

            // v1.1: turn the tracking into the assay's per-animal result and store it in the library.
            let experiment = makeExperimentResult(from: result, runFolder: folder)
            if library.save(experiment) {
                latestResultID = experiment.id
            } else {
                errorMessage = library.lastError ?? loc("The assay result could not be saved.")
            }

            // Recovery data is deleted only after every final output has been archived successfully.
            recoverableRun = try await Task.detached(priority: .utility) {
                try FullAnalysisRecoveryStore.deleteRun(runID: runID, deleteSourceVideo: false)
                return FullAnalysisRecoveryStore.latestRecoverable()
            }.value
            fullAnalysisNotice = loc("Analysis complete. Recovery checkpoints were cleaned up.")
        } catch is CancellationError {
            if let runID {
                try? FullAnalysisRecoveryStore.markPaused(runID: runID)
                recoverableRun = FullAnalysisRecoveryStore.latestRecoverable()
            }
            fullAnalysisNotice = loc("Analysis paused. Progress was saved and can be resumed.")
        } catch {
            if let runID {
                try? FullAnalysisRecoveryStore.markPaused(runID: runID)
                recoverableRun = FullAnalysisRecoveryStore.latestRecoverable()
            }
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Workflow navigation (v1.2)

    /// A video is open (imported and readable), independent of the screen shown.
    var hasActiveVideo: Bool { videoURL != nil && videoMetadata != nil }

    /// Fingerprint of everything the tracking depends on. Assay markers (objects, platform,
    /// target hole) are left out: they only change the computed results, not the tracking.
    var setupSignature: Int {
        var hasher = Hasher()
        var trackingCalibration = calibration
        trackingCalibration.markerA = .markerA
        trackingCalibration.markerB = .markerB
        trackingCalibration.markerTarget = .markerTarget
        hasher.combine(trackingCalibration)
        hasher.combine(arenaShape)
        for value in [arenaWidthCM, arenaHeightCM, mazeArmWidthCM, tStartArmLengthCM, tChoiceArmLengthCM,
                      yArmLengthCM, plusArmLengthCM, plusArmWidthCM, previewStartSeconds] {
            hasher.combine(value)
        }
        return hasher.finalize()
    }

    /// The preview (and any full analysis) was made with a different setup than the current one.
    var isPreviewStale: Bool { previewResult != nil && previewSetupSignature != setupSignature }

    var workflowStep: WorkflowStep {
        switch stage {
        case .home: return .start
        case .setup: return .setup
        case .preview: return .preview
        }
    }

    var latestResultExists: Bool {
        guard let id = latestResultID else { return false }
        return library.result(id: id) != nil
    }

    func isStepAvailable(_ step: WorkflowStep) -> Bool {
        // Importing a video or making the preview finishes on its own screen; don't leave mid-way.
        if isBusy { return false }
        switch step {
        case .start: return true
        // Setup is locked while the full analysis runs: the result is built from it at the end.
        case .setup: return hasActiveVideo && !isFullAnalysisRunning
        case .preview: return hasActiveVideo && previewResult != nil
        case .result: return hasActiveVideo && latestResultExists
        }
    }

    func isStepDone(_ step: WorkflowStep) -> Bool {
        switch step {
        case .start: return hasActiveVideo
        case .setup: return previewResult != nil
        case .preview: return fullAnalysisResult != nil
        case .result: return false
        }
    }

    func go(to step: WorkflowStep) {
        guard isStepAvailable(step) else { return }
        switch step {
        case .start: stage = .home
        case .setup: stage = .setup
        case .preview: stage = .preview
        case .result:
            pendingResultPush = latestResultID
            stage = .preview
        }
    }

    /// Short status of the open video for the start screen.
    var workflowStatusText: String {
        if isFullAnalysisRunning { return locf("Analyzing %.0f%%", fullAnalysisProgress.fraction * 100) }
        if latestResultExists { return loc("Result saved") }
        if fullAnalysisResult != nil { return loc("Analyzed") }
        if previewResult != nil { return isPreviewStale ? loc("Setup changed") : loc("Preview ready") }
        return loc("Setting up")
    }

    /// Furthest screen worth returning to from the start screen.
    var continueStep: WorkflowStep {
        if isStepAvailable(.preview) { return .preview }
        return .setup
    }

    private func currentReusableSetup(metadata: VideoMetadata) -> ReusableSetup {
        ReusableSetup(
            assay: assay, pixelWidth: metadata.pixelWidth, pixelHeight: metadata.pixelHeight,
            arenaShape: arenaShape, arenaWidthCM: arenaWidthCM, arenaHeightCM: arenaHeightCM,
            mazeArmWidthCM: mazeArmWidthCM, tStartArmLengthCM: tStartArmLengthCM, tChoiceArmLengthCM: tChoiceArmLengthCM,
            yArmLengthCM: yArmLengthCM, plusArmLengthCM: plusArmLengthCM, plusArmWidthCM: plusArmWidthCM,
            calibration: calibration, zoneConfig: zoneConfig,
            videoName: mouseID.isEmpty ? originalVideoFilename : mouseID
        )
    }

    /// The previous video's setup can be applied to the current one (same assay and frame size)
    /// and differs from what is set now.
    var canReusePreviousSetup: Bool {
        guard let previous = previousSetup, let metadata = videoMetadata, previewResult == nil else { return false }
        guard previous.assay == assay,
              previous.pixelWidth == metadata.pixelWidth,
              previous.pixelHeight == metadata.pixelHeight else { return false }
        return previous != currentReusableSetup(metadata: metadata).withVideoName(previous.videoName)
    }

    func reusePreviousSetup() {
        guard let p = previousSetup else { return }
        arenaShape = p.arenaShape
        arenaWidthCM = p.arenaWidthCM
        arenaHeightCM = p.arenaHeightCM
        mazeArmWidthCM = p.mazeArmWidthCM
        tStartArmLengthCM = p.tStartArmLengthCM
        tChoiceArmLengthCM = p.tChoiceArmLengthCM
        yArmLengthCM = p.yArmLengthCM
        plusArmLengthCM = p.plusArmLengthCM
        plusArmWidthCM = p.plusArmWidthCM
        calibration = p.calibration
        zoneConfig = p.zoneConfig
    }

    /// Clears the current video and returns to the start screen. Group, sex, assay, phase and day
    /// are kept, and the previous setup is offered for reuse, so a batch can be scored quickly.
    func startNextAnimal() {
        guard !isFullAnalysisRunning else { return }
        let keptGroup = group
        let keptAssay = assay
        reset()
        homeNotice = keptGroup.isEmpty
            ? locf("Ready for the next animal (%@). Choose the next video — on the setup screen you can reuse the previous calibration and settings.", keptAssay.displayName)
            : locf("Ready for the next animal (%@, group %@). Choose the next video — on the setup screen you can reuse the previous calibration and settings.", keptAssay.displayName, keptGroup)
    }

    func reset() {
        guard !isFullAnalysisRunning else { return }
        let oldVideoURL = videoURL
        stage = .home
        videoURL = nil
        videoMetadata = nil
        calibrationImage = nil
        originalVideoFilename = ""
        mouseID = ""
        trial = nil
        latestResultID = nil
        // Group, sex, assay, phase and day are kept: batches are usually scored animal after animal.
        errorMessage = nil
        fullAnalysisNotice = nil
        clearAnalysisOutputs()
        if let oldVideoURL, !isVideoNeededByRecovery(oldVideoURL) {
            AppState.removeFileInBackground(oldVideoURL)
        }
        recoverableRun = FullAnalysisRecoveryStore.latestRecoverable()
    }

    /// Deleting a multi-GB video can take a moment; it never needs to block the screen.
    nonisolated static func removeFileInBackground(_ url: URL) {
        Task.detached(priority: .utility) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func clearAnalysisOutputs() {
        previewResult = nil
        previewJSONURL = nil
        previewAnalysisProgress = .zero
        fullAnalysisResult = nil
        fullTrackingJSONURL = nil
        summaryJSONURL = nil
        mazeEventsJSONURL = nil
        metadataJSONURL = nil
        videoInfoJSONURL = nil
        fullAnalysisProgress = .zero
        savedRunFolderURL = nil
        isFullAnalysisRunning = false
        latestResultID = nil
        previewSetupSignature = nil
        pendingResultPush = nil
    }

    nonisolated private static func copyIntoPersistentWorkingDirectory(_ sourceURL: URL) throws -> URL {
        let needsSecurityScope = sourceURL.startAccessingSecurityScopedResource()
        defer { if needsSecurityScope { sourceURL.stopAccessingSecurityScopedResource() } }

        let ext = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension
        var destination = try FullAnalysisRecoveryStore.importedVideosDirectory()
            .appendingPathComponent("RodentFlow-selected-\(UUID().uuidString)")
            .appendingPathExtension(ext)
        if FileManager.default.fileExists(atPath: destination.path) { try FileManager.default.removeItem(at: destination) }
        // Videos picked from Photos already arrive as a private copy in the app's temporary folder:
        // move that copy instead of duplicating gigabytes of data.
        let temporaryRoot = FileManager.default.temporaryDirectory.standardizedFileURL.path
        if sourceURL.standardizedFileURL.path.hasPrefix(temporaryRoot),
           (try? FileManager.default.moveItem(at: sourceURL, to: destination)) != nil {
            // moved
        } else {
            try FileManager.default.copyItem(at: sourceURL, to: destination)
        }
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try? destination.setResourceValues(resourceValues)
        return destination
    }

    private func isVideoNeededByRecovery(_ url: URL) -> Bool {
        guard let recoverableRun,
              let source = try? FullAnalysisRecoveryStore.sourceURL(for: recoverableRun) else { return false }
        return source.standardizedFileURL == url.standardizedFileURL
    }

    private func beginLifecycleBackgroundTaskIfNeeded() {
        guard lifecycleBackgroundTask == .invalid else { return }
        lifecycleBackgroundTask = UIApplication.shared.beginBackgroundTask(withName: "Save tracking checkpoint") { [weak self] in
            Task { @MainActor in
                self?.fullAnalysisTask?.cancel()
                self?.endLifecycleBackgroundTaskIfNeeded()
            }
        }
    }

    private func endLifecycleBackgroundTaskIfNeeded() {
        guard lifecycleBackgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(lifecycleBackgroundTask)
        lifecycleBackgroundTask = .invalid
    }

    enum ArchiveError: LocalizedError {
        case missingOutput
        var errorDescription: String? { loc("The analysis finished, but one or more JSON output files could not be prepared.") }
    }

    enum RecoveryError: LocalizedError {
        case sourceVideoMissing
        case couldNotCreateRun

        var errorDescription: String? {
            switch self {
            case .sourceVideoMissing: return loc("The saved source video for this interrupted analysis is no longer available.")
            case .couldNotCreateRun: return loc("The app could not create a recoverable analysis session.")
            }
        }
    }
}

extension AppState.ReusableSetup {
    func withVideoName(_ name: String) -> AppState.ReusableSetup {
        var copy = self
        copy.videoName = name
        return copy
    }
}

/// Files written at the end of a full analysis (produced off the main thread).
struct ArchivedOutputs {
    let fullTracking: URL
    let summary: URL
    let mazeEvents: URL?
    let metadata: URL
    let videoInfo: URL
    let folder: URL
}

/// Limits progress updates from the analyzers to a few per second. Every update redraws the
/// screen; the analyzers report far more often than anyone can see.
final class ProgressThrottle: @unchecked Sendable {
    private let lock = NSLock()
    private var lastEmit: TimeInterval = 0
    private let interval: TimeInterval

    init(interval: TimeInterval = 0.2) {
        self.interval = interval
    }

    func allow(_ snapshot: AnalysisProgressSnapshot) -> Bool {
        let now = ProcessInfo.processInfo.systemUptime
        lock.lock()
        defer { lock.unlock() }
        if snapshot.fraction >= 0.999 || now - lastEmit >= interval {
            lastEmit = now
            return true
        }
        return false
    }
}
