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
    @IBOutlet weak var enableAudioFilter: UISwitch!
    
    

    private let webRTCClient: WebRTCClient
    private var signalClient: SignalingClient?

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
            enableAudioFilter.isOn = isApplyAudioFilter
        }
    }

    required init?(coder: NSCoder) {
        let defaultWebRtcIceServers = [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302",
            "stun:stun2.l.google.com:19302",
            "stun:stun3.l.google.com:19302",
            "stun:stun4.l.google.com:19302"
        ]
        self.webRTCClient = WebRTCClient(iceServers: defaultWebRtcIceServers)
        super.init(coder: coder)
    }
    
    func setupSignalClient(serverUrl: URL) {
        // Use the entered IP address if needed to configure the signaling client
        let webSocketClient = WebSocketClient(url: serverUrl)
        self.signalClient = SignalingClient(webSocket: webSocketClient)
        self.signalClient?.delegate = self
        self.signalClient?.connect()

    }
    
    func loadIpAddressAndPort() -> (ipAddress: String?, port: String?) {
        let ipAddress = UserDefaults.standard.string(forKey: "ipAddress") ?? "192.168.1.1"
        let port = UserDefaults.standard.string(forKey: "port") ?? "8080"
        return (ipAddress, port)
    }
    
    func saveIpAddressAndPort(ipAddress: String, port: String) {
        UserDefaults.standard.set(ipAddress, forKey: "ipAddress")
        UserDefaults.standard.set(port, forKey: "port")
    }
    
    func popUpIpAddressInput() {
        let alertController = UIAlertController(title: "Enter IP Address",
            message: "Please enter the IP address to connect to",
            preferredStyle: .alert)
 
        let (ipAddress, port) = loadIpAddressAndPort()
        
        alertController.addTextField { textField in
            textField.placeholder = "IP Address"
            textField.text = ipAddress
            textField.keyboardType = .decimalPad
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Port"
            textField.text = port
            textField.keyboardType = .numberPad
        }
        
        let connectAction = UIAlertAction(title: "Connect", style: .default) { [weak self, weak alertController] _ in
            guard let textFields = alertController?.textFields, textFields.count == 2,
                  let ipAddress = textFields[0].text, !ipAddress.isEmpty,
                  let port = textFields[1].text, !port.isEmpty,
                  Int(port) != nil else {
                return
            }
            let ipAddressAndPort: String = "ws://\(ipAddress):\(port)"
            guard let serverUrl: URL = URL(string: ipAddressAndPort) else {
                debugPrint("Invalid URL " + ipAddressAndPort)
                return
            }
            self!.saveIpAddressAndPort(ipAddress: ipAddress, port: port)
            self!.setupSignalClient(serverUrl: serverUrl)
        }

        alertController.addAction(connectAction)
        present(alertController, animated: true)
        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.popUpIpAddressInput()

        self.webRTCClient.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTitle.text = "WebRTC Integration Sample"
        self.webRTCStatusLabel.text = "New"
        
        self.isSignalingConnected = false

        self.hasLocalSdp = false
        self.localCandidateCount = 0
        self.remoteCandidateCount = 0
        
        self.isSpeakerEnabled = true
        self.isMicrophoneEnabled = true
        self.isApplyAudioFilter = true

    }
    
    @IBAction func sendOfferButtonHandler(_ sender: Any) {
        self.webRTCClient.sendOfferMessage { (sdp) in
            self.hasLocalSdp = true
            self.signalClient?.send(sdp: sdp)
        }
    }
    
    @IBAction func sendAnswerButtonHandler(_ sender: Any) {
        self.webRTCClient.sendAnswerMessage { (localSdp) in
            self.hasLocalSdp = true
            self.signalClient?.send(sdp: localSdp)
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
    
    @IBAction func audioFilterTapHandler(_ sender: UISwitch) {
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
        self.signalClient?.send(candidate: candidate)
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

