//
//  CreateInverterReading.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 09.09.24.
//

import Fluent

struct CreateInverterReading: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(InverterReading.schema)
            .id()
            .field("reading_at", .datetime)
            .field("solar_to_battery", .double)
            .field("solar_to_load", .double)
            .field("solar_to_grid", .double)
            .field("battery_to_load", .double)
            .field("battery_to_grid", .double)
            .field("grid_to_battery", .double)
            .field("grid_to_load", .double)
            .field("battery_level", .double)
            .field("battery_health", .double)
            .field("battery_temperature", .double)
            .field("daily_pv_generation", .double)
            .field("daily_import_energy", .double)
            .field("daily_export_energy", .double)
            .field("daily_direct_energy_consumption", .double)
            .field("daily_battery_discharge_energy", .double)
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(InverterReading.schema).delete()
    }
}
