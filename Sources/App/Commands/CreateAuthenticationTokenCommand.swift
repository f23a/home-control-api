//
//  CreateAuthenticationTokenCommand.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Vapor

struct CreateAuthenticationTokenCommand: AsyncCommand {
    struct Signature: CommandSignature { }

    var help: String { "Create Authentication Tokne" }

    func run(using context: CommandContext, signature: Signature) async throws {
        let authenticationToken = AuthenticationToken()
        try await authenticationToken.save(on: context.application.db)
        let id = try authenticationToken.requireID()
        context.console.print("Token: \(id)")
    }
}
