//
//  webRTCClient.swift
//  rtc_demo
//
//  Created by apple on 2021/11/29.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}

final class WebRTCClient: NSObject {
    
    /// 工厂类
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    /// 代理
    weak var delegate: WebRTCClientDelegate?
    /// PC
    private let peerConnection: RTCPeerConnection
    /// 音频
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    /// 视频
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    private var videoCapturer: RTCVideoCapturer?
    /// 本地视频流
    private var localVideoTrack: RTCVideoTrack?
    /// 远程视频流
    private var remoteVideoTrack: RTCVideoTrack?
    /// 本地数据通道
    private var localDataChannel: RTCDataChannel?
    /// 远程数据通道
    private var remoteDataChannel: RTCDataChannel?
    ///用户id
    var uid: Int
    ///key
    var longKey: Int
    ///是否开启加密
    private var isDecryptor: Bool?
    //音频通道
    var reSender :RTCRtpSender?
    var reReciver :RTCRtpReceiver?
    
    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    /// 初始化状态
    /// - Parameters:
    ///   - iceServers: turn/stun服务器
    ///   - uid: uid
    required init(iceServers: [String], uid: Int) {
        
        self.uid = uid
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: iceServers, username: "im", credential: "123456")]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        
        let peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: nil)
        self.peerConnection = peerConnection
        
        longKey = Int(newAesManager(0,"12345678901234567890123456789012"))
        
        super.init()
        self.createMediaSenders()
        self.configureAudioSession()
        self.peerConnection.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotifitionClicks), name: Notification.Name("btnDeTapClick"), object: nil)
    }
    
    @objc func onNotifitionClicks(notifi : Notification) {

        let tap = notifi.userInfo!["bool"]
        self.isDecryptor = (tap as! Bool)
//        self.setAudioEnabled(self.isDecryptor!)
        
        
        if self.reSender != nil {
            for rtcSen in self.peerConnection.senders {
                //音频进行加密
                if  self.isDecryptor ==  true {
                    WrapperOc.rtcSenderEncryptor(rtcSen, crypto: longKey)
                }else{
                    WrapperOc.rtcSenderEncryptor(rtcSen, crypto: 0)
                }
            }
        }
        
        if self.reReciver != nil {
            for rtc in self.peerConnection.receivers {
                ///音频进行解密
                if rtc.track?.kind == "audio" &&  self.isDecryptor == true {
                    WrapperOc.rtcReceiverDecryptor(rtc, crypto: longKey)
                }else{
                    WrapperOc.rtcReceiverDecryptor(rtc, crypto: 0)
                }
            }
            
        }
   }
    
    
    /// 设置音视频加密
    /// - Parameter decrypory: 是否启动加密
    func setAudioCryptor(decrypory: Bool) {

    }
    
    
    // MARK: 信令相关
    /// 创建offer
    /// - Parameter completion: 回调
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                             optionalConstraints: nil)
        self.peerConnection.offer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    /// 创建answer
    /// - Parameter completion: 回调
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void)  {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                             optionalConstraints: nil)
        self.peerConnection.answer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                return
            }
            
            self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    /// 设置SDP
    /// - Parameters:
    ///   - remoteSdp: SDP
    ///   - completion: 回调
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> ()) {
        self.peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    /// 设置candidate
    /// - Parameters:
    ///   - remoteCandidate: candidate
    ///   - completion: 回调
    func set(remoteCandidate: RTCIceCandidate, completion: @escaping (Error?) -> ()) {
        self.peerConnection.add(remoteCandidate)
    }
    
    // MARK: 媒体相关
    
    /// 设置约束
    /// - Parameter 渲染:
    func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
            return
        }

        guard
            let frontCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .front }),
        
            // choose highest res
            let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted { (f1, f2) -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                return width1 < width2
            }).last,
        
            // choose highest fps
            let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last) else {
            return
        }

        capturer.startCapture(with: frontCamera,
                              format: format,
                              fps: Int(fps.maxFrameRate))
        
        self.localVideoTrack?.add(renderer)
    }
    
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        
        self.remoteVideoTrack?.add(renderer)
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            Logger.info("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = self.createAudioTrack()
        self.reSender = self.peerConnection.add(audioTrack, streamIds: [streamId])
        
        // Video
        let videoTrack = self.createVideoTrack()
        self.localVideoTrack = videoTrack
        self.peerConnection.add(videoTrack, streamIds: [streamId])
        
        self.remoteVideoTrack = self.peerConnection.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
        
        // Data
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio\(String(describing: self.uid))")
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCClient.factory.videoSource()
        
        #if targetEnvironment(simulator)
        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
        
        let videoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: "video\(String(describing: self.uid))")
        return videoTrack
    }
    
    // MARK: Data Channels
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = self.peerConnection.dataChannel(forLabel: "WebRTCData", configuration: config) else {
            Logger.info("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        self.remoteDataChannel?.sendData(buffer)
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd rtpReceiver: RTCRtpReceiver, streams mediaStreams: [RTCMediaStream]) {
        Logger.verbose("peerConnection rtpReceiver: \(rtpReceiver)")
        self.reReciver = rtpReceiver
        ///音频进行解密
        if rtpReceiver.track?.kind == "audio" && self.isDecryptor == true {
            WrapperOc.rtcReceiverDecryptor(rtpReceiver, crypto: longKey)
        }

    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        Logger.verbose("peerConnection new signaling state: \(stateChanged)")
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        Logger.verbose("peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        Logger.verbose("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        Logger.verbose("peerConnection should negotiate")
    }
    
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        Logger.verbose("peerConnection new connection state: \(newState)")
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        Logger.verbose("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        Logger.verbose("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        Logger.verbose("peerConnection did open data channel")
        self.remoteDataChannel = dataChannel
    }
    
}

extension WebRTCClient {
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool) {
        peerConnection.transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
}

// MARK: - Video control
extension WebRTCClient {
    func hideVideo() {
        self.setVideoEnabled(false)
    }
    func showVideo() {
        self.setVideoEnabled(true)
    }
    private func setVideoEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCVideoTrack.self, isEnabled: isEnabled)
    }
}

// MARK:- Audio control
extension WebRTCClient {
    func muteAudio() {
        self.setAudioEnabled(false)
    }
    
    func unmuteAudio() {
        self.setAudioEnabled(true)
    }
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
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
                Logger.error("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    // Force speaker
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
                Logger.error("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    private func setAudioEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled)
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        Logger.debug("dataChannel did change state: \(dataChannel.readyState)")
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
}

