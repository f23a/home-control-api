//
//  InverterReadingController.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 09.09.24.
//

import Fluent
import Vapor
import HomeControlKit

struct InverterReadingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let inverterReadings = routes.grouped("inverter_readings")

        inverterReadings.post("query", use: query)
        inverterReadings.post(use: create)
    }

    @Sendable
    func create(req: Request) async throws -> Stored<HomeControlKit.InverterReading> {
        let content = try req.content.decode(HomeControlKit.InverterReading.self)
        let model = InverterReading(
            readingAt: content.readingAt,
            solarToBattery: content.solarToBattery,
            solarToLoad: content.solarToLoad,
            solarToGrid: content.solarToGrid,
            batteryToLoad: content.batteryToLoad,
            batteryToGrid: content.batteryToGrid,
            gridToBattery: content.gridToBattery,
            gridToLoad: content.gridToLoad,
            batteryLevel: content.batteryLevel,
            batteryHealth: content.batteryHealth,
            batteryTemperature: content.batteryTemperature,
            dailyPVGeneration: content.dailyPVGeneration,
            dailyImportEnergy: content.dailyImportEnergy,
            dailyExportEnergy: content.dailyExportEnergy,
            dailyDirectEnergyConsumption: content.dailyDirectEnergyConsumption,
            dailyBatteryDischargeEnergy: content.dailyBatteryDischargeEnergy
        )

        try await model.save(on: req.db)
        guard let stored = model.stored else { throw Abort(.internalServerError) }

        await req.application.webSocketRegister?.send(
            message: WebSocketDidCreateInverterReadingMessage(inverterReading: stored)
        )

        return stored
    }

    @Sendable
    func query(req: Request) async throws -> QueryPage<Stored<HomeControlKit.InverterReading>> {
        let query = try req.content.decode(InverterReadingQuery.self)
        var builder = InverterReading.query(on: req.db)
        for filter in query.filter {
            switch filter {
            case let .readingAt(filter):
                builder = builder.filter(\.$readingAt, filter.method.fluentMethod, filter.value)
            }
        }
        switch query.sort.value {
        case .readingAt:
            builder = builder.sort(\.$readingAt, query.sort.direction.fluentDirection)
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
}
