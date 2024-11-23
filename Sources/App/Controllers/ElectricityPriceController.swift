//
//  ElectricityPriceController.swift
//  home-control-api
//
//  Created by Christoph Pageler on 03.11.24.
//

import Fluent
import Vapor
import HomeControlKit

struct ElectricityPriceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let electrictyPrices = routes.grouped("electricity_prices")

        electrictyPrices.post("query", use: query)
        electrictyPrices.post(use: create)
        electrictyPrices.post("bulk", use: createBulk)
        electrictyPrices.group(":id") { electricityPrice in
            electricityPrice.delete(use: delete)
        }
    }

    @Sendable
    func query(req: Request) async throws -> QueryPage<Stored<HomeControlKit.ElectricityPrice>> {
        let query = try req.content.decode(ElectricityPriceQuery.self)
        var builder = ElectricityPrice.query(on: req.db)
        for filter in query.filter {
            switch filter {
            case let .startsAt(filter):
                builder = builder.filter(\.$startsAt, filter.method.fluentMethod, filter.value)
            }
        }
        switch query.sort.value {
        case .startsAt:
            builder = builder.sort(\.$startsAt, query.sort.direction.fluentDirection)
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
    func create(req: Request) async throws -> Stored<HomeControlKit.ElectricityPrice> {
        let content = try req.content.decode(HomeControlKit.ElectricityPrice.self)
        let model = ElectricityPrice(
            startsAt: content.startsAt,
            total: content.total,
            energy: content.energy,
            tax: content.tax
        )

        try await model.save(on: req.db)
        guard let stored = model.stored else { throw Abort(.internalServerError) }
        return stored
    }

    @Sendable
    func createBulk(req: Request) async throws -> [Stored<HomeControlKit.ElectricityPrice>] {
        let content = try req.content.decode([HomeControlKit.ElectricityPrice].self)
        var result: [Stored<HomeControlKit.ElectricityPrice>] = []
        for content in content {
            let model = ElectricityPrice(
                startsAt: content.startsAt,
                total: content.total,
                energy: content.energy,
                tax: content.tax
            )

            try await model.save(on: req.db)
            guard let stored = model.stored else { throw Abort(.internalServerError) }
            result.append(stored)
        }
        return result
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let model = try await ElectricityPrice.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await model.delete(on: req.db)
        return .noContent
    }
}
