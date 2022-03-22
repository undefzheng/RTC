//
//  NotificationModel.swift
//  rtc_demo
//
//  Created by apple on 2021/12/3.
//

import Foundation

enum JoinType: Int, Codable {
    case SingleChat = 1, GroupChat
}

struct NotificationModel: Codable {
    
    var type:JoinType
    var event_type:Int
    var avtype:Int?
    var uid: Int
    var app_key: Int?
    var sdp_type: Int?
    var sdp: String?
    var room_id: String
    var sdp_mid: String?
    var sdp_index: Int?
}
