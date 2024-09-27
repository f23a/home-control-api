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
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(PushDevice.schema).delete()
    }
}
