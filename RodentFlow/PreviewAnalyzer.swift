import Foundation

struct PreviewAnalyzer {
    static func analyze(
        videoURL: URL,
        startSeconds: Double,
        durationSeconds: Double = 10,
        arenaShape: ArenaShape,
        arenaWidthCM: Double,
        arenaHeightCM: Double,
        calibration: ArenaCalibration,
        mazeArmWidthCM: Double,
        tStartArmLengthCM: Double,
        tChoiceArmLengthCM: Double,
        yArmLengthCM: Double,
        plusArmLengthCM: Double = 30,
        plusArmWidthCM: Double = 5,
        progress: @escaping @Sendable (AnalysisProgressSnapshot) -> Void = { _ in }
    ) async throws -> TrackingPreviewResult {
        let output = try await FullVideoAnalyzer.analyzeRange(
            videoURL: videoURL,
            startSeconds: startSeconds,
            durationSeconds: durationSeconds,
            arenaShape: arenaShape,
            arenaWidthCM: arenaWidthCM,
            arenaHeightCM: arenaHeightCM,
            calibration: calibration,
            mazeArmWidthCM: mazeArmWidthCM,
            tStartArmLengthCM: tStartArmLengthCM,
            tChoiceArmLengthCM: tChoiceArmLengthCM,
            yArmLengthCM: yArmLengthCM,
            plusArmLengthCM: plusArmLengthCM,
            plusArmWidthCM: plusArmWidthCM,
            progress: progress
        )
        return TrackingPreviewResult(
            startSeconds: output.startSeconds,
            durationSeconds: output.durationSeconds,
            processingFPS: output.analysisHz,
            points: output.points
        )
    }
}
