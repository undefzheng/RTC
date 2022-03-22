//
//  cmdConfig.swift
//  rtc_demo
//
//  Created by apple on 2021/11/30.
//

import Foundation
//发起音视频
public let defaultInitiateAudioCS = 26020
public let defaultInitiateAudioSC = 26021
///音视频事件
public let defaultChangeAudioSC = 26023
///音视频基本操作 加入/回复/同意/拒绝等
public let defaultOperationAudioCS = 26026
public let defaultOperationAudioSC = 26027
//查询会议信息
public let defaultCheckMeetingCS = 26028
public let defaultCheckMeetingSC = 26029
//更新SDP
public let defaultUpdateSDPCS = 26030
public let defaultUpdateSDPSC = 26031
///邀请好友
public let defaultInvitationCS = 26032
public let defaultInvitationSC = 26033
///切换音视频模式
public let defaultAVSwitchCS = 26036
public let defaultAVSwitchSC = 26037

///访问地址
struct CMDConfig {
    let initiateAudioCS: Int
    let initiateAudioSC:Int
    
    let changeAudioSC:Int
    
    let operationAudioCS:Int
    let operationAudioSC:Int
    
    let checkMeetingCS:Int
    let checkMeetingSC:Int
    
    let updateSDPCS:Int
    let updateSDPSC:Int
    
    let invitationCS:Int
    let invitationSC:Int
    
    let AVSwitchCS:Int
    let AVSwitchSC:Int
    
    static let  `cmddefault` = CMDConfig(initiateAudioCS: defaultInitiateAudioCS, initiateAudioSC: defaultInitiateAudioSC, changeAudioSC: defaultChangeAudioSC, operationAudioCS: defaultOperationAudioCS, operationAudioSC: defaultOperationAudioSC, checkMeetingCS: defaultCheckMeetingCS, checkMeetingSC: defaultCheckMeetingSC, updateSDPCS: defaultUpdateSDPCS, updateSDPSC: defaultUpdateSDPSC, invitationCS: defaultInvitationCS, invitationSC: defaultInvitationSC, AVSwitchCS: defaultAVSwitchCS, AVSwitchSC:defaultAVSwitchSC)
}
