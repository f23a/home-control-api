//
//  CreateElectricityConsumerPower.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 09.09.24.
//

import Fluent

struct CreateElectricityConsumerPower: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ElectricityConsumerPower.schema)
            .id()
            .field("power_at", .datetime)
            .field("power", .double)
            .field("consumer_type", .string)
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ElectricityConsumerPower.schema).delete()
    }
}
