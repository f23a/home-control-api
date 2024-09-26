//
//  RegisteredWebSocket.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 21.09.24.
//

import Foundation
import Vapor
import HomeControlKit

class RegisteredWebSocket: Identifiable {
    var id: UUID
    var websocket: WebSocket
    var settings: WebSocketSettings

    init(id: UUID, websocket: WebSocket, settings: WebSocketSettings) {
        self.id = id
        self.websocket = websocket
        self.settings = settings
    }

    func send(message: any WebSocketMessage) async throws {
        let data = try JSONEncoder().encode(message)
        try await websocket.send(raw: data, opcode: .binary)
    }
}
