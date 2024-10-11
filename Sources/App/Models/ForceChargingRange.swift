//
//  ForceChargingRange.swift
//  home-control-api
//
//  Created by Christoph Pageler on 10.10.24.
//

import Fluent
import Vapor
import HomeControlKit

final class ForceChargingRange: Model, Content, @unchecked Sendable  {
    static let schema = "force_charging_ranges"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "startsAt")
    var startsAt: Date

    @Field(key: "endsAt")
    var endsAt: Date

    @Field(key: "targetStateOfCharge")
    var targetStateOfCharge: Double

    @Field(key: "state")
    var state: ForceChargingRangeState

    @Field(key: "source")
    var source: ForceChargingRangeSource

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        startsAt: Date,
        endsAt: Date,
        targetStateOfCharge: Double,
        state: ForceChargingRangeState,
        source: ForceChargingRangeSource
    ) {
        self.id = id
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.state = state
        self.source = source
    }
}

extension ForceChargingRange {
    var stored: Stored<HomeControlKit.ForceChargingRange>? {
        guard let id, let createdAt else { return nil }
        return .init(
            id: id,
            value: .init(
                startsAt: startsAt,
                endsAt: endsAt,
                targetStateOfCharge: targetStateOfCharge,
                state: state,
                source: source
            ),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
