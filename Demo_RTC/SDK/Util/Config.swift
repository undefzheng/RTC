//
//  Config.swift
//  rtc_demo
//
//  Created by apple on 2021/11/29.
//

import Foundation

//url
fileprivate let defaultSignalingServerURL = URL(string: "wss://www.iotgeek.top/rtc2")!

///turn、stun服务器
fileprivate let defaultIcceServers = ["turn:119.91.72.223:7834"]

///访问地址
struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers:[String]
    
    static let  `default` = Config(signalingServerUrl: defaultSignalingServerURL, webRTCIceServers: defaultIcceServers)
}

