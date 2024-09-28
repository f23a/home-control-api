//
//  SendPushMessageCommand.swift
//  home-control-api
//
//  Created by Christoph Pageler on 28.09.24.
//

import Vapor
import APNSCore
import VaporAPNS

struct SendPushMessageCommand: AsyncCommand {
    struct Signature: CommandSignature {
        @Argument(name: "title")
        var title: String

        @Argument(name: "body")
        var body: String

        @Argument(name: "deviceToken")
        var deviceToken: String
    }

    var help: String { "Send Push Message" }

    func run(using context: CommandContext, signature: Signature) async throws {
        let notification = APNSAlertNotification(
            alert: .init(title: .raw(signature.title), body: .raw(signature.body)),
            expiration: .none,
            priority: .immediately,
            topic: "de.pageler.christoph.home-control.mobile"
        )
        try await context.application.apns.client.sendAlertNotification(
            notification,
            deviceToken: signature.deviceToken
        )
    }
}
