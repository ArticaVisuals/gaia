import AVFoundation
import AVKit
import SwiftUI

struct SplashScreenView: View {
    @State private var opacity: Double = 1
    @State private var isFinished = false

    var onDismiss: () -> Void

    var body: some View {
        if !isFinished {
            ZStack {
                GaiaColor.splashBackground
                SplashPlayerView(onVideoEnded: handleVideoEnded)
            }
                .ignoresSafeArea()
                .opacity(opacity)
                .animation(.easeInOut(duration: 0.6), value: opacity)
        }
    }

    private func handleVideoEnded() {
        // Hold on the last frame briefly, then fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isFinished = true
            onDismiss()
        }
    }
}

// MARK: - AVPlayer wrapper

private struct SplashPlayerView: UIViewControllerRepresentable {
    let onVideoEnded: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onVideoEnded: onVideoEnded)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.view.backgroundColor = UIColor(GaiaColor.splashBackground)
        controller.updatesNowPlayingInfoCenter = false

        context.coordinator.configure(controller: controller)

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        coordinator.teardown(controller: uiViewController)
    }

    final class Coordinator: NSObject {
        private let onVideoEnded: () -> Void
        private var player: AVPlayer?
        private weak var observedItem: AVPlayerItem?
        private var hasFinished = false
        private var setupTask: Task<Void, Never>?

        init(onVideoEnded: @escaping () -> Void) {
            self.onVideoEnded = onVideoEnded
            super.init()
        }

        deinit {
            setupTask?.cancel()
            removeObserver()
        }

        func configure(controller: AVPlayerViewController) {
            guard player == nil, setupTask == nil else { return }

            guard let url = Bundle.main.url(forResource: "GaiaSplashScreen", withExtension: "mp4") else {
                finishPlayback()
                return
            }

            setupTask = Task { @MainActor [weak self, weak controller] in
                guard let self else { return }

                defer { self.setupTask = nil }

                let player = await self.makePlayer(url: url)
                guard !Task.isCancelled else { return }

                guard let controller else { return }

                self.removeObserver()
                self.observedItem = player.currentItem
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.handlePlayerDidFinish),
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: player.currentItem
                )

                controller.player = player
                self.player = player
                player.play()
            }
        }

        func teardown(controller: AVPlayerViewController) {
            setupTask?.cancel()
            setupTask = nil
            player?.pause()
            controller.player = nil
            player = nil
            removeObserver()
        }

        private func finishPlayback() {
            guard !hasFinished else { return }
            hasFinished = true
            onVideoEnded()
        }

        @MainActor
        private func makePlayer(url: URL) async -> AVPlayer {
            let player: AVPlayer

            if let silentItem = await makeSilentPlayerItem(url: url) {
                player = AVPlayer(playerItem: silentItem)
            } else {
                player = AVPlayer(url: url)
                disableAudioTracks(for: player.currentItem)
            }

            player.actionAtItemEnd = .pause // Freeze on the last frame.
            player.isMuted = true
            player.volume = 0
            player.allowsExternalPlayback = false

            return player
        }

        @MainActor
        private func makeSilentPlayerItem(url: URL) async -> AVPlayerItem? {
            let asset = AVURLAsset(url: url)

            do {
                let videoTracks = try await asset.loadTracks(withMediaType: .video)
                guard let videoTrack = videoTracks.first else { return nil }

                let duration = try await asset.load(.duration)
                let preferredTransform = try await videoTrack.load(.preferredTransform)

                let composition = AVMutableComposition()

                guard let compositionTrack = composition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                ) else {
                    return nil
                }

                try compositionTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: duration),
                    of: videoTrack,
                    at: .zero
                )
                compositionTrack.preferredTransform = preferredTransform
                return AVPlayerItem(asset: composition)
            } catch {
                return nil
            }
        }

        private func disableAudioTracks(for item: AVPlayerItem?) {
            item?.tracks
                .filter { $0.assetTrack?.mediaType == .audio }
                .forEach { $0.isEnabled = false }
        }

        @objc private func handlePlayerDidFinish() {
            DispatchQueue.main.async { [weak self] in
                self?.finishPlayback()
            }
        }

        private func removeObserver() {
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: observedItem
            )
            observedItem = nil
        }
    }
}
