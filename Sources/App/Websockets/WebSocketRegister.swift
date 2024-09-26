//
//  WebSocketRegister.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 21.09.24.
//

import Foundation
import Vapor
import HomeControlKit

protocol WebSocketRegisterDelegate: AnyObject {
    func didUpdateRegisteredWebSockets()
}

class WebSocketRegister {
    var registeredWebSockets: [RegisteredWebSocket] = [] {
        didSet {
            delegate?.didUpdateRegisteredWebSockets()
        }
    }
    weak var delegate: WebSocketRegisterDelegate?

    init(delegate: WebSocketRegisterDelegate?) {
        self.delegate = delegate
    }

    func send(message: any WebSocketMessage) async {
        var removeWebSocketIDs: [UUID] = []
        for registeredWebSocket in registeredWebSockets {
            do {
                try await registeredWebSocket.send(message: message)
            } catch {
                if registeredWebSocket.websocket.isClosed {
                    removeWebSocketIDs.append(registeredWebSocket.id)
                } else {
                    print("Failed to send to websocket \(error)")
                }
            }
        }

        if !removeWebSocketIDs.isEmpty {
            print("Remove \(removeWebSocketIDs.count) WebSockets")
            for removeWebSocketID in removeWebSocketIDs {
                registeredWebSockets.removeAll(where: { $0.id == removeWebSocketID })
            }
        }
    }
}

struct WebSocketRegisterKey: StorageKey {
    typealias Value = WebSocketRegister
}

extension Application {
    var webSocketRegister: WebSocketRegister? {
        get { storage[WebSocketRegisterKey.self] }
        set { storage[WebSocketRegisterKey.self] = newValue }
    }

    func register(webSocket: WebSocket, settings: WebSocketSettings) -> RegisteredWebSocket {
        let register = self.webSocketRegister ?? .init(delegate: self)
        self.webSocketRegister = register

        let newRegisteredWebSocket = RegisteredWebSocket(id: .init(), websocket: webSocket, settings: settings)
        register.registeredWebSockets.append(newRegisteredWebSocket)
        return newRegisteredWebSocket
    }

    func update(settings: WebSocketSettings, for id: UUID) {
        guard let registeredWebSocket = webSocketRegister?.registeredWebSockets.first(where: { $0.id == id }) else {
            return
        }
        registeredWebSocket.settings = settings
    }
}

extension Application: WebSocketRegisterDelegate {
    func didUpdateRegisteredWebSockets() { }
}
