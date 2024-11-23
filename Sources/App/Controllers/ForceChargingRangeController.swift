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

        forceChargingRanges.post("query", use: query)
        forceChargingRanges.post(use: create)
        forceChargingRanges.group(":id") { forceChargingRange in
            forceChargingRange.put(use: update)
            forceChargingRange.delete(use: delete)
        }
    }

    @Sendable
    func query(req: Request) async throws -> QueryPage<Stored<HomeControlKit.ForceChargingRange>> {
        let query = try req.content.decode(HomeControlKit.ForceChargingRangeQuery.self)
        var builder = ForceChargingRange.query(on: req.db)
        for filter in query.filter {
            switch filter {
            case let .startsAt(filter):
                builder = builder.filter(\.$startsAt, filter.method.fluentMethod, filter.value)
            case let .endsAt(filter):
                builder = builder.filter(\.$endsAt, filter.method.fluentMethod, filter.value)
            case let .state(state):
                builder = builder.filter(\.$state == state)
            case let .source(source):
                builder = builder.filter(\.$source == source)
            }
        }
        switch query.sort.value {
        case .startsAt:
            builder = builder.sort(\.$startsAt, query.sort.direction.fluentDirection)
        case .endsAt:
            builder = builder.sort(\.$endsAt, query.sort.direction.fluentDirection)
        }
        let page = try await builder.paginate(.init(page: query.pagination.page, per: query.pagination.per))
        let storedItems = try page.items.map { model in
            guard let stored = model.stored else {
                throw Abort(.internalServerError)
            }
            return stored
        }
        return .init(
            items: storedItems,
            metadata: .init(
                page: page.metadata.page,
                per: page.metadata.per,
                total: page.metadata.total
            )
        )
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
    func update(req: Request) async throws -> Stored<HomeControlKit.ForceChargingRange> {
        guard let model = try await ForceChargingRange.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let content = try req.content.decode(HomeControlKit.ForceChargingRange.self)
        model.startsAt = content.startsAt
        model.endsAt = content.endsAt
        model.targetStateOfCharge = content.targetStateOfCharge
        model.state = content.state
        model.source = content.source

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
