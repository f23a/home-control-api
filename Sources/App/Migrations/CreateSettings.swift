//
//  CreateSetting.swift
//  home-control-api
//
//  Created by Christoph Pageler on 03.10.24.
//

import Fluent

struct CreateSetting: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Setting.schema)
            .field("id", .string, .identifier(auto: false))
            .field("encoded_content", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Setting.schema).delete()
    }
}
