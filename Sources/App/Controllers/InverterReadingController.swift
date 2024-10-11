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

        inverterReadings.get(use: index)
        inverterReadings.post(use: create)
        inverterReadings.get("latest", use: latest)
    }

    @Sendable
    func index(req: Request) async throws -> [Stored<HomeControlKit.InverterReading>] {
        try await InverterReading
            .query(on: req.db)
            .sort(\.$readingAt, .descending)
            .all().compactMap { $0.stored }
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
    func latest(req: Request) async throws -> Stored<HomeControlKit.InverterReading> {
        guard let latest = try await InverterReading.query(on: req.db).sort(\.$readingAt, .descending).first() else {
            throw Abort(.notFound)
        }
        guard let result = latest.stored else { throw Abort(.internalServerError) }
        return result
    }
}
