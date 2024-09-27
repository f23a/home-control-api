//
//  CreateElectricityMeterReadings.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Fluent

struct CreateElectricityMeterReadings: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ElectricityMeterReading.schema)
            .id()
            .field("electricity_meter_id", .uuid, .required, .references("electricity_meters", "id"))
            .field("reading_at", .datetime)
            .field("power", .double)
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ElectricityMeterReading.schema).delete()
    }
}
