//
//  Configure.swift
//  home-control-api
//
//  Created by Christoph Pageler on 25.09.24.
//

import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import VaporAPNS
import APNSCore
import APNS

// configures your application
public func configure(_ app: Application) async throws {
    var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
    tlsConfiguration.certificateVerification = .none

    app.http.server.configuration.hostname = "0.0.0.0"

    let pem = try Environment.require("APNS_PEM")
    let apnsConfig = APNSClientConfiguration(
        authenticationMethod: .jwt(
            privateKey: try .loadFrom(string: pem),
            keyIdentifier: try Environment.require("APNS_KEY_IDENTIFIER"),
            teamIdentifier: try Environment.require("APNS_TEAM_IDENTIFIER")
        ),
        environment: .development
    )
    app.apns.containers.use(
        apnsConfig,
        eventLoopGroupProvider: .shared(app.eventLoopGroup),
        responseDecoder: JSONDecoder(),
        requestEncoder: JSONEncoder(),
        as: .default
    )

    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: try Environment.require("DATABASE_HOST"),
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: try Environment.require("DATABASE_USERNAME"),
        password: try Environment.require("DATABASE_PASSWORD"),
        database: try Environment.require("DATABASE_NAME"),
        tlsConfiguration: tlsConfiguration
    ), as: .mysql)

    app.migrations.add(CreateInverterReading())
    app.migrations.add(CreateElectricityMeter())
    app.migrations.add(CreateElectricityMeterReadings())
    app.migrations.add(CreateAuthenticationToken())
    app.migrations.add(CreatePushDevice())

    app.asyncCommands.use(CreateAuthenticationTokenCommand(), as: "create-authentication-token")

    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    encoder.dateEncodingStrategy = .iso8601
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    try routes(app)
}