//
//  InverterReadingController.swift
//  Home Control Server
//
//  Created by Christoph Pageler on 09.09.24.
//

import Fluent
import Vapor
import HomeControlKit

struct InverterReadingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let inverterReadings = routes.grouped("inverter_readings")
        inverterReadings.get("latest", use: latest)
    }

    func latest(req: Request) async throws -> HomeControlKit.StoredInverterReading {
        guard let latest = try await InverterReading.query(on: req.db).sort(\.$readingAt, .descending).first() else {
            throw Abort(.notFound)
        }
        guard let result = latest.storedInverterReading else { throw Abort(.internalServerError) }
        return result
    }
}

extension HomeControlKit.StoredInverterReading: Content { }
