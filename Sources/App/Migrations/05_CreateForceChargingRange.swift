//
//  CreateForceChargingRange.swift
//  home-control-api
//
//  Created by Christoph Pageler on 10.10.24.
//

import Fluent

struct CreateForceChargingRange: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ForceChargingRange.schema)
            .id()
            .field("starts_at", .datetime)
            .field("ends_at", .datetime)
            .field("target_state_of_charge", .double)
            .field("state", .string)
            .field("source", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ForceChargingRange.schema).delete()
    }
}
