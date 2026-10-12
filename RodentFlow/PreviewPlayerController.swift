import Foundation
import Combine
import AVFoundation

final class PreviewPlayerController: ObservableObject {
    let player: AVPlayer
    let startSeconds: Double
    let endSeconds: Double

    @Published var relativeTime: Double = 0
    private var timeObserver: Any?

    /// Loads the asset asynchronously before creating the player, so first access to its
    /// properties does not block the main thread.
    @MainActor
    static func make(url: URL, startSeconds: Double, durationSeconds: Double) async -> PreviewPlayerController {
        let asset = AVURLAsset(url: url)
        _ = try? await asset.load(.isPlayable, .duration)
        return PreviewPlayerController(asset: asset, startSeconds: startSeconds, durationSeconds: durationSeconds)
    }

    convenience init(url: URL, startSeconds: Double, durationSeconds: Double) {
        self.init(asset: AVURLAsset(url: url), startSeconds: startSeconds, durationSeconds: durationSeconds)
    }

    init(asset: AVAsset, startSeconds: Double, durationSeconds: Double) {
        self.startSeconds = startSeconds
        self.endSeconds = startSeconds + durationSeconds
        self.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))

        let start = CMTime(seconds: startSeconds, preferredTimescale: 600)
        player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero)

        // 15 Hz is plenty for a 10 Hz tracking overlay and halves the redraws of 30 Hz.
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(value: 1, timescale: 15),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            let seconds = time.seconds
            self.relativeTime = max(0, seconds - self.startSeconds)
            if seconds >= self.endSeconds {
                let restart = CMTime(seconds: self.startSeconds, preferredTimescale: 600)
                self.player.seek(to: restart, toleranceBefore: .zero, toleranceAfter: .zero)
                self.relativeTime = 0
                self.player.play()
            }
        }
    }

    func play() { player.play() }
    func pause() { player.pause() }

    func restart() {
        let start = CMTime(seconds: startSeconds, preferredTimescale: 600)
        player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero)
        relativeTime = 0
        player.play()
    }

    deinit {
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
        }
    }
}
