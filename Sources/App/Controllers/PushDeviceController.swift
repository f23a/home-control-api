//
//  PushDeviceController.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Vapor
import Fluent
import HomeControlKit

struct PushDeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let pushDevices = routes.grouped("push_devices")
        pushDevices.post(use: register)
        pushDevices.get(":deviceToken", ":messageType", "settings", use: getSettings)
        pushDevices.put(":deviceToken", ":messageType", "settings", use: updateSettings)
    }

    @Sendable
    func register(req: Request) async throws -> Response {
        let content = try req.content.decode(HomeControlKit.PushDevice.self)
        let count = try await PushDevice
            .query(on: req.db)
            .filter(\.$deviceToken == content.deviceToken)
            .count()
        if count == 0 {
            let newPushDevice = PushDevice(id: nil, deviceToken: content.deviceToken)
            try await newPushDevice.save(on: req.db)
        }
        return .init(status: .noContent)
    }

    @Sendable
    func getSettings(req: Request) async throws -> Stored<HomeControlKit.PushDeviceMessageTypeSettings> {
        guard
            let deviceToken = req.parameters.get("deviceToken"),
            let pushDevice = try await PushDevice.query(on: req.db).filter(\.$deviceToken == deviceToken).first(),
            let pushDeviceID = pushDevice.id,
            let messageTypeString = req.parameters.get("messageType"),
            let messageType = MessageType(rawValue: messageTypeString)
        else {
            throw Abort(.notFound)
        }

        let model = try await PushDeviceMessageTypeSettings
            .query(on: req.db)
            .filter(\.$pushDevice.$id == pushDeviceID )
            .filter(\.$messageType == messageType )
            .first()

        guard let stored = model?.stored else {
            throw Abort(.notFound)
        }
        return stored
    }

    @Sendable
    func updateSettings(req: Request) async throws -> Stored<HomeControlKit.PushDeviceMessageTypeSettings> {
        let content = try req.content.decode(HomeControlKit.PushDeviceMessageTypeSettings.self)
        guard
            let deviceToken = req.parameters.get("deviceToken"),
            let pushDevice = try await PushDevice.query(on: req.db).filter(\.$deviceToken == deviceToken).first(),
            let pushDeviceID = pushDevice.id,
            let messageTypeString = req.parameters.get("messageType"),
            let messageType = MessageType(rawValue: messageTypeString)
        else {
            throw Abort(.notFound)
        }

        let settings = try await PushDeviceMessageTypeSettings
            .query(on: req.db)
            .filter(\.$pushDevice.$id == pushDeviceID )
            .filter(\.$messageType == messageType )
            .first()

        let updateSettings = settings ?? .init(messageType: messageType, pushDeviceID: pushDeviceID, isEnabled: false)
        updateSettings.messageType = messageType
        updateSettings.isEnabled = content.isEnabled

        try await updateSettings.save(on: req.db)

        guard let stored = updateSettings.stored else { throw Abort(.internalServerError) }

        return stored
    }
}
