//
//  WebRTCClient+AudioControl.swift
//  WebRTC-Sample-Krisp-IOS
//
//  Created by Arthur Hayrapetyan on 20.02.23.
//

import Foundation
import WebRTC

extension WebRTCClient {
    
    private func setAudioEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled)
    }
    
    /// Microphone parts
    func muteMicrophone() {
        self.setAudioEnabled(false)
    }
    
    func unmuteMicrophone() {
        self.setAudioEnabled(true)
    }
    
    /// Speaker parts
    func speakerOn() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let error {
                debugPrint("WebRTCClient: Failed to turn on speaker, error: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }

    func speakerOff() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
            } catch let error {
                debugPrint("WebRTCClient: Failed to turn on speaker, error: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
}
