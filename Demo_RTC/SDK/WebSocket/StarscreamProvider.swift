//
//  StarscreamProvider.swift
//  rtc_demo
//
//  Created by apple on 2021/11/29.
//

import Foundation
import Starscream

class StarscreamWebSocket: WebSocketProvider {
    
    var delegate: WebSocketProviderDeleate?
    private let socket: WebSocket
    
    init(request: URLRequest) {
        self.socket = WebSocket(request: request)
        self.socket.delegate = self
    }
    
    func connect() {
        self.socket.connect()
    }
    
    func send(data: Data) {
        self.socket.write(data: data)
    }
}

extension StarscreamWebSocket: Starscream.WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            Logger.info("websocket is connected: \(headers)")
            self.delegate?.webSocketDidConnect(self)
        case .disconnected(let reason, let code):
            Logger.info("websocket is disconnected: \(reason) with code: \(code)")
            self.delegate?.webSocketDidDisconnect(self)
        case .text(let string):
            Logger.info("Received text: \(string)")
        case .binary(let data):
            self.delegate?.webSocket(self, didReceiveData: data)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            break
        case .error(let error):
            handleError(error)
            break
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            Logger.warn("websocket encountered an error: \(e.message)")
        } else if let e = error {
            Logger.warn("websocket encountered an error: \(e.localizedDescription)")
        } else {
            Logger.warn("websocket encountered an error")
        }
    }
}
