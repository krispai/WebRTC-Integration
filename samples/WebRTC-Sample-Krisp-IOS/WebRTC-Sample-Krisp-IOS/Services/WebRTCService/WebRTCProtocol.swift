//
//  WebRTCProtocol.swift
//  WebRTC-Sample-Krisp-IOS
//
//  Created by Arthur Hayrapetyan on 20.02.23.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}
