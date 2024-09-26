//
//  ElectricityConsumerPower.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 09.09.24.
//

import Fluent
import Vapor
import HomeControlKit

public final class ElectricityConsumerPower: Model, Content {
    public static let schema = "electricity_consumer_power"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "power_at")
    public var date: Date

    @Field(key: "power")
    public var power: Double

    @Field(key: "consumer_type")
    public var consumerType: ElectricityConsumerType

    @Timestamp(key: "createdAt", on: .create)
    public var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    public var updatedAt: Date?

    public init() { }

    public init(
        id: UUID?,
        date: Date,
        power: Double,
        consumerType: ElectricityConsumerType
    ) {
        self.id = id
        self.date = date
        self.power = power
        self.consumerType = consumerType
    }
}

extension ElectricityConsumerType: Content { }
