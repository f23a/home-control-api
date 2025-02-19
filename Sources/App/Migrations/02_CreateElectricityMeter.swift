//
//  CreateElectricityMeter.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Fluent

struct CreateElectricityMeter: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ElectricityMeter.schema)
            .id()
            .field("title", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ElectricityMeter.schema).delete()
    }
}
