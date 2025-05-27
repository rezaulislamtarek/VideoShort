//
//  CustomVideoPlayer.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

import SwiftUI
import AVFoundation

struct CustomVideoPlayer: UIViewRepresentable {
    var player: AVPlayer
    @Binding var isBuffering: Bool

    func makeUIView(context: Context) -> UIView {
        let view = PlayerView()
        view.playerLayer.player = player

        context.coordinator.isBuffering = $isBuffering
        context.coordinator.player = player

        if let item = player.currentItem {
            context.coordinator.observeBuffering(for: item)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let view = uiView as? PlayerView {
            view.playerLayer.player = player
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.cleanUpObservers()
    }

    class Coordinator: NSObject {
        weak var player: AVPlayer?
        var isBuffering: Binding<Bool> = .constant(false)

        private var bufferEmptyObservation: NSKeyValueObservation?
        private var likelyToKeepUpObservation: NSKeyValueObservation?

        func observeBuffering(for item: AVPlayerItem) {
            bufferEmptyObservation = item.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] item, _ in
                self?.isBuffering.wrappedValue = item.isPlaybackBufferEmpty || !item.isPlaybackLikelyToKeepUp || self?.player?.rate == 0
            }

            likelyToKeepUpObservation = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
                    guard let self = self, let player = self.player else { return }

                    if item.isPlaybackLikelyToKeepUp {
                        self.isBuffering.wrappedValue = false

                        // Force play if paused
                        if player.rate == 0 {
                            player.play()
                        }
                    } else {
                        self.isBuffering.wrappedValue = true
                    }
                }

                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(playerDidFinishPlaying),
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: item
                )
        }
        
        @objc func playerDidFinishPlaying() {
            player?.seek(to: .zero)
            player?.play()
        }

        func cleanUpObservers() {
            bufferEmptyObservation?.invalidate()
            likelyToKeepUpObservation?.invalidate()
            bufferEmptyObservation = nil
            likelyToKeepUpObservation = nil
        }
    }

    class PlayerView: UIView {
        override static var layerClass: AnyClass {
            AVPlayerLayer.self
        }

        var playerLayer: AVPlayerLayer {
            return layer as! AVPlayerLayer
        }
    }
}
