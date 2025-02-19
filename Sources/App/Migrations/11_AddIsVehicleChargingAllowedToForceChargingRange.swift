//
//  AddIsVehicleChargingAllowedToForceChargingRange.swift
//  home-control-api
//
//  Created by Christoph Pageler on 18.02.25.
//

import Fluent

struct AddIsVehicleChargingAllowedToForceChargingRange: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ForceChargingRange.schema)
            .field("is_vehicle_charging_allowed", .bool, .required, .sql(.default(true)))
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ForceChargingRange.schema)
            .deleteField("is_vehicle_charging_allowed")
            .update()
    }
}
