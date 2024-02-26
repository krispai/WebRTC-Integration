//
//  WebSocketClient.swift
//  WebRTC-Sample-iOS
//
//  Created by Arthur Hayrapetyan on 09.02.23.
//

import Foundation
import Starscream

class WebSocketClient: WebSocketProvider {

    var delegate: WebSocketProviderDelegate?
    private let socket: WebSocket
    
    init(url: URL) {
        self.socket = WebSocket(request: URLRequest(url: url))
        self.socket.delegate = self
    }

    func connect() {
        self.socket.connect()
    }
    
    func send(data: Data) {
        self.socket.write(data: data)
    }
}

extension WebSocketClient: Starscream.WebSocketDelegate {
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected:
            self.delegate?.webSocketDidConnect(self)
        case .disconnected:
            self.delegate?.webSocketDidDisconnect(self)
        case .error(let error):
            if let error = error {
                debugPrint("WebSocket encountered an error: \(error)")
            } else {
                debugPrint("WebSocket encountered an unknown error")
            }
            self.delegate?.webSocketDidDisconnect(self)
            break
        case .peerClosed:
            debugPrint("Server connection is closed. Something is wrong.")
            self.delegate?.webSocketDidDisconnect(self)
            break
        case .text:
            debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
        case .binary(let data):
            self.delegate?.webSocket(self, didReceiveData: data)
        default:
            break
        }
    }
}
