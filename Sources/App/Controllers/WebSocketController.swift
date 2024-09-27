//
//  WebSocketController.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 21.09.24.
//

import Vapor
import HomeControlKit

struct WebSocketController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.webSocket("ws", onUpgrade: webSocket)
        routes.put("ws", "settings", ":id", use: webSocketSettings)
    }

    @Sendable
    func webSocket(req: Request, ws: WebSocket) async {
        let registeredWebSocket = req.application.register(webSocket: ws, settings: .default)

        do {
            try await registeredWebSocket.send(message: WebSocketDidRegisterMessage(id: registeredWebSocket.id))
        } catch {
            req.logger.error("Failed to send websocket message \(error)")
        }
    }

    @Sendable
    func webSocketSettings(req: Request) async throws -> Response {
        guard let id = req.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }
        let webSocketSettings = try req.content.decode(WebSocketSettings.self)
        req.application.update(settings: webSocketSettings, for: id)
        return .init(status: .noContent)
    }
}
