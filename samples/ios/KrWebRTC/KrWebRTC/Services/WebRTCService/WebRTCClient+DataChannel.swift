//
//  WebRTCClient+DataChannel.swift
//  KrWebRTC
//
//  Created by Arthur Hayrapetyan on 20.02.23.
//

import Foundation
import WebRTC

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("WebRTCClient: dataChannel did change state: \(dataChannel.readyState)")
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
}
