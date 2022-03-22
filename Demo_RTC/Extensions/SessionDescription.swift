//
//  SessionDescription.swift
//  rtc_demo
//
//  Created by apple on 2021/11/29.
//

import Foundation
import WebRTC

// 编码和解码
enum SdpType: String, Codable {
    case offer, prAnswer, answer
    
    var rtcSdpType: RTCSdpType {
        switch self {
        case .offer:    return .offer
        case .answer:   return .answer
        case .prAnswer: return .prAnswer
        }
    }
}

// 编码和解码
struct SessionDescription: Codable {
    let sdp: String
    let type: SdpType
    
    init(from rtcSessionDescription: RTCSessionDescription) {
        self.sdp = rtcSessionDescription.sdp
        
        switch rtcSessionDescription.type {
        case .offer:    self.type = .offer
        case .prAnswer: self.type = .prAnswer
        case .answer:   self.type = .answer
        @unknown default:
            fatalError("Unknown RTCSessionDescription type: \(rtcSessionDescription.type.rawValue)")
        }
    }
    
    var rtcSessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: self.type.rtcSdpType, sdp: self.sdp)
    }
}
