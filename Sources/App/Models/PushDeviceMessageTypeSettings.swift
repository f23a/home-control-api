//
//  PushDeviceMessageTypeSettings.swift
//  home-control-api
//
//  Created by Christoph Pageler on 16.10.24.
//

import Fluent
import Vapor
import HomeControlKit

final class PushDeviceMessageTypeSettings: Model, Content, @unchecked Sendable  {
    static let schema = "push_device_message_type_settings"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "message_type")
    var messageType: MessageType

    @Parent(key: "push_device_id")
    var pushDevice: PushDevice

    @Field(key: "is_enabled")
    var isEnabled: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, messageType: MessageType, pushDeviceID: PushDevice.IDValue, isEnabled: Bool) {
        self.id = id
        self.messageType = messageType
        self.$pushDevice.id = pushDeviceID
        self.isEnabled = isEnabled
    }
}

extension PushDeviceMessageTypeSettings {
    var stored: Stored<HomeControlKit.PushDeviceMessageTypeSettings>? {
        guard let id, let createdAt else { return nil }
        return .init(
            id: id,
            value: .init(isEnabled: isEnabled),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
