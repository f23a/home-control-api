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
        let inverterReadings = routes.grouped("push_devices")
        inverterReadings.post("register", use: register)
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
}

//extension HomeControlKit.PushDevice: @retroactive Content { }
