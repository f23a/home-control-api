//
//  CreatePushDeviceMessageTypeSettings.swift
//  home-control-api
//
//  Created by Christoph Pageler on 16.10.24.
//

import Fluent

struct CreatePushDeviceMessageTypeSettings: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PushDeviceMessageTypeSettings.schema)
            .id()
            .field("message_type", .string)
            .field("push_device_id", .uuid, .required, .references(PushDevice.schema, "id"))
            .field("is_enabled", .bool)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(PushDeviceMessageTypeSettings.schema).delete()
    }
}
