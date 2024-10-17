//
//  CreateMessages.swift
//  home-control-api
//
//  Created by Christoph Pageler on 16.10.24.
//

import Fluent

struct CreateMessages: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Message.schema)
            .id()
            .field("message_type", .string)
            .field("title", .string)
            .field("body", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Message.schema).delete()
    }
}
