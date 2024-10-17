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

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$pushDevice)
    var messageTypeSettings: [PushDeviceMessageTypeSettings]

    init() { }

    init(id: UUID? = nil, deviceToken: String) {
        self.id = id
        self.deviceToken = deviceToken
    }
}
