import Foundation

struct Configuration {

    struct serverURL {
        static let defaultIceServers = ["stun:stun.l.google.com:19302",
                                             "stun:stun1.l.google.com:19302",
                                             "stun:stun2.l.google.com:19302",
                                             "stun:stun3.l.google.com:19302",
                                             "stun:stun4.l.google.com:19302"]
    }

    struct ServerConfig {
        let webRTCIceServers: [String]
    }
    
    static let serverConfig = ServerConfig(
        webRTCIceServers: serverURL.defaultIceServers)
}
