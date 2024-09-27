//
//  ElectricityMeterController.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Fluent
import Vapor
import HomeControlKit

struct ElectricityMeterController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let electrictyMeters = routes.grouped("electricity_meters")

        electrictyMeters.get(use: index)
        electrictyMeters.post(use: create)
        try electrictyMeters.group(":id") { electricityMeter in
            electricityMeter.delete(use: self.delete)

            try electricityMeter.register(collection: ElectricityMeterReadingController())
        }
    }

    @Sendable
    func index(req: Request) async throws -> [StoredElectricityMeter] {
        try await ElectricityMeter.query(on: req.db).all().compactMap { $0.storedElectricityMeter }
    }

    @Sendable
    func create(req: Request) async throws -> StoredElectricityMeter {
        let content = try req.content.decode(HomeControlKit.ElectricityMeter.self)
        let electricityMeter = ElectricityMeter(title: content.title)

        try await electricityMeter.save(on: req.db)
        guard let stored = electricityMeter.storedElectricityMeter else { throw Abort(.internalServerError) }
        return stored
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let electricityMeter = try await ElectricityMeter.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await electricityMeter.delete(on: req.db)
        return .noContent
    }
}

extension StoredElectricityMeter: @retroactive Content { }
