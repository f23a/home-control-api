//
//  Message.swift
//  home-control-api
//
//  Created by Christoph Pageler on 16.10.24.
//

import Fluent
import Vapor
import HomeControlKit

final class Message: Model, Content, @unchecked Sendable  {
    static let schema = "messages"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "message_type")
    var messageType: MessageType

    @Field(key: "title")
    var title: String

    @Field(key: "body")
    var body: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, messageType: MessageType, title: String, body: String) {
        self.id = id
        self.messageType = messageType
        self.title = title
        self.body = body
    }
}

extension Message {
    var stored: Stored<HomeControlKit.Message>? {
        guard let id, let createdAt else { return nil }
        return .init(
            id: id,
            value: .init(
                type: messageType,
                title: title,
                body: body
            ),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
