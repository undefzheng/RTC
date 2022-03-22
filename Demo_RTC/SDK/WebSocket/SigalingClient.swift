//
//  SigalingClient.swift
//  rtc_demo
//
//  Created by apple on 2021/11/29.
//

import Foundation
import WebRTC

protocol SigalingCliendtDelegate: AnyObject {
    /// webscoket链接回调
    func signalClientDidConnect(_ signalClient: SigalingClient)
    /// webscket链接断开
    func signalClientDidDisconnect(_ signalClient: SigalingClient)
    /// 发送信令相关cmd
    func signalClient(_ signalClient: SigalingClient, didReceiveCmd cmd:UInt16,receiveBody body:NSDictionary)
}

final class SigalingClient {
    
    private let webScoket: WebSocketProvider
    weak var delegate: SigalingCliendtDelegate?
    private let config = CMDConfig.cmddefault
    var uid:UInt32 = 0;
    var JoinType: JoinType = .SingleChat
    
    
    //初始化
    init(webSocket: WebSocketProvider) {
        self.webScoket = webSocket
    }
    
    //进行链接
    func connect(pUid: String) {
        self.webScoket.delegate = self
        self.webScoket.connect()
        self.uid = UInt32(pUid)!
    }
    
    //进行链接
    func connect(uid: Int) {
        self.webScoket.delegate = self
        self.webScoket.connect()
        self.uid = UInt32(uid)
    }
    
    //更新uid
    func updateUid(uid: Int) {
        self.uid = UInt32(uid)
    }
}

///信令相关
extension SigalingClient {
    
    /// 发送sdp
    /// - Parameters:
    ///   - rtcSdp: sdp
    ///   - rooID: rooid
    ///   - meberID: 用户id
    ///   - merbers: 用户组
    func send(type: chatType, avtype: Int, sdp rtcSdp:String, cID room_id:String, mID meberID:Int, mIDs merbers:[Int?]) {
        self.sendVideo(type: type, avtype: avtype, uid: meberID, app_key: 16001, sdp: rtcSdp, call_ids: merbers, room_id: room_id)
        
    }
    
    /// 查询会议信息
    /// - Parameters:
    ///   - channelID: 房间id
    ///   - verify_code: 验证码
    func sendMetingState(room_id: String, verify_code: String) {
        let parmas:NSDictionary = ["room_id": room_id, "verify_code": "000000"]
        let cmd = UInt16(self.config.checkMeetingCS)
        Logger.info("C-->S查询会议：\(parmas)")
        self.senSignaling(body: parmas, cmd: cmd)
    }
    
    /// 发送音视频
    /// - Parameters:
    ///   - type: 1.单聊，2群聊
    ///   - avtype: 1音视频 2音频
    ///   - uid: type1的时候必填 对方的uid
    ///   - roomid: 群聊/会议 房间号
    ///   - sdp: 自己的sdp
    ///   - call_ids: type为2 需要通知的uid列表
    ///   - channel_id: 监听标签 用于推送匹配音视频状态
    func sendVideo(type: chatType, avtype: Int, uid: Int, app_key: Int, sdp: String, call_ids:[Int?], room_id: String) {
        let parmas:NSDictionary = ["type": type, "avtype": avtype, "uid": uid, "app_key": app_key, "sdp": sdp, "call_ids": call_ids, "room_id": room_id]
        let cmd = UInt16(self.config.initiateAudioCS)
        Logger.info("C-->S发送音视频：\(parmas)")
        self.senSignaling(body: parmas, cmd: cmd)
    }
    
    
    /// 加入房间
    /// - Parameters:
    ///   - type: 同上
    ///   - avtype: 同上
    ///   - channel_id: 同上
    ///   - opt: 2 -- 取消/挂断 音视频
    ///   - verify_code: 验证码
    func sendJoinMetting(type: Int, avtype: Int, room_id: String, opt: Int, verify_code:String?) {
        let parmas:NSDictionary = ["type": type, "avtype": avtype,"room_id": room_id, "verify_code": "000000", "opt": opt]
        let cmd = UInt16(self.config.operationAudioCS)
        Logger.info("C-->S加入房间：\(parmas)")
        self.senSignaling(body: parmas, cmd: cmd)
    }
    
    
    /// 更新SDP信息
    /// - Parameters:
    ///   - channel_id: 同上
    ///   - type: 同上
    ///   - avtype: 同上
    ///   - uid: 指定推送的目标如果sdp_type是 1 (即 offer)、如果sdp_type是2 (即 answer ) 则客户端需要指定目标 , 服务端会将这个 answer 推送到指定的用户、如果sdp_type 是3 (即 condidate) 也是广播
    ///   - sdp_type: 更新的sdp 的类型
    ///   - sdp: sdp 的具体内容
    ///   - sdp_Index: candidate 的 数据
    ///   - sdp_mid: candidate 的 数据
    func sendUpdateSDP(room_id: String, type: Int, avtype: Int, uid: Int, sdp_type: Int, sdp: String, sdp_Index: Int, sdp_mid: String) {
        let parmas:NSDictionary = ["room_id": room_id, "type": type,"avtype": avtype, "uid": uid, "sdp_type": sdp_type, "sdp": sdp, "sdp_Index": sdp_Index, "sdp_mid":sdp_mid]
        let cmd = UInt16(self.config.updateSDPCS)
        Logger.info("发送OFFER===更新SDP_TYPE=====\(sdp_type)")
        self.senSignaling(body: parmas, cmd: cmd)
    }
    
    /// 发送信令相关
    /// - Parameters:
    ///   - body: 内容
    ///   - cmd: 请求的cmd
    private func senSignaling(body: NSDictionary, cmd:UInt16) {
        let data = RSocketPacket.setPacketDataWithCmd(cmd, body: body, seqno: 0, uid: self.uid)
        self.webScoket.send(data: data)
    }
}

//MARK:
extension SigalingClient: WebSocketProviderDeleate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidDisconnect(self)
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            Logger.debug("Trying to reconnect to signaling server...")
            self.webScoket.connect()
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        
        let serverTC: ServerToClientModel = ServerToClientModel.serverTotalData(data)
        let type = serverTC.cmd;
        let bodyObj:NSDictionary = serverTC.body as! NSDictionary
        self.delegate?.signalClient(self, didReceiveCmd: type, receiveBody: bodyObj)

    }
}
