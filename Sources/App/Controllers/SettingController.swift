//
//  SettingsController.swift
//  home-control-api
//
//  Created by Christoph Pageler on 03.10.24.
//

import Vapor
import Fluent
import HomeControlKit

struct SettingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let settings = routes.grouped("settings")

        settings.group(":id") { setting in
            setting.get(use: self.get)
            setting.post(use: self.save)
        }
    }

    @Sendable
    func get(req: Request) async throws -> Response {
        guard let setting = try await Setting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let id = setting.id else { throw Abort(.internalServerError) }
        guard let data = Data(base64Encoded: setting.encodedContent) else {
            throw Abort(.internalServerError)
        }

        return .init(
            status: .ok,
            headers: .init([("Content-Type", "application/json")]),
            body: .init(data: data)
        )
    }

    @Sendable
    func save(req: Request) async throws -> Response {
        guard let id = req.parameters.get("id") else { throw Abort(.badRequest, reason: "Missing id") }
        let setting = try? await Setting.find(req.parameters.get("id"), on: req.db)

        let encodedContent: String
        switch id {
        case "adapter-sungrow-inverter":
            let content = try req.content.decode(HomeControlKit.AdapterSungrowInverterSetting.self)
            encodedContent = try JSONEncoder().encode(content).base64EncodedString()
        default:
            throw Abort(.badRequest, reason: "Invalid type of setting")
        }

        let updatedSettings = setting ?? .init()
        updatedSettings.id = id
        updatedSettings.encodedContent = encodedContent
        try await updatedSettings.save(on: req.db)

        if let setting = updatedSettings.setting {
            await req.application.webSocketRegister?.send(
                message: WebSocketDidSaveSettingMessage(setting: setting)
            )
        }

        return .init(status: .noContent)
    }
}

extension AdapterSungrowInverterSetting: @retroactive Content { }
