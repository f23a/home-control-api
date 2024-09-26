//
//  InverterReading.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 09.09.24.
//

import Fluent
import Vapor
import HomeControlKit

public final class InverterReading: Model, Content {
    public static let schema = "inverter_readings"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "reading_at")
    public var readingAt: Date

    @Field(key: "solar_to_battery")
    public var solarToBattery: Double
    @Field(key: "solar_to_load")
    public var solarToLoad: Double
    @Field(key: "solar_to_grid")
    public var solarToGrid: Double

    @Field(key: "battery_to_load")
    public var batteryToLoad: Double
    @Field(key: "battery_to_grid")
    public var batteryToGrid: Double

    @Field(key: "grid_to_battery")
    public var gridToBattery: Double
    @Field(key: "grid_to_load")
    public var gridToLoad: Double

    @Field(key: "battery_level")
    public var batteryLevel: Double
    @Field(key: "battery_health")
    public var batteryHealth: Double
    @Field(key: "battery_temperature")
    public var batteryTemperature: Double

    @Field(key: "daily_pv_generation")
    public var dailyPVGeneration: Double
    @Field(key: "daily_import_energy")
    public var dailyImportEnergy: Double
    @Field(key: "daily_export_energy")
    public var dailyExportEnergy: Double
    @Field(key: "daily_direct_energy_consumption")
    public var dailyDirectEnergyConsumption: Double
    @Field(key: "daily_battery_discharge_energy")
    public var dailyBatteryDischargeEnergy: Double

    @Timestamp(key: "createdAt", on: .create)
    public var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    public var updatedAt: Date?

    public init() { }

    public init(
        id: UUID?,
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

public extension InverterReading {
    var storedInverterReading: HomeControlKit.StoredInverterReading? {
        guard let id, let createdAt else { return nil }
        return .init(
            id: id,
            reading: .init(
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
