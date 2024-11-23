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

        electrictyMeterReadings.post("query", use: query)
        electrictyMeterReadings.post(use: create)
    }

    @Sendable
    func query(req: Request) async throws -> QueryPage<Stored<HomeControlKit.ElectricityMeterReading>> {
        guard let model = try await ElectricityMeter.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let query = try req.content.decode(HomeControlKit.ElectricityMeterReadingQuery.self)
        var builder = model.$readings.query(on: req.db)
        for filter in query.filter {
            switch filter {
            case let .readingAt(filter):
                builder = builder.filter(\.$readingAt, filter.method.fluentMethod, filter.value)
            case let .power(filter):
                builder = builder.filter(\.$power, filter.method.fluentMethod, filter.value)
            }
        }
        switch query.sort.value {
        case .readingAt:
            builder = builder.sort(\.$readingAt, query.sort.direction.fluentDirection)
        case .power:
            builder = builder.sort(\.$power, query.sort.direction.fluentDirection)
        }
        let page = try await builder.paginate(.init(page: query.pagination.page, per: query.pagination.per))
        let storedItems = try page.items.map { model in
            guard let stored = model.stored else {
                throw Abort(.internalServerError)
            }
            return stored
        }
        return .init(
            items: storedItems,
            metadata: .init(
                page: page.metadata.page,
                per: page.metadata.per,
                total: page.metadata.total
            )
        )
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
}
