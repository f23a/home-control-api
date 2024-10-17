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

    @Field(key: "starts_at")
    var startsAt: Date

    @Field(key: "ends_at")
    var endsAt: Date

    @Field(key: "target_state_of_charge")
    var targetStateOfCharge: Double

    @Field(key: "state")
    var state: ForceChargingRangeState

    @Field(key: "source")
    var source: ForceChargingRangeSource

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
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
        self.targetStateOfCharge = targetStateOfCharge
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
