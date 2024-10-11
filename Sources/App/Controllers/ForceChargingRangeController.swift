//
//  ForceChargingRangeController.swift
//  home-control-api
//
//  Created by Christoph Pageler on 11.10.24.
//

import Vapor
import Fluent
import HomeControlKit

struct ForceChargingRangeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let forceChargingRanges = routes.grouped("force_charging_ranges")

        forceChargingRanges.get(use: index)
        forceChargingRanges.post(use: create)
        forceChargingRanges.group(":id") { forceChargingRange in
            forceChargingRange.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [Stored<HomeControlKit.ForceChargingRange>] {
        try await ForceChargingRange.query(on: req.db).all().compactMap { $0.stored }
    }

    @Sendable
    func create(req: Request) async throws -> Stored<HomeControlKit.ForceChargingRange> {
        let content = try req.content.decode(HomeControlKit.ForceChargingRange.self)
        let model = ForceChargingRange(
            startsAt: content.startsAt,
            endsAt: content.endsAt,
            targetStateOfCharge: content.targetStateOfCharge,
            state: content.state,
            source: content.source
        )

        try await model.save(on: req.db)
        guard let stored = model.stored else { throw Abort(.internalServerError) }
        return stored
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let model = try await ForceChargingRange.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await model.delete(on: req.db)
        return .noContent
    }
}
