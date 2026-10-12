import Foundation
import AVFoundation

struct VideoMetadataReader {
    static func read(url: URL) async throws -> VideoMetadata {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        let tracks = try await asset.loadTracks(withMediaType: .video)

        guard let track = tracks.first else {
            throw VideoReadError.noVideoTrack
        }

        let naturalSize = try await track.load(.naturalSize)
        let transform = try await track.load(.preferredTransform)
        let frameRate = try await track.load(.nominalFrameRate)
        let transformedSize = naturalSize.applying(transform)

        let width = abs(transformedSize.width)
        let height = abs(transformedSize.height)

        var creationDate: Date?
        let commonMetadata = try await asset.load(.commonMetadata)
        let creationItems = AVMetadataItem.metadataItems(
            from: commonMetadata,
            filteredByIdentifier: .commonIdentifierCreationDate
        )
        if let item = creationItems.first {
            creationDate = try? await item.load(.dateValue)
        }

        return VideoMetadata(
            durationSeconds: max(0, duration.seconds),
            pixelWidth: Double(width),
            pixelHeight: Double(height),
            nominalFPS: Double(frameRate),
            creationDate: creationDate
        )
    }

    enum VideoReadError: LocalizedError {
        case noVideoTrack

        var errorDescription: String? {
            switch self {
            case .noVideoTrack: return loc("The selected file does not contain a readable video track.")
            }
        }
    }
}
