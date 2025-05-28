//
//  CustomVideoPlayer.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

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
            
            // Update coordinator with new player item if changed
            if let newItem = player.currentItem,
               context.coordinator.currentItem !== newItem {
                context.coordinator.observeBuffering(for: newItem)
            }
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
        weak var currentItem: AVPlayerItem?
        var isBuffering: Binding<Bool> = .constant(false)

        private var bufferEmptyObservation: NSKeyValueObservation?
        private var likelyToKeepUpObservation: NSKeyValueObservation?
        private var rateObservation: NSKeyValueObservation?
        private var timeControlStatusObservation: NSKeyValueObservation?

        func observeBuffering(for item: AVPlayerItem) {
            // Clean up previous observers
            cleanUpObservers()
            currentItem = item
            
            // Observe buffer empty state
            bufferEmptyObservation = item.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] item, _ in
                DispatchQueue.main.async {
                    self?.updateBufferingState()
                }
            }

            // Observe likely to keep up state
            likelyToKeepUpObservation = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
                DispatchQueue.main.async {
                    self?.updateBufferingState()
                }
            }
            
            // Observe player rate changes
            rateObservation = player?.observe(\.rate, options: [.new]) { [weak self] player, _ in
                DispatchQueue.main.async {
                    self?.updateBufferingState()
                }
            }
            
            // Observe time control status (iOS 10+)
            timeControlStatusObservation = player?.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
                DispatchQueue.main.async {
                    self?.updateBufferingState()
                }
            }

            // Handle video end - loop the video
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerDidFinishPlaying),
                name: .AVPlayerItemDidPlayToEndTime,
                object: item
            )
            
            // Initial state update
            DispatchQueue.main.async {
                self.updateBufferingState()
            }
        }
        
        private func updateBufferingState() {
            guard let player = player, let item = currentItem else {
                isBuffering.wrappedValue = false
                return
            }
            
            // Determine if we should show buffering indicator
            let shouldShowBuffering: Bool
            
            switch player.timeControlStatus {
            case .playing:
                // Video is playing smoothly - never show buffering
                shouldShowBuffering = false
                
            case .paused:
                // Video is paused - only show buffering if buffer is empty and we're trying to play
                // (This handles the case where user manually paused vs system paused for buffering)
                shouldShowBuffering = item.isPlaybackBufferEmpty && !item.isPlaybackLikelyToKeepUp
                
            case .waitingToPlayAtSpecifiedRate:
                // Video is trying to play but waiting - show buffering
                shouldShowBuffering = true
                
            @unknown default:
                shouldShowBuffering = item.isPlaybackBufferEmpty && !item.isPlaybackLikelyToKeepUp
            }
            
            // Only update if state actually changed to avoid unnecessary UI updates
            if isBuffering.wrappedValue != shouldShowBuffering {
                isBuffering.wrappedValue = shouldShowBuffering
                
                // Debug logging
                if CacheConfiguration.enableLogging {
                    let status = player.timeControlStatus
                    let rate = player.rate
                    let bufferEmpty = item.isPlaybackBufferEmpty
                    let likelyToKeepUp = item.isPlaybackLikelyToKeepUp
                    
                    print("📺 BUFFERING: \(shouldShowBuffering ? "SHOW" : "HIDE") - Status: \(status.rawValue), Rate: \(rate), BufferEmpty: \(bufferEmpty), KeepUp: \(likelyToKeepUp)")
                }
            }
            
            // Auto-resume playback when buffer is ready
            if player.timeControlStatus == .waitingToPlayAtSpecifiedRate &&
               item.isPlaybackLikelyToKeepUp &&
               player.rate == 0 {
                player.play()
            }
        }
        
        @objc func playerDidFinishPlaying() {
            player?.seek(to: .zero)
            player?.play()
        }

        func cleanUpObservers() {
            bufferEmptyObservation?.invalidate()
            likelyToKeepUpObservation?.invalidate()
            rateObservation?.invalidate()
            timeControlStatusObservation?.invalidate()
            
            bufferEmptyObservation = nil
            likelyToKeepUpObservation = nil
            rateObservation = nil
            timeControlStatusObservation = nil
            
            NotificationCenter.default.removeObserver(self)
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
