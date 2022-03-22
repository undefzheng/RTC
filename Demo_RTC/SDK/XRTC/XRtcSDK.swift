//
//  XCallManager.swift
//  Demo_RTC
//
//  Created by apple on 2021/12/9.
//

import Foundation
import WebRTC

/// webscket 状态
public enum WebStatus: Int32 {
    ///未链接
    case noConnected = 0
    ///已链接
    case connected
    ///断开
    case disconnected
    ///报错，目前没回调错误信息出来
    case error
}

///加密选项
public enum EncryptorType: Int32 {
    ///未加密
    case noEncryptory = 0
    ///aes加密
    case aes
    ///棘轮加密
    case Ratchet
}

///传输通道
public enum RansmissionType: Int32 {
    ///信令
    case sigling = 1
    ///透明通道
    case p2p
}

///聊天类型
public enum chatType: Int32 {
    ///个人
    case personal = 1
    ///群聊
    case group
}

///音视频切换状态
public enum SwitchAvType: Int32 {
    ///音视频
    case AudioVideo = 1
    ///音频
    case Audio
}

///会议事件
public enum RoomEvent: Int32 {
    ///本地
    case xrtcingLocal = 0
    ///远程
    case xrtcingRemote
    ///本地连接
    case connectedLocal
    ///远程连接
    case connectedRemote
    ///会议超时
    case endedTimeout
    ///加入房间
    case joinRoom
    ///离开房间
    case leaveRoom
    ///拒绝进入房间
    case refuseRoom
    ///关闭房间
    case closeRoom
    ///创建房间成功
    case creatRoomSuccess
}

///错误码
public enum rtcError: Int {
    /// 操作成功
    case ErrorCodeSuccess = 0
    /// 没有权限访问. 不是房间的成员,或者无权加入,无权发起
    case ErrorCodePermissionDenied = 40001
    /// 不在这个会议,或者未找到这个会议
    case ErrorCodeNotFoundChatRoom = 40004
    /// 创建音视频会议失败, 可能是这个 channel 被占用
    case ErrorCodeCreateChatRoomFail = 40010
    /// 加入音视频会议失败, 可能是channel 错误,或者验证码错误,无权加入等
    case ErrorCodeJoinChatRoomFail = 40011
    /// 不是这个channel 的成员 , 无法对这channel 进行操作
    case ErrorCodeNoMemberChannel = 40012
    /// 请添加成员
    case ErrorCodeAddMember = 50001
    /// 请输入房间号
    case ErrorCodeRoomId = 50002
    /// 会议字典转模型解析失败
    case ErrorAnla = 50003
}

protocol XRtcSDKDelegate: AnyObject {
    
    /// 创建房间（被邀请）
    func XRtcOnInvitedMember(_ rtcSDK: XRtcSDK)
    
    /// 关闭房间
    func XRtcOnRoomClose(_ rtcSDK: XRtcSDK)
    
    /// 查询房间信息
    func XRtcOnRoomInfo(_ rtcSDK: XRtcSDK, roomInfo: NSDictionary)
    
    /// 用户进入房间
    func XRtcOnMemberJoin(_ rtcSDK: XRtcSDK, memberJoin uid: Int)
    
    /// 用户离开房间
    func XRtcOnMemberLeave(_ rtcSDK: XRtcSDK, memberJoin uid: Int)
    
    /// 用户拒绝邀请
    func XRtcOnMemberRefuse(_ rtcSDK: XRtcSDK, memberJoin uid: Int)
    
    /// 用户掉线 - 服务器推送
    func XRtcOnMemberOffline(_ rtcSDK: XRtcSDK, memberJoin uid: Int)
    
    ///切换音视频类型
    func XRtcOnSwitchAvType(_ rtcSDK: XRtcSDK, avtype: SwitchAvType)
    
    /// 会议操作结果
    func XRtcOnRoomResult(_ rtcSDK: XRtcSDK, result: RoomEvent)
    
    /// 网络状态改变
    func XRtconWebStatusChanged(_ rtcSDK: XRtcSDK, State: WebStatus)
}

open class XRtcSDK: NSObject {
    
    let callManager: XRTCCallManager
    ///代理
    weak var delegate: XRtcSDKDelegate?
    
    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    /// 初始化
    /// - Parameters:
    ///   - appkey: app唯一标识
    ///   - uid: uid
    required public init(appkey: Int, uid: Int) {

        self.callManager = XRTCCallManager.init(appkey: appkey, uid: uid)
        super.init()
        ///打开日志
        self.openLog(isOpen: true)
        self.callManager.delegate = self
    }
    
    deinit {
        Logger.debug("object! XRtcSDK destroyed... \(ObjectIdentifier(self))")
    }
    
    /// 是否打开日志 默认打开
    /// - Parameter isOpen:
    func openLog(isOpen: Bool) {
        DebugLogger.shared().openLoging(isOpen)
    }
    
    /// 更新uid
    /// - Parameter uid: uid
    func setUid(uid: Int) {
        self.callManager.setUid(uid: uid)
    }
    
    
    /// 查询房间信息
    /// - Parameters:
    ///   - roomID: rooid
    func quaryRoomInfo(roomID: String) {
        self.callManager.quaryRoomInfo(roomID: roomID)
    }
    
    /// 创建房间
    /// - Parameters:
    ///   - roomId: 房间id
    ///   - type: 1 私聊 uid_111111  群聊 gid_111111
    ///   - users: 用户组，注意数组里面一定是要int类型
    func creatRoom(roomId: String, type:chatType, users: Array<Int>) {
        self.callManager.creatRoom(roomId: roomId, type: type, users: users)
    }
    
    /// 邀请用户
    /// - Parameter users: 用户数组
    func inviteMember(users:Array<Int>) {
        
    }
    
    /// 设置ice 服务器
    /// - Parameter list: ice服务器  turn、stun
    /// TODO: 后面考虑传入dic。这边通过字典在里面逻辑进行解析
    func replaceIceServer(iceSevers: Array<RTCIceServer>) {
        self.callManager.replaceIceServer(iceSevers: iceSevers)
    }
    
    /// 加减密
    /// - Parameters:
    ///   - start: 开启状态
    ///   - type: 加密类型 0 : 不加密 1：aes加密 2： 棘轮加密
    ///   - ransmission: 1: 信令服 2：透明通道
    func startEncryptor(start: Bool, type: EncryptorType, ransmission: RansmissionType) {
        
    }
    
    /// 切换音视频
    /// 1 音视频 2 音频
    func switchAvType(avtype: SwitchAvType){
        
    }
    
}

extension XRtcSDK: XRTCCallManagerDelegate {
    
    func CallManagerWebStatusChanged(_ callManage: XRTCCallManager, State: WebStatus) {
        delegate?.XRtconWebStatusChanged(self, State: State)
    }
    
    func CallManagerChangeState(_ callManage: XRTCCallManager, state: RoomEvent, uid: Int) {
        Logger.info("当前事件\(state)")
    }
    
    func CallManagerChangeErro(_ callManage: XRTCCallManager, error: rtcError) {
        if error == rtcError.ErrorCodeNotFoundChatRoom {
            delegate?.XRtcOnRoomInfo(self, roomInfo: NSDictionary.init())
        }else{
            Logger.error("错误信息\(error)")
        }
    }
    
    func CallManagerRoomInfo(_ callManage: XRTCCallManager, roomInfo: NSDictionary) {
        delegate?.XRtcOnRoomInfo(self, roomInfo: roomInfo)
    }
    
  
    
}
