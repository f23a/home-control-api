//
//  CreatePushDevice.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Fluent

struct CreatePushDevice: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PushDevice.schema)
            .id()
            .field("device_token", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(PushDevice.schema).delete()
    }
}
