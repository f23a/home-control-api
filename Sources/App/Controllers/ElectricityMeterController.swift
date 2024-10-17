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
            electricityMeter.delete(use: delete)

            try electricityMeter.register(collection: ElectricityMeterReadingController())
        }
    }

    @Sendable
    func index(req: Request) async throws -> [Stored<HomeControlKit.ElectricityMeter>] {
        try await ElectricityMeter.query(on: req.db).all().compactMap { $0.stored }
    }

    @Sendable
    func create(req: Request) async throws -> Stored<HomeControlKit.ElectricityMeter> {
        let content = try req.content.decode(HomeControlKit.ElectricityMeter.self)
        let model = ElectricityMeter(title: content.title)

        try await model.save(on: req.db)
        guard let stored = model.stored else { throw Abort(.internalServerError) }
        return stored
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let model = try await ElectricityMeter.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await model.delete(on: req.db)
        return .noContent
    }
}
