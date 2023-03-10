//
//  Configuration.swift
//  WebRTC-Sample-iOS
//
//  Created by Arthur Hayrapetyan on 13.02.23.
//

import Foundation

struct Configuration {

    struct serverURL {
        static var defaultSignalingServerUrl = URL(string: "ws://192.168.10.30:8080")!
        static let defaultIceServers = ["stun:stun.l.google.com:19302",
                                             "stun:stun1.l.google.com:19302",
                                             "stun:stun2.l.google.com:19302",
                                             "stun:stun3.l.google.com:19302",
                                             "stun:stun4.l.google.com:19302"]
    }

    struct ServerConfig {
        let signalingServerUrl: URL
        let webRTCIceServers: [String]
    }
    
    static let serverConfig = ServerConfig(signalingServerUrl: serverURL.defaultSignalingServerUrl, webRTCIceServers: serverURL.defaultIceServers)
}

