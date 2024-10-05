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
    try protected.register(collection: InverterReadingController())
    try protected.register(collection: WebSocketController())
    try protected.register(collection: PushDeviceController())
    try protected.register(collection: SettingController())
}
