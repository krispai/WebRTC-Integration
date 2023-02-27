//
//  ViewController.swift
//  KrWebRTC
//
//  Created by Arthur Hayrapetyan on 19.01.23.
//

import UIKit
import AVFoundation
import WebRTC

final class ViewController: UIViewController {

    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var signalingStatus: UILabel!

    @IBOutlet weak var localSDPImageView: UIImageView!
    @IBOutlet weak var localCandidatesCountLabel: UILabel!

    @IBOutlet weak var remoteSDPImageView: UIImageView!
    @IBOutlet weak var remoteCandidatesCountLabel: UILabel!

    @IBOutlet weak var webRTCStatusLabel: UILabel!
    
    @IBOutlet weak var speakerEnable: UISwitch!
    @IBOutlet weak var microphoneEnable: UISwitch!
    @IBOutlet weak var enableSDKFilter: UISwitch!

    private let signalClient: SignalingClient
    private let webRTCClient: WebRTCClient
    
    private var isSignalingConnected: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isSignalingConnected {
                    self.signalingStatus?.text = "Connected"
                    self.signalingStatus?.textColor = UIColor.systemGreen
                }
                else {
                    self.signalingStatus?.text = "Not connected"
                    self.signalingStatus?.textColor = UIColor.red
                }
            }
        }
    }

    private var hasLocalSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.localSDPImageView.image = self.hasLocalSdp ? UIImage(named: "greencheckmark") : UIImage(named: "redcheckmark")
            }
        }
    }
    
    private var localCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.localCandidatesCountLabel.text = "\(self.localCandidateCount)"
            }
        }
    }
    
    private var hasRemoteSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.remoteSDPImageView.image = self.hasRemoteSdp ? UIImage(named: "greencheckmark") : UIImage(named: "redcheckmark")
            }
        }
    }
    
    private var remoteCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.remoteCandidatesCountLabel.text = "\(self.remoteCandidateCount)"
            }
        }
    }
    
    private var isSpeakerEnabled: Bool = false {
        didSet {
            speakerEnable.isOn = isSpeakerEnabled
        }
    }
    
    private var isMicrophoneEnabled: Bool = false {
        didSet {
            microphoneEnable.isOn = isMicrophoneEnabled
        }
    }

    private var isApplyAudioFilter: Bool = false {
        didSet {
            enableSDKFilter.isOn = isApplyAudioFilter
        }
    }
    
    init(signalClient: SignalingClient, webRTCClient: WebRTCClient) {
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
        super.init(nibName: String(describing: ViewController.self), bundle: Bundle.main)
    }

    @available(*, unavailable, renamed: "init(product:coder:)")
       required init?(coder: NSCoder) {
           let config = Configuration.serverConfig
           self.webRTCClient = WebRTCClient(iceServers: config.webRTCIceServers)
           self.signalClient = SignalingClient(webSocket: WebSocketClient(url: config.signalingServerUrl))
           super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTitle.text = "Krisp SDK via WebRTC"
        self.webRTCStatusLabel.text = "New"
        
        self.isSignalingConnected = false

        self.hasLocalSdp = false
        self.localCandidateCount = 0
        self.remoteCandidateCount = 0
        
        self.isSpeakerEnabled = true
        self.isMicrophoneEnabled = true
        self.isApplyAudioFilter = true
        
        self.signalClient.delegate = self
        self.signalClient.connect()
        self.webRTCClient.delegate = self
    }
    
    @IBAction func sendOfferButtonHandler(_ sender: Any) {
        self.webRTCClient.sendOfferMessage { (sdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: sdp)
        }
    }
    
    @IBAction func sendAnswerButtonHandler(_ sender: Any) {
        self.webRTCClient.sendAnswerMessage { (localSdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: localSdp)
        }
    }
    
    @IBAction func speakerTapHandler(_ sender: UISwitch) {
        self.isSpeakerEnabled = sender.isOn
        if self.isSpeakerEnabled {
            self.webRTCClient.speakerOn()
        }
        else {
            self.webRTCClient.speakerOff()
        }
    }
    
    @IBAction func microphoneTapHandler(_ sender: UISwitch) {
        self.isMicrophoneEnabled = sender.isOn
        if self.isMicrophoneEnabled {
            self.webRTCClient.unmuteMicrophone()
        }
        else {
            self.webRTCClient.muteMicrophone()
        }
    }
    
    @IBAction func krispSDKTapHandler(_ sender: UISwitch) {
        self.isApplyAudioFilter = sender.isOn
        self.webRTCClient.enableAudioFilter(enable: self.isApplyAudioFilter)
    }
}

extension ViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.isSignalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.isSignalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        self.webRTCClient.updateSdpMessage(remoteSdp: sdp) { (error) in
            self.hasRemoteSdp = true
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        self.webRTCClient.addIceCandidateMessage(remoteCandidate: candidate) { error in
            self.remoteCandidateCount += 1
        }
    }
}

extension ViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        let textColor: UIColor
        switch state {
        case .connected, .completed:
            textColor = UIColor.systemGreen
        case .disconnected, .failed, .closed:
            textColor = .red
        case .new, .checking, .count:
            textColor = .black
        @unknown default:
            textColor = .black
        }
        DispatchQueue.main.async {
            self.webRTCStatusLabel?.text = state.description.capitalized
            self.webRTCStatusLabel?.textColor = textColor
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

