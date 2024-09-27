//
//  AuthenticationToken.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 18.09.24.
//

import Fluent
import Vapor

final class AuthenticationToken: Model, Content, @unchecked Sendable {
    static let schema = "authentication_tokens"

    @ID(key: .id)
    public var id: UUID?

    public init() { }

    public init(id: UUID) {
        self.id = id
    }
}

extension AuthenticationToken: Authenticatable { }

struct AuthenticationTokenAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        guard let tokenUUID = UUID(uuidString: bearer.token) else {
            throw Abort(.unauthorized)
        }
        guard let authenticationToken = try await AuthenticationToken.find(tokenUUID, on: request.db) else {
            throw Abort(.unauthorized)
        }

        request.auth.login(authenticationToken)
    }
}
