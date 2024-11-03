//
//  ElectricityPrice.swift
//  home-control-api
//
//  Created by Christoph Pageler on 03.10.24.
//

import Fluent
import Vapor
import HomeControlKit

final class ElectricityPrice: Model, Content, @unchecked Sendable {
    static let schema = "electricity_prices"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "starts_at")
    var startsAt: Date

    @Field(key: "total")
    var total: Double

    @Field(key: "energy")
    var energy: Double

    @Field(key: "tax")
    var tax: Double

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, startsAt: Date, total: Double, energy: Double, tax: Double) {
        self.id = id
        self.startsAt = startsAt
        self.total = total
        self.energy = energy
        self.tax = tax
    }
}

extension ElectricityPrice {
    var stored: Stored<HomeControlKit.ElectricityPrice>? {
        guard let id, let createdAt else { return nil }
        return .init(
            id: id,
            value: .init(
                startsAt: startsAt,
                total: total,
                energy: energy,
                tax: tax
            ),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

