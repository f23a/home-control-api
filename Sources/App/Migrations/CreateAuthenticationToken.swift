//
//  CreateAuthenticationToken.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 18.09.24.
//

import Fluent

struct CreateAuthenticationToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(AuthenticationToken.schema)
            .id()
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(AuthenticationToken.schema).delete()
    }
}
