//
//  ElectricityMeter.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Fluent
import Vapor
import HomeControlKit

final class ElectricityMeter: Model, Content, @unchecked Sendable {
    static let schema = "electricity_meters"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$electricityMeter)
    var readings: [ElectricityMeterReading]

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

extension ElectricityMeter {
    var stored: Stored<HomeControlKit.ElectricityMeter>? {
        guard let id, let createdAt else { return nil }
        return .init(
            id: id,
            value: .init(
                title: title
            ),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
