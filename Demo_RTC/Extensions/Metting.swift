//
//  Metting.swift
//  rtc_demo
//
//  Created by apple on 2021/11/30.
//

import Foundation

struct Condidatas :Codable {
    let sdp:String?
    let sdp_index:Int
    let sdp_mid:String
}

struct Members :Codable {
    let uid:Int
    let sdp:String?
    let condidatas:[Condidatas]?
}

struct Metting :Codable {
    var room_id:String
    var errMsg:String?
    var res:Int
    var members:[Members]

    private enum CodingKeys : String , CodingKey {
        case room_id="room_id"
        case res="res"
        case errMsg="err_msg"
        case members="members"
    }

    // 解码：JSON -> Model 必须实现这个方法
    init(from decoder: Decoder) throws {
        // 解码器提供了一个容器，用来存储这些变量
        let container = try decoder.container(keyedBy: CodingKeys.self)
        room_id = try container.decode(String.self, forKey: .room_id)
        errMsg = try container.decode(String.self, forKey: .errMsg)
        res = try container.decode(Int.self, forKey: .res)
        do { //处理服务器返回为null的时候
            members = try container.decode([Members].self, forKey: .members)
           }catch {
            members = [Members.init(uid: 0, sdp: "", condidatas: [])]
        }
    }

    // 编码：Model -> JSON 必须实现这个方法
    func encode(to encoder: Encoder) throws {
        // 编码器同样提供了一个容器，用来提供对应变量的值
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(room_id, forKey: .room_id)
        try container.encode(errMsg, forKey: .errMsg)
        try container.encode(res, forKey: .res)
        try container.encode(members, forKey: .members)
    }

}
