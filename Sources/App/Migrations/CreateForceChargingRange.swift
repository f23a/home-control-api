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
            .field("device_token", .string)
            .field("startsAt", .datetime)
            .field("endsAt", .datetime)
            .field("targetStateOfCharge", .double)
            .field("state", .string)
            .field("source", .string)
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ForceChargingRange.schema).delete()
    }
}
