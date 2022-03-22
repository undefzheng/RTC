//
//  ViewController.swift
//  rtc_demo
//
//  Created by apple on 2021/11/29.
//

import UIKit
import Starscream
import WebRTC

class MainViewController: UIViewController {
    
    @IBOutlet weak var signalStatusLabel: UILabel!
    @IBOutlet weak var localsdpLabel: UILabel!
    @IBOutlet weak var candidateLabel: UILabel!
    @IBOutlet weak var remotesdpLabel: UILabel!
    @IBOutlet weak var rcandidateLabel: UILabel!
    @IBOutlet weak var webRTCStatusLabel: UILabel!
    @IBOutlet weak var roomIDTF: UITextField!
    @IBOutlet weak var uidTF: UITextField!
    @IBOutlet weak var socketButton: UIButton!
    @IBOutlet weak var rIdTF: UITextField!
    @IBOutlet weak var anwerBtn: UIButton!
    
    private var notifiModel: NotificationModel!
    private var metingModel: Metting!
    private var rtcList = [WebRTCClient]()

    private let decoder = JSONDecoder()
    private var signalClient: SigalingClient
    private var webRTCClient: WebRTCClient
    private let config = Config.default
    private let cmdConfig = CMDConfig.cmddefault
    private var eventUid = 0
    private var cmdT = 0
    private var sdpType = 1
//    private lazy var videoViewController = VideoViewController(webRTCClient: self.rtcList)
    private var rooID: String = ""
    @IBOutlet weak var derBtn: UIButton!
    
    @IBOutlet weak var localView: UIView!
    
    private var signalingConnected: Bool = false {
        didSet {
            if self.signalingConnected {
                self.signalStatusLabel?.text = "Connected"
                self.signalStatusLabel?.textColor = UIColor.green
                self.socketButton.isEnabled = false
            }
            else {
                self.signalStatusLabel?.text = "Not signalStatusLabel"
                self.signalStatusLabel?.textColor = UIColor.red
                self.uidTF.isEnabled = true
            }
        }
    }
    
    private var hasLocalSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.localsdpLabel.text = self.hasLocalSdp ? "✅" : "❌"
            }
        
        }
    }
    
    private var hasRemoteSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.remotesdpLabel?.text = self.hasRemoteSdp ? "✅" : "❌"
            }
        }
    }
    
    private var localCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.candidateLabel?.text = "\(self.localCandidateCount)"
            }
           
        }
    }
    
    private var remoteCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.rcandidateLabel?.text = "\(self.remoteCandidateCount)"
            }
        }
    }
    
    //创建server
    private func buildSignalingCliend() -> SigalingClient {
        
        var request = URLRequest(url: self.config.signalingServerUrl)
        request.timeoutInterval = 60 // Sets the timeout for the connection
        request.addValue(self.uidTF.text!, forHTTPHeaderField: "uid")
        
        let webScoketProvider: WebSocketProvider
        webScoketProvider = StarscreamWebSocket(request: request)
        
        return SigalingClient(webSocket: webScoketProvider)
    }
    
    init(webRTCClient: WebRTCClient) {
        self.signalClient = SigalingClient(webSocket: StarscreamWebSocket(request: URLRequest(url: self.config.signalingServerUrl)))
        self.webRTCClient = webRTCClient
//        self.rtcList.append(webRTCClient)
        super.init(nibName: String(describing: MainViewController.self), bundle: Bundle.main)
        
        
        let sdk =  XRtcSDK.init(appkey: 16000, uid: 12)
//        sdk.delegate = self
//        sdk.quaryRoomInfo(roomID: "uid_167000")
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "webRTC SDK"
      
        
        ///初始值
        self.hasLocalSdp = false
        self.hasRemoteSdp = false
        self.localCandidateCount = 0;
        self.remoteCandidateCount = 0;
        self.webRTCStatusLabel?.text = "New"
        self.roomIDTF.text = "channel_00025"
        self.rooID = self.roomIDTF.text!
        self.uidTF.text = "13"
        self.rIdTF.text = "10,19,12"
        self.webRTCClient.delegate = self
        self.webRTCClient.uid = Int(self.uidTF.text!)!
        //注册点击事件
        let tapSingle=UITapGestureRecognizer(target:self,action:#selector(handleTap(_:)))
        view.addGestureRecognizer(tapSingle)
    }
    
    //跳转到视频
    @IBAction func VideoOpen(_ sender: Any) {
//        self.navigationController?.pushViewController(videoViewController, animated: true)
        self.present(VideoViewController(webRTCClient: self.rtcList), animated: true, completion: nil)
    }
    
    //退出键盘
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.view?.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    @IBAction func socketTap(_ sender: Any) {
        self.view?.endEditing(true)
        self.signalClient = self.buildSignalingCliend()
        self.signalClient.delegate = self
        self.signalClient.connect(pUid: self.uidTF.text!)
    }
    
    
    /// 加入房间
    /// - Parameter sender: sender
    @IBAction func joinMeeting(_ sender: Any) {
        self.creatAlert()
    }
    
    //创建房间
    func creatRoom() {
            self.rooID = self.roomIDTF.text!
            self.hasLocalSdp = true
            let UIDStr = self.rIdTF.text!
            guard UIDStr.count > 0 else {
                Logger.error("请输入UID")
                return
            }
            let uidList = UIDStr.components(separatedBy: ",").map(Int.init)
            let mid = uidList.first

        self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers, uid: self.webRTCClient.uid)
        self.webRTCClient.delegate = self
        self.rtcList.append(self.webRTCClient)
        self.webRTCClient.offer { (sdp) in
//            self.signalClient.send(type: self.signalClient.JoinType.rawValue, avtype: 1, sdp: sdp, cID: self.rooID, mID: mid! ?? 0, mIDs: uidList)
        }
    }
    
    //接听操作
    @IBAction func answerTap(_ sender: Any) {
        self.signalClient.sendMetingState(room_id: self.roomIDTF.text!, verify_code: "")
//
//        self.signalClient.sendJoinMetting(type:  self.notifiModel.type.rawValue, avtype: 1, channel_id:self.roomIDTF.text!, opt: 1, verify_code: "")
    }
    
    ///创建弹窗选择功能
    private func creatAlert() {
        let  alertController =  UIAlertController (title:  "" ,
                                                   message:  "选择开启聊天功能" , preferredStyle: . alert )
        let  cancelAction =  UIAlertAction (title:  "进行私聊" , style: . default) { ation in
            self.signalClient.JoinType = .SingleChat
            self.signalClient.sendMetingState(room_id: self.roomIDTF.text!, verify_code: "")
        }
        let  okAction =  UIAlertAction (title:  "进行群聊" , style: . default ,
            handler: {
                action  in
                self.signalClient.JoinType = .GroupChat
            self.signalClient.sendMetingState(room_id: self.roomIDTF.text!, verify_code: "")
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self .present(alertController, animated:  true , completion:  nil )
    }
    
    ///报错提示
    private func creatAlertErroString(erro: String) {
        let  alertController =  UIAlertController (title:  "" ,
                                                   message:  erro , preferredStyle: . alert )
        let  cancelAction =  UIAlertAction (title:  "好的" , style: . default) { ation in
        }
        alertController.addAction(cancelAction)
        self .present(alertController, animated:  true , completion:  nil )
    }
    
    /// 查询/创建房间后生成offer，然后发送给房间内的每一个成员
    private func sendOffer() {
        for Members in self.metingModel.members {
            if Members.uid != 0 {
                
                //得考虑后续加入/当前接入/创建三种情况
                var joinType: Int = 1
                if self.notifiModel == nil {
                    joinType = self.signalClient.JoinType.rawValue
                }else{
                    joinType = self.notifiModel.type.rawValue
                }
                
                
                //创建PC
                self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers, uid: Members.uid)
                self.webRTCClient.delegate = self
                self.rtcList.append(self.webRTCClient)
                self.webRTCClient.offer { (sdp) in
                    //发送SDP
                    Logger.info("发送OFFER===更新SDP_TYPE=====1\(sdp.sdp)")
                    self.signalClient.sendUpdateSDP(room_id: self.rooID, type:  joinType, avtype:  1, uid:  Members.uid, sdp_type: 1, sdp: sdp.sdp , sdp_Index: 0, sdp_mid: "")
                }
               
            }
        }
    }
    
    /// 接受offer后，创建offer，产生answer发给对方
    private func sendAnswer() {
        self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers, uid: self.notifiModel.uid)
        self.webRTCClient.delegate = self
        self.rtcList.append(self.webRTCClient)
        let rtcSessing = RTCSessionDescription(type: RTCSdpType.offer, sdp: self.notifiModel.sdp ?? "")
        Logger.info("S-->C接受OFFER 的SDP\(String(describing: self.notifiModel.sdp))")
        let rooID = self.roomIDTF.text
        self.webRTCClient.set(remoteSdp: rtcSessing) { Error in
            if (Error == nil) {
                self.webRTCClient.answer { sdp in
                        self.hasRemoteSdp = true
                        Logger.info("产生ANSWER 的SDP_TYPE=====2\(sdp)")
                    self.signalClient.sendUpdateSDP(room_id: rooID!, type: self.notifiModel.type.rawValue, avtype: 1, uid: self.notifiModel.uid, sdp_type: 2, sdp: sdp.sdp, sdp_Index: 0, sdp_mid: "")
                }
            }else{
                Logger.info("S-->C产生ANSWER 的SDP失败\(String(describing: Error))")
            }
        }
    }
    
    ///发送candidate
    private func sendCandidate(candidate: RTCIceCandidate) {
        Logger.info("discovered local candidate SDP_TYPE=====3\(candidate.sdp)")
    
        for rtcClient in self.rtcList {
            self.signalClient.sendUpdateSDP(room_id: self.rooID, type: self.signalClient.JoinType.rawValue, avtype: 1, uid: rtcClient.uid, sdp_type: 3, sdp: candidate.sdp, sdp_Index: 0, sdp_mid: "")
        }
    }
    
    //找出PC
    private func getRTC(uid: Int) -> (WebRTCClient) {
        for rtcClient in self.rtcList {
            if rtcClient.uid == uid {
                return rtcClient
            }
        }
        
        if self.notifiModel != nil {
            ///没有情况下，创建一个新的PC
            self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers, uid: self.notifiModel.uid)
            self.webRTCClient.delegate = self
            self.rtcList.append(self.webRTCClient)
            return self.webRTCClient
        }
       return webRTCClient
    }
    
    @IBAction func btnDeTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.derBtn .setTitle("关闭加密", for: .normal)
        }else{
            self.derBtn .setTitle("开启加密", for: .normal)
        }
        
        ///发通知
        NotificationCenter.default.post(name: NSNotification.Name("btnDeTapClick"), object: nil, userInfo: ["bool":sender.isSelected])
    }
}

extension MainViewController: SigalingCliendtDelegate {
    func signalClient(_ signalClient: SigalingClient, didReceiveCmd cmd: UInt16, receiveBody body: NSDictionary) {
        
        Logger.verbose("接受到事件\(body)")
        let switchCMD = Int(cmd)
        self.cmdT = switchCMD
        switch switchCMD {
        case cmdConfig.initiateAudioSC:
            do {
                let res = body["res"]
                guard res as! Int == 0 else {
                    Logger.info("S-->C发起音视频失败：\(body)")
                    return
                }
                Logger.info("S-->C发起音视频成功：\(String(describing: res))")
            }
        case cmdConfig.checkMeetingSC:
            do {
                guard let mettingModel = BASEModel.jsonToModel(type: Metting.self, json: body) else {
                    Logger.error("接受事件后 ----会议字典转模型解析失败！！！！！！")
                    return
                }
                self.metingModel = mettingModel
                if mettingModel.res != 0 {
                    Logger.info("S-->C没有房间创建房间\(body)")
                    self.creatRoom()
                }else{
                    Logger.info("S-->C已有房间-加入：\(body)")
                    self.signalClient.sendJoinMetting(type:  self.signalClient.JoinType.rawValue, avtype: 1, room_id:self.roomIDTF.text!, opt: 1, verify_code: "")
                    
                }
            }
            break
        case cmdConfig.operationAudioSC:
            do {
                let res = body["res"]
                guard res as! Int == 0 else {
                    Logger.error("S-->C\(String(describing: body["err_msg"]))")
                    self.creatAlertErroString(erro: body["err_msg"] as! String)
                    return
                }
                self.rooID = self.notifiModel.room_id
                self.hasLocalSdp = true
                self.anwerBtn.isHidden = true
                self.sendOffer()
            }
            break
        case cmdConfig.changeAudioSC:
                do{
                    
                    Logger.debug("S-->C音视频事件推送\(body)")
                    
                    guard let notifiM = BASEModel.jsonToModel(type: NotificationModel.self, json: body) else {
                        Logger.error("接受事件后 ----会议字典转模型解析失败！！！！！！")
                        return
                    }
                    self.notifiModel = notifiM
                    
                    
               if self.notifiModel.event_type == 1 { //有会话创建
                    Logger.info("S-->C接受音视频远程推送\(self.notifiModel.event_type)")
                    self.anwerBtn.isHidden = false
                    self.roomIDTF.text = self.notifiModel.room_id as String?
                      
                }else if self.notifiModel.event_type == 2 { //有人接听会话
                    Logger.info("S-->C有人进入房间了event_type\(self.notifiModel.event_type)")
                    //按道理得在这里创建占用view，等待candidate更新视频画面
                }else if self.notifiModel.event_type == 3 { //有远程会话重连/更新
                    Logger.info("S-->C房间有更新SDP\(self.notifiModel.event_type)")
                    if self.notifiModel.sdp_type == 2 {   //answer
                        let rtcSessing = RTCSessionDescription(type: RTCSdpType.answer, sdp: self.notifiModel.sdp ?? "")
                        self.webRTCClient = self.getRTC(uid: self.notifiModel.uid)
                        self.webRTCClient.set(remoteSdp: rtcSessing) { Error in
                            if(Error == nil) {
                                self.hasRemoteSdp = true
                                Logger.info("S-->C接受ANSWER SDP更新成功")
                            }else{
                                Logger.error("S-->C接受ANSWER SDP更新失败")
                            }
                        }
                    }else if self.notifiModel.sdp_type == 3 {  ///设置candidate
                        let rtcC = RTCIceCandidate(sdp: self.notifiModel.sdp ?? "", sdpMLineIndex: 0, sdpMid: "")
                            Logger.info("S-->C接受candidta 设置成功")
                            self.remoteCandidateCount += 1
                        self.webRTCClient.set(remoteCandidate: rtcC) { Error in
                            if(Error == nil) {
                            }else{
                                Logger.info("S-->C接受candidta 设置失败")
                            }
                        }
                    }else{ // 创offer，发answer
                        self.sendAnswer()
                    }
                }else { //退出会议
                    Logger.info("S-->C退出会议\(self.notifiModel.event_type)")
                }
                
            }
            break
        case cmdConfig.updateSDPSC:
            do{
                let res = body["res"]
                guard res as! Int == 0 else {
                    Logger.info("S-->C更新SDP失败")
                    return
                }
                Logger.info("S-->C发送更新SDP成功")
            }
            break
        default:
            break
        }
    }
    
    func signalClientDidConnect(_ signalClient: SigalingClient) {
        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SigalingClient) {
        self.signalingConnected = false
    }
    
}

//代理
extension MainViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        self.localCandidateCount += 1
        self.sendCandidate(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        let textColor: UIColor
        switch state {
        case .connected, .completed:
            textColor = .green
        case .disconnected:
            textColor = .orange
        case .failed, .closed:
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
        let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
        let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
