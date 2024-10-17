//
//  ElectricityMeterReadingController.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Fluent
import Vapor
import HomeControlKit

struct ElectricityMeterReadingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let electrictyMeterReadings = routes.grouped("readings")

        electrictyMeterReadings.get(use: index)
        electrictyMeterReadings.post(use: create)
        electrictyMeterReadings.get("latest", use: latest)
    }

    @Sendable
    func index(req: Request) async throws -> [Stored<HomeControlKit.ElectricityMeterReading>] {
        guard let model = try await ElectricityMeter.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        return try await model.$readings
            .query(on: req.db)
            .sort(\.$readingAt, .descending)
            .all()
            .compactMap { $0.stored }
    }

    @Sendable
    func create(req: Request) async throws -> Stored<HomeControlKit.ElectricityMeterReading> {
        guard let electricityMeter = try await ElectricityMeter.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let electricityMeterID = try electricityMeter.requireID()
        let content = try req.content.decode(HomeControlKit.ElectricityMeterReading.self)

        let model = ElectricityMeterReading(
            electricityMeterID: electricityMeterID,
            readingAt: content.readingAt,
            power: content.power
        )

        try await model.save(on: req.db)
        guard let stored = model.stored else {
            throw Abort(.internalServerError)
        }

        return stored
    }

    @Sendable
    func latest(req: Request) async throws -> Stored<HomeControlKit.ElectricityMeterReading> {
        guard let electricityMeter = try await ElectricityMeter.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let latest = try await electricityMeter.$readings.query(on: req.db).sort(\.$readingAt, .descending).first() else {
            throw Abort(.notFound)
        }
        guard let result = latest.stored else { throw Abort(.internalServerError) }
        return result
    }
}
