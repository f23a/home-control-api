//
//  PushDeviceController.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Vapor
import Fluent

struct PushDeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let inverterReadings = routes.grouped("push_devices")
        inverterReadings.post("register", use: register)
    }

    @Sendable
    func register(req: Request) async throws -> Response {
        struct RegisterContent: Content {
            let token: String
        }
        let content = try req.content.decode(RegisterContent.self)
        let count = try await PushDevice.query(on: req.db).filter(\.$deviceToken == content.token).count()
        if count == 0 {
            let newPushDevice = PushDevice(id: nil, deviceToken: content.token)
            try await newPushDevice.save(on: req.db)
        }
        return .init(status: .noContent)
    }
}
