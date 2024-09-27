//
//  PushDevice.swift
//  home-control-api
//
//  Created by Christoph Pageler on 27.09.24.
//

import Fluent
import Vapor
import HomeControlKit

final class PushDevice: Model, Content, @unchecked Sendable  {
    static let schema = "push_devices"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "device_token")
    var deviceToken: String

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID?, deviceToken: String) {
        self.id = id
        self.deviceToken = deviceToken
    }
}
