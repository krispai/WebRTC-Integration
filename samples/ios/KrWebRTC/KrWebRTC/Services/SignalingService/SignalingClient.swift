//
//  SignalingClient.swift
//  KrWebRTC
//
//  Created by Arthur Hayrapetyan on 13.02.23.
//

import Foundation
import WebRTC

final class SignalingClient {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private let webSocket: WebSocketProvider
    
    weak var delegate: SignalClientDelegate?
    
    init(webSocket: WebSocketProvider) {
        self.webSocket = webSocket
    }
    
    func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect()
    }
    
    func send(sdp rtcSdp: RTCSessionDescription) {
        let message = Message.sdp(SessionDescription(from: rtcSdp))
        do {
            let dataMessage = try self.encoder.encode(message)
            
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("SignalingClient: Failed to encode sdp message: \(error)")
        }
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate) {
        let message = Message.candidate(IceCandidate(from: rtcIceCandidate))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("SignalingClient: Failed to encode candidate message: \(error)")
        }
    }
}

extension SignalingClient: WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidDisconnect(self)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("SignalingClient: Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        let message: Message
        do {
            message = try self.decoder.decode(Message.self, from: data)
        }
        catch {
            debugPrint("SignalingClient: Fialed to decode received message: \(error)")
            return
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
        }
    }
}
