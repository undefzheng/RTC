//
//  WebSocketProvider.swift
//  rtc_demo
//
//  Created by apple on 2021/11/29.
//

import Foundation

protocol WebSocketProvider: AnyObject {
    var delegate: WebSocketProviderDeleate? {get set}
    func connect()
    func send(data: Data)
}

protocol WebSocketProviderDeleate: AnyObject {
    func webSocketDidConnect(_ webSocket: WebSocketProvider)
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data)
}
