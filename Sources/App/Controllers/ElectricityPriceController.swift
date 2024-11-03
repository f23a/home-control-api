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

        electrictyPrices.get(use: index)
        electrictyPrices.post(use: create)
        electrictyPrices.post("bulk", use: createBulk)
        electrictyPrices.group(":id") { electricityPrice in
            electricityPrice.delete(use: delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [Stored<HomeControlKit.ElectricityPrice>] {
        try await ElectricityPrice.query(on: req.db).all().compactMap { $0.stored }
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
