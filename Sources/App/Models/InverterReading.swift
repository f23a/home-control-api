//
//  InverterReading.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 09.09.24.
//

import Fluent
import Vapor
import HomeControlKit

final class InverterReading: Model, Content, @unchecked Sendable {
    static let schema = "inverter_readings"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "reading_at")
    var readingAt: Date

    @Field(key: "solar_to_battery")
    var solarToBattery: Double
    @Field(key: "solar_to_load")
    var solarToLoad: Double
    @Field(key: "solar_to_grid")
    var solarToGrid: Double

    @Field(key: "battery_to_load")
    var batteryToLoad: Double
    @Field(key: "battery_to_grid")
    var batteryToGrid: Double

    @Field(key: "grid_to_battery")
    var gridToBattery: Double
    @Field(key: "grid_to_load")
    var gridToLoad: Double

    @Field(key: "battery_level")
    var batteryLevel: Double
    @Field(key: "battery_health")
    var batteryHealth: Double
    @Field(key: "battery_temperature")
    var batteryTemperature: Double

    @Field(key: "daily_pv_generation")
    var dailyPVGeneration: Double
    @Field(key: "daily_import_energy")
    var dailyImportEnergy: Double
    @Field(key: "daily_export_energy")
    var dailyExportEnergy: Double
    @Field(key: "daily_direct_energy_consumption")
    var dailyDirectEnergyConsumption: Double
    @Field(key: "daily_battery_discharge_energy")
    var dailyBatteryDischargeEnergy: Double

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        readingAt: Date,
        solarToBattery: Double,
        solarToLoad: Double,
        solarToGrid: Double,
        batteryToLoad: Double,
        batteryToGrid: Double,
        gridToBattery: Double,
        gridToLoad: Double,
        batteryLevel: Double,
        batteryHealth: Double,
        batteryTemperature: Double,
        dailyPVGeneration: Double,
        dailyImportEnergy: Double,
        dailyExportEnergy: Double,
        dailyDirectEnergyConsumption: Double,
        dailyBatteryDischargeEnergy: Double
    ) {
        self.id = id
        self.readingAt = readingAt
        self.solarToBattery = solarToBattery
        self.solarToLoad = solarToLoad
        self.solarToGrid = solarToGrid
        self.batteryToLoad = batteryToLoad
        self.batteryToGrid = batteryToGrid
        self.gridToBattery = gridToBattery
        self.gridToLoad = gridToLoad
        self.batteryLevel = batteryLevel
        self.batteryHealth = batteryHealth
        self.batteryTemperature = batteryTemperature
        self.dailyPVGeneration = dailyPVGeneration
        self.dailyImportEnergy = dailyImportEnergy
        self.dailyExportEnergy = dailyExportEnergy
        self.dailyDirectEnergyConsumption = dailyDirectEnergyConsumption
        self.dailyBatteryDischargeEnergy = dailyBatteryDischargeEnergy
    }
}

extension InverterReading {
    var stored: Stored<HomeControlKit.InverterReading>? {
        guard let id, let createdAt else { return nil }
        return .init(
            id: id,
            value: .init(
                readingAt: readingAt,
                solarToBattery: solarToBattery,
                solarToLoad: solarToLoad,
                solarToGrid: solarToGrid,
                batteryToLoad: batteryToLoad,
                batteryToGrid: batteryToGrid,
                gridToBattery: gridToBattery,
                gridToLoad: gridToLoad,
                batteryLevel: batteryLevel,
                batteryHealth: batteryHealth,
                batteryTemperature: batteryTemperature,
                dailyPVGeneration: dailyPVGeneration,
                dailyImportEnergy: dailyImportEnergy,
                dailyExportEnergy: dailyExportEnergy,
                dailyDirectEnergyConsumption: dailyDirectEnergyConsumption,
                dailyBatteryDischargeEnergy: dailyBatteryDischargeEnergy
            ),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
