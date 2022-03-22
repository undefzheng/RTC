//
//  XRTCCallManager.swift
//  Demo_RTC
//
//  Created by apple on 2021/12/9.
//

import Foundation
import WebRTC

protocol XRTCCallManagerDelegate: AnyObject {
    ///webscoket链接状态
    func CallManagerWebStatusChanged(_ callManage: XRTCCallManager, State: WebStatus)
    ///创建房间状态
    func CallManagerChangeState(_ callManage: XRTCCallManager, state: RoomEvent, uid: Int)
    ///操作失败回调
    func CallManagerChangeErro(_ callManage: XRTCCallManager, error: rtcError)
    ///房间信息
    func CallManagerRoomInfo(_ callManage: XRTCCallManager, roomInfo: NSDictionary)
}

public class XRTCCallManager: NSObject {
    
    /// 唯一标识
    private let appkey: Int
    
    /// 用户id
    private let uid: Int
    
    /// 默认访问地址配置
    private let config = Config.default

    /// webSocket
    private var socket: SigalingClient

    /// manage代理
    weak var delegate: XRTCCallManagerDelegate?
    
    /// client的list
    private var rtcList = [WebRTCClient]()
    
    
    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    /// 管理器初始化
    /// - Parameters:
    ///   - appkey: key
    ///   - uid: uid
    public init(appkey: Int, uid: Int) {
        self.appkey = appkey
        self.uid = uid
        ///创建socket
        var request = URLRequest(url: self.config.signalingServerUrl)
        request.addValue(String(uid), forHTTPHeaderField: "uid")
        let webScoketProvider: WebSocketProvider
        webScoketProvider = StarscreamWebSocket(request: request)
        self.socket = SigalingClient(webSocket: webScoketProvider)
        
        super.init()
        self.socket.delegate = self
        self.socket.connect(uid: self.uid)
        ///创建webrtc
       self.creartWebRTC(uid: self.uid)
    }
    
    deinit {
        Logger.debug("object! XRTCCallManager destroyed... \(ObjectIdentifier(self))")
    }
    
}

// MARK: -公开方法
extension XRTCCallManager {

    func setUid(uid: Int) {
        self.updateSocketUid(uid: uid)
    }

    func replaceIceServer(iceSevers: Array<RTCIceServer>) {

    }
}

// MARK: -私有方法
extension XRTCCallManager {

    /// 更新socket的uid
    private func updateSocketUid(uid: Int) {
        self.socket.updateUid(uid: uid)
    }
    
    
    //创建server
    private func buildSignalingCliend(uid: String) -> SigalingClient {
        
        var request = URLRequest(url: self.config.signalingServerUrl)
        request.addValue(uid, forHTTPHeaderField: "uid")
        let webScoketProvider: WebSocketProvider
        webScoketProvider = StarscreamWebSocket(request: request)
        
        return SigalingClient(webSocket: webScoketProvider)
    }
}

// MARK: -socket代理
extension XRTCCallManager: SigalingCliendtDelegate {

    /// socket成功回调
    /// - Parameter signalClient: webscoket
    func signalClientDidConnect(_ signalClient: SigalingClient) {
        self.delegate?.CallManagerWebStatusChanged(self, State: WebStatus.connected)
    }

    /// socket链接断开回调
    /// - Parameter signalClient: webscoket
    func signalClientDidDisconnect(_ signalClient: SigalingClient) {
        self.delegate?.CallManagerWebStatusChanged(self, State: WebStatus.disconnected)
    }

    /// socket数据回调
    /// - Parameters:
    ///   - signalClient: webscket
    ///   - cmd: 信令服cmd
    ///   - body: 字典body
    func signalClient(_ signalClient: SigalingClient, didReceiveCmd cmd: UInt16, receiveBody body: NSDictionary) {
        Logger.info("处理\(body)");
//        Logger.verbose("接受到事件\(body)")
        let switchCMD = Int(cmd)
        switch switchCMD {
        case defaultInitiateAudioSC:
            do {
                let res = body["res"]
                self.defaultInitiateAudio(resCode: res as! Int)
            }
            break
        case defaultCheckMeetingSC:
            do {
                self.defaultCheckMeeting(body: body)
            }
            break
        case defaultOperationAudioSC:
            do {
//                let res = body["res"]
//                guard res as! Int == 0 else {
//                    Logger.error("S-->C\(String(describing: body["err_msg"]))")
//                    self.creatAlertErroString(erro: body["err_msg"] as! String)
//                    return
//                }
//                self.rooID = self.notifiModel.room_id
//                self.hasLocalSdp = true
//                self.anwerBtn.isHidden = true
//                self.sendOffer()
            }
            break
//        case defaultChangeAudioSC:
//                do{
//
//                    Logger.debug("S-->C音视频事件推送\(body)")
//
//                    guard let notifiM = BASEModel.jsonToModel(type: NotificationModel.self, json: body) else {
//                        Logger.error("接受事件后 ----会议字典转模型解析失败！！！！！！")
//                        return
//                    }
//                    self.notifiModel = notifiM
//
//
//               if self.notifiModel.event_type == 1 { //有会话创建
//                    Logger.info("S-->C接受音视频远程推送\(self.notifiModel.event_type)")
//                    self.anwerBtn.isHidden = false
//                    self.roomIDTF.text = self.notifiModel.room_id as String?
//
//                }else if self.notifiModel.event_type == 2 { //有人接听会话
//                    Logger.info("S-->C有人进入房间了event_type\(self.notifiModel.event_type)")
//                    //按道理得在这里创建占用view，等待candidate更新视频画面
//                }else if self.notifiModel.event_type == 3 { //有远程会话重连/更新
//                    Logger.info("S-->C房间有更新SDP\(self.notifiModel.event_type)")
//                    if self.notifiModel.sdp_type == 2 {   //answer
//                        let rtcSessing = RTCSessionDescription(type: RTCSdpType.answer, sdp: self.notifiModel.sdp ?? "")
//                        self.webRTCClient = self.getRTC(uid: self.notifiModel.uid)
//                        self.webRTCClient.set(remoteSdp: rtcSessing) { Error in
//                            if(Error == nil) {
//                                self.hasRemoteSdp = true
//                                Logger.info("S-->C接受ANSWER SDP更新成功")
//                            }else{
//                                Logger.error("S-->C接受ANSWER SDP更新失败")
//                            }
//                        }
//                    }else if self.notifiModel.sdp_type == 3 {  ///设置candidate
//                        let rtcC = RTCIceCandidate(sdp: self.notifiModel.sdp ?? "", sdpMLineIndex: 0, sdpMid: "")
//                            Logger.info("S-->C接受candidta 设置成功")
//                            self.remoteCandidateCount += 1
//                        self.webRTCClient.set(remoteCandidate: rtcC) { Error in
//                            if(Error == nil) {
//                            }else{
//                                Logger.info("S-->C接受candidta 设置失败")
//                            }
//                        }
//                    }else{ // 创offer，发answer
//                        self.sendAnswer()
//                    }
//                }else { //退出会议
//                    Logger.info("S-->C退出会议\(self.notifiModel.event_type)")
//                }
//
//            }
//            break
//        case defaultUpdateSDPSC:
//            do{
//                let res = body["res"]
//                guard res as! Int == 0 else {
//                    Logger.info("S-->C更新SDP失败")
//                    return
//                }
//                Logger.info("S-->C发送更新SDP成功")
//            }
//            break
        default:
            break
        }
    }

}

/// 信令服处理
extension XRTCCallManager {
    
    ///查询房间
    func quaryRoomInfo(roomID: String) {
        self.socket.sendMetingState(room_id: roomID, verify_code: "")
    }
    
    //查询房间结果
    func defaultCheckMeeting(body: NSDictionary) {
        guard let mettingModel = BASEModel.jsonToModel(type: Metting.self, json: body) else {
            Logger.error("接受事件后 ----会议字典转模型解析失败！！！！！！")
            self.delegate?.CallManagerChangeErro(self, error: rtcError.ErrorAnla)
            return
        }
        if mettingModel.res != 0 {
            Logger.info("S-->C没有房间可以创建房间\(body)")
            self.delegate?.CallManagerChangeErro(self, error: rtcError.ErrorCodeNotFoundChatRoom)
        }else{
            Logger.info("S-->C已有房间-加入：\(body)")
            self.delegate?.CallManagerRoomInfo(self, roomInfo: body)
        }
    }
    
    ///创建房间
    func creatRoom(roomId: String, type:chatType, users: Array<Int>) {
        let uid = users.first!
        self.socket.sendVideo(type: type, avtype: 1, uid: uid, app_key: self.appkey, sdp: "", call_ids: users, room_id: roomId)
    }
    
    ///房间返回结果
    func defaultInitiateAudio(resCode: Int) {
        guard resCode != 0 else {
            Logger.info("S-->C发起音视频失败：\(resCode)")
            self.delegate?.CallManagerChangeErro(self, error: rtcError.ErrorCodeCreateChatRoomFail)
            return
        }
        Logger.info("S-->C发起音视频成功：\(resCode))")
        self.delegate?.CallManagerChangeState(self, state: RoomEvent.creatRoomSuccess, uid: self.uid)
    }
}

/// webRTC 处理
extension XRTCCallManager {
    
    func creartWebRTC(uid: Int) -> WebRTCClient {
        let webRtc = WebRTCClient(iceServers: self.config.webRTCIceServers, uid: uid)
        webRtc.delegate = self
        self.rtcList.append(webRtc)
        return webRtc
    }
}


///webRTC 代理
extension XRTCCallManager: WebRTCClientDelegate {


    /// candidata 产生回调
    /// - Parameters:
    ///   - client: rtcClicent
    ///   - candidate: 获取到candidate
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        Logger.info("candidate")
    }

    /// webRTC链接状态
    /// - Parameters:
    ///   - client: client
    ///   - state: 当前状态
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        switch state {
        case .connected, .completed:
            delegate?.CallManagerChangeState(self, state: RoomEvent.joinRoom, uid: client.uid)
        case .disconnected:
            delegate?.CallManagerChangeState(self, state: RoomEvent.leaveRoom, uid: client.uid)
        case .failed, .closed:
            delegate?.CallManagerChangeState(self, state: RoomEvent.closeRoom, uid: client.uid)
        case .new, .checking, .count:
            delegate?.CallManagerChangeState(self, state: RoomEvent.creatRoomSuccess, uid: client.uid)
        @unknown default:
            Logger.info("default")
        }
    }

    /// 透明通道
    /// - Parameters:
    ///   - client: client
    ///   - data: data数据
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        Logger.info("获取到data\(data)")
    }
}
