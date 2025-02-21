//
//  Routes.swift
//  home-control-api
//
//  Created by Christoph Pageler on 25.09.24.
//

import Fluent
import Vapor

func routes(_ app: Application) throws {
    let protected = app
        .grouped(AuthenticationTokenAuthenticator())
        .grouped(AuthenticationToken.guardMiddleware())

    try protected.register(collection: ElectricityMeterController())
    try protected.register(collection: ElectricityPriceController())
    try protected.register(collection: ForceChargingRangeController())
    try protected.register(collection: InverterReadingController())
    try protected.register(collection: MessageController())
    try protected.register(collection: PushDeviceController())
    try protected.register(collection: SettingController())
    try protected.register(collection: WebSocketController())
}
