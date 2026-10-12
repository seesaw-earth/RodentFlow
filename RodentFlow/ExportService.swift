import Foundation

struct ExportService {
    static let trackingVersion = "classic_centroid_v0.1_10hz_smoothing_90_10"
    static let analysisHz = 10.0

    private struct TrackingSampleJSON: Codable {
        let sampleIndex: Int
        let clipTimeSeconds: Double
        let videoTimeSeconds: Double
        let imageXNormalized: Double
        let imageYNormalized: Double
        let arenaXNormalized: Double
        let arenaYNormalized: Double
        let xCentimeters: Double
        let yCentimeters: Double
        let speedCentimetersPerSecond: Double
        let confidence: Double
        let interpolated: Bool
        let zone: String
        let motionIndex: Double?
        let blobAreaFraction: Double?
    }

    private struct TrackingFileJSON: Codable {
        let schemaVersion: String
        let kind: String
        let trackingVersion: String
        let analysisHz: Double
        let sourceNominalFPS: Double
        let startSeconds: Double
        let durationSeconds: Double
        let sampleCount: Int
        let samples: [TrackingSampleJSON]
    }

    private struct SummaryJSON: Codable {
        let schemaVersion: String
        let mouseID: String
        let group: String
        let experimentDate: Date
        let experimentDateSource: String
        let videoCreationDate: Date?
        let importedAt: Date
        let videoSource: String
        let arenaShape: String
        let arenaWidthCM: Double
        let arenaHeightCM: Double
        let trackingVersion: String
        let analysisHz: Double
        let durationSeconds: Double
        let sampleCount: Int
        let trackedPercent: Double
        let meanConfidence: Double
        let distanceCentimeters: Double
        let meanSpeedCentimetersPerSecond: Double
        let armEntryCount: Int
        let armEntrySequence: [String]
        let tMazeFirstChoice: String?
        let yMazeAlternationPercent: Double?
    }

    private struct MazeEventsJSON: Codable {
        let schemaVersion: String
        let arenaShape: String
        let entryRule: String
        let eventCount: Int
        let armEntrySequence: [String]
        let tMazeFirstChoice: String?
        let yMazeAlternationPercent: Double?
        let events: [MazeEvent]
    }

    private struct VideoInfoJSON: Codable {
        let schemaVersion: String
        let originalFilename: String
        let source: String
        let durationSeconds: Double
        let widthPixels: Double
        let heightPixels: Double
        let nominalFPS: Double
        let creationDate: Date?
        let importedAt: Date
        let mouseID: String
        let group: String
        let experimentDate: Date
        let arenaShape: String
    }

    static func makePreviewJSON(
        result: TrackingPreviewResult,
        sourceNominalFPS: Double,
        mouseID: String
    ) throws -> URL {
        let payload = TrackingFileJSON(
            schemaVersion: "1.0",
            kind: "preview_tracking",
            trackingVersion: trackingVersion,
            analysisHz: result.processingFPS,
            sourceNominalFPS: sourceNominalFPS,
            startSeconds: result.startSeconds,
            durationSeconds: result.durationSeconds,
            sampleCount: result.points.count,
            samples: trackingSamples(result.points)
        )
        return try writeJSON(payload, to: tempURL(mouseID: mouseID, suffix: "preview_tracking"))
    }

    static func makeFullTrackingJSON(
        result: FullAnalysisResult,
        sourceNominalFPS: Double,
        mouseID: String
    ) throws -> URL {
        let start = result.points.first?.videoTimeSeconds ?? 0
        let payload = TrackingFileJSON(
            schemaVersion: "1.0",
            kind: "full_tracking",
            trackingVersion: trackingVersion,
            analysisHz: result.processingFPS,
            sourceNominalFPS: sourceNominalFPS,
            startSeconds: start,
            durationSeconds: result.durationSeconds,
            sampleCount: result.points.count,
            samples: trackingSamples(result.points)
        )
        return try writeJSON(payload, to: tempURL(mouseID: mouseID, suffix: "full_tracking"))
    }

    static func makeSummaryJSON(
        result: FullAnalysisResult,
        mouseID: String,
        group: String,
        experimentDate: Date,
        experimentDateSource: ExperimentDateSource,
        videoCreationDate: Date?,
        importedAt: Date,
        videoSource: VideoSource,
        arenaShape: ArenaShape,
        arenaWidthCM: Double,
        arenaHeightCM: Double
    ) throws -> URL {
        let payload = SummaryJSON(
            schemaVersion: "1.0",
            mouseID: mouseID,
            group: group,
            experimentDate: experimentDate,
            experimentDateSource: experimentDateSource.rawValue,
            videoCreationDate: videoCreationDate,
            importedAt: importedAt,
            videoSource: videoSource.rawValue,
            arenaShape: arenaShape.rawValue,
            arenaWidthCM: arenaWidthCM,
            arenaHeightCM: arenaHeightCM,
            trackingVersion: trackingVersion,
            analysisHz: result.processingFPS,
            durationSeconds: result.durationSeconds,
            sampleCount: result.points.count,
            trackedPercent: result.trackedFraction * 100,
            meanConfidence: result.meanConfidence,
            distanceCentimeters: result.distanceCentimeters,
            meanSpeedCentimetersPerSecond: result.meanSpeedCentimetersPerSecond,
            armEntryCount: result.mazeEvents.count,
            armEntrySequence: result.armEntrySequence,
            tMazeFirstChoice: result.tMazeFirstChoice,
            yMazeAlternationPercent: result.yMazeAlternationPercent
        )
        return try writeJSON(payload, to: tempURL(mouseID: mouseID, suffix: "summary"))
    }

    static func makeMazeEventsJSON(
        result: FullAnalysisResult,
        arenaShape: ArenaShape,
        mouseID: String
    ) throws -> URL {
        let payload = MazeEventsJSON(
            schemaVersion: "1.0",
            arenaShape: arenaShape.rawValue,
            entryRule: "zone_must_remain_stable_for_at_least_0.25_seconds",
            eventCount: result.mazeEvents.count,
            armEntrySequence: result.armEntrySequence,
            tMazeFirstChoice: result.tMazeFirstChoice,
            yMazeAlternationPercent: result.yMazeAlternationPercent,
            events: result.mazeEvents
        )
        return try writeJSON(payload, to: tempURL(mouseID: mouseID, suffix: "maze_events"))
    }

    static func makeMetadataJSON(
        metadata: VideoMetadata,
        originalVideoFilename: String,
        mouseID: String,
        group: String,
        experimentDate: Date,
        experimentDateSource: ExperimentDateSource,
        importedAt: Date,
        videoSource: VideoSource,
        arenaShape: ArenaShape,
        arenaWidthCM: Double,
        arenaHeightCM: Double,
        mazeArmWidthCM: Double,
        tStartArmLengthCM: Double,
        tChoiceArmLengthCM: Double,
        yArmLengthCM: Double,
        calibration: ArenaCalibration,
        preview: TrackingPreviewResult,
        fullAnalysis: FullAnalysisResult? = nil,
        assay: AssayKind? = nil
    ) throws -> URL {
        struct Payload: Codable {
            let schemaVersion: String
            let assay: String?
            let motionIndexVersion: String
            let mouseID: String
            let group: String
            let experimentDate: Date
            let experimentDateSource: String
            let videoCreationDate: Date?
            let importedAt: Date
            let videoSource: String
            let originalVideoFilename: String
            let arenaShape: String
            let durationSeconds: Double
            let widthPixels: Double
            let heightPixels: Double
            let sourceNominalFPS: Double
            let arenaWidthCM: Double
            let arenaHeightCM: Double
            let mazeArmWidthCM: Double
            let tStartArmLengthCM: Double
            let tChoiceArmLengthCM: Double
            let yArmLengthCM: Double
            let calibration: ArenaCalibration
            let previewStartSeconds: Double
            let previewDurationSeconds: Double
            let previewAnalysisHz: Double
            let fullAnalysisHz: Double?
            let fullAnalysisSamples: Int?
            let trackingVersion: String
            let positionDefinition: String
            let smoothing: String
            let samplingPolicy: String
            let mazeEntryRule: String
        }

        let payload = Payload(
            schemaVersion: "1.1",
            assay: assay?.rawValue,
            motionIndexVersion: NativeMouseTracker.motionIndexVersion,
            mouseID: mouseID,
            group: group,
            experimentDate: experimentDate,
            experimentDateSource: experimentDateSource.rawValue,
            videoCreationDate: metadata.creationDate,
            importedAt: importedAt,
            videoSource: videoSource.rawValue,
            originalVideoFilename: originalVideoFilename,
            arenaShape: arenaShape.rawValue,
            durationSeconds: metadata.durationSeconds,
            widthPixels: metadata.pixelWidth,
            heightPixels: metadata.pixelHeight,
            sourceNominalFPS: metadata.nominalFPS,
            arenaWidthCM: arenaWidthCM,
            arenaHeightCM: arenaHeightCM,
            mazeArmWidthCM: mazeArmWidthCM,
            tStartArmLengthCM: tStartArmLengthCM,
            tChoiceArmLengthCM: tChoiceArmLengthCM,
            yArmLengthCM: yArmLengthCM,
            calibration: calibration,
            previewStartSeconds: preview.startSeconds,
            previewDurationSeconds: preview.durationSeconds,
            previewAnalysisHz: preview.processingFPS,
            fullAnalysisHz: fullAnalysis?.processingFPS,
            fullAnalysisSamples: fullAnalysis?.points.count,
            trackingVersion: trackingVersion,
            positionDefinition: "centroid_of_selected_foreground_component",
            smoothing: "90_percent_current_detection_plus_10_percent_previous_position",
            samplingPolicy: "10_hz_using_original_video_presentation_timestamps",
            mazeEntryRule: "zone_must_remain_stable_for_at_least_0.25_seconds"
        )
        return try writeJSON(payload, to: tempURL(mouseID: mouseID, suffix: "metadata"))
    }

    static func makeVideoInfoJSON(
        metadata: VideoMetadata,
        originalVideoFilename: String,
        videoSource: VideoSource,
        importedAt: Date,
        mouseID: String,
        group: String,
        experimentDate: Date,
        arenaShape: ArenaShape
    ) throws -> URL {
        let payload = VideoInfoJSON(
            schemaVersion: "1.0",
            originalFilename: originalVideoFilename,
            source: videoSource.rawValue,
            durationSeconds: metadata.durationSeconds,
            widthPixels: metadata.pixelWidth,
            heightPixels: metadata.pixelHeight,
            nominalFPS: metadata.nominalFPS,
            creationDate: metadata.creationDate,
            importedAt: importedAt,
            mouseID: mouseID,
            group: group,
            experimentDate: experimentDate,
            arenaShape: arenaShape.rawValue
        )
        return try writeJSON(payload, to: tempURL(mouseID: mouseID, suffix: "video_info"))
    }

    private static func trackingSamples(_ points: [TrackingPoint]) -> [TrackingSampleJSON] {
        points.indices.map { index in
            let point = points[index]
            let speed: Double
            if index > 0 {
                let previous = points[index - 1]
                let dt = point.videoTimeSeconds - previous.videoTimeSeconds
                if dt > 0, !point.interpolated, !previous.interpolated {
                    speed = hypot(point.xCentimeters - previous.xCentimeters, point.yCentimeters - previous.yCentimeters) / dt
                } else {
                    speed = 0
                }
            } else {
                speed = 0
            }
            return TrackingSampleJSON(
                sampleIndex: point.frameIndex,
                clipTimeSeconds: point.clipTimeSeconds,
                videoTimeSeconds: point.videoTimeSeconds,
                imageXNormalized: point.imageXNormalized,
                imageYNormalized: point.imageYNormalized,
                arenaXNormalized: point.arenaXNormalized,
                arenaYNormalized: point.arenaYNormalized,
                xCentimeters: point.xCentimeters,
                yCentimeters: point.yCentimeters,
                speedCentimetersPerSecond: speed,
                confidence: point.confidence,
                interpolated: point.interpolated,
                zone: point.zone,
                motionIndex: point.motionIndex,
                blobAreaFraction: point.blobAreaFraction
            )
        }
    }

    private static func tempURL(mouseID: String, suffix: String) -> URL {
        let cleanMouse = mouseID.isEmpty ? "mouse" : sanitizeFilename(mouseID)
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("RodentFlow_\(cleanMouse)_\(suffix)")
            .appendingPathExtension("json")
    }

    @discardableResult
    private static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
        return url
    }

    static func sanitizeFilename(_ value: String) -> String {
        let cleaned = value.replacingOccurrences(of: "[^A-Za-z0-9_-]", with: "_", options: .regularExpression)
        return cleaned.isEmpty ? "mouse" : cleaned
    }
}

struct ExperimentArchiveService {
    static func ensureFolder(
        existing: URL?,
        mouseID: String,
        experimentDate: Date,
        arenaShape: ArenaShape
    ) throws -> URL {
        if let existing { return existing }

        let fm = FileManager.default
        let documents = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let root = documents
            .appendingPathComponent("Experiments", isDirectory: true)
        try fm.createDirectory(at: root, withIntermediateDirectories: true)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let stamp = formatter.string(from: experimentDate)
        let mouse = ExportService.sanitizeFilename(mouseID)
        let runName = "\(stamp)_\(mouse)_\(arenaShape.rawValue)_\(UUID().uuidString.prefix(6))"
        let folder = root.appendingPathComponent(runName, isDirectory: true)
        try fm.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    static func savePreview(
        folder: URL,
        previewJSONURL: URL,
        metadataJSONURL: URL,
        videoInfoJSONURL: URL
    ) throws {
        try copy(previewJSONURL, to: folder.appendingPathComponent("preview_tracking.json"))
        try copy(metadataJSONURL, to: folder.appendingPathComponent("metadata.json"))
        try copy(videoInfoJSONURL, to: folder.appendingPathComponent("video_info.json"))
    }

    static func saveFull(
        folder: URL,
        fullTrackingJSONURL: URL,
        summaryJSONURL: URL,
        metadataJSONURL: URL,
        videoInfoJSONURL: URL,
        mazeEventsJSONURL: URL?
    ) throws {
        try copy(fullTrackingJSONURL, to: folder.appendingPathComponent("full_tracking.json"))
        try copy(summaryJSONURL, to: folder.appendingPathComponent("summary.json"))
        try copy(metadataJSONURL, to: folder.appendingPathComponent("metadata.json"))
        try copy(videoInfoJSONURL, to: folder.appendingPathComponent("video_info.json"))
        if let mazeEventsJSONURL {
            try copy(mazeEventsJSONURL, to: folder.appendingPathComponent("maze_events.json"))
        }
    }

    private static func copy(_ source: URL, to destination: URL) throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: destination.path) { try fm.removeItem(at: destination) }
        try fm.copyItem(at: source, to: destination)
    }
}
