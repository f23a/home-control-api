//
//  Setting.swift
//  home-control-api
//
//  Created by Christoph Pageler on 03.10.24.
//

import Fluent
import Vapor
import HomeControlKit

final class Setting: Model, Content, @unchecked Sendable  {
    static let schema = "settings"

    @ID(custom: "id", generatedBy: .user)
    var id: String?

    @Field(key: "encoded_content")
    var encodedContent: String

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: String, encodedContent: String) {
        self.id = id
        self.encodedContent = encodedContent
    }
}

extension Setting {
    var setting: HomeControlKit.Setting? {
        guard let id else { return nil }
        return .init(id: id)
    }
}
