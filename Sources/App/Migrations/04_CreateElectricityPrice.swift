//
//  CreateElectricityPrice.swift
//  home-control-api
//
//  Created by Christoph Pageler on 03.11.24.
//

import Fluent

struct CreateElectricityPrice: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ElectricityPrice.schema)
            .id()
            .field("starts_at", .datetime)
            .field("total", .double)
            .field("energy", .double)
            .field("tax", .double)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ElectricityPrice.schema).delete()
    }
}
