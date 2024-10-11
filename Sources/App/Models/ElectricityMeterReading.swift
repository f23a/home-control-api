//
//  ElectricityMeterReading.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Fluent
import Vapor
import HomeControlKit

final class ElectricityMeterReading: Model, Content, @unchecked Sendable {
    static let schema = "electricity_meter_readings"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "electricity_meter_id")
    var electricityMeter: ElectricityMeter

    @Field(key: "reading_at")
    var readingAt: Date

    @Field(key: "power")
    var power: Double

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, electricityMeterID: ElectricityMeter.IDValue, readingAt: Date, power: Double) {
        self.id = id
        self.$electricityMeter.id = electricityMeterID
        self.readingAt = readingAt
        self.power = power
    }
}

extension ElectricityMeterReading {
    var stored: Stored<HomeControlKit.ElectricityMeterReading>? {
        guard let id, let createdAt else { return nil }
        return .init(
            id: id,
            value: .init(
                readingAt: readingAt,
                power: power
            ),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

