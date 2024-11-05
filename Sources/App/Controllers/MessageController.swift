//
//  MessageController.swift
//  home-control-api
//
//  Created by Christoph Pageler on 16.10.24.
//

import Vapor
import Fluent
import HomeControlKit
import APNSCore
import VaporAPNS

struct MessageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let messages = routes.grouped("messages")

        messages.get(use: index)
        messages.post(use: create)
        messages.group(":id") { message in
            message.put(use: update)
            message.delete(use: delete)
            message.post("send_push_notifications", use: sendPushNotifications)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [Stored<HomeControlKit.Message>] {
        try await Message.query(on: req.db).all().compactMap { $0.stored }
    }

    @Sendable
    func create(req: Request) async throws -> Stored<HomeControlKit.Message> {
        let content = try req.content.decode(HomeControlKit.Message.self)
        let model = Message(
            messageType: content.type,
            title: content.title,
            body: content.body
        )

        try await model.save(on: req.db)
        guard let stored = model.stored else { throw Abort(.internalServerError) }
        return stored
    }

    @Sendable
    func update(req: Request) async throws -> Stored<HomeControlKit.Message> {
        guard let model = try await Message.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let content = try req.content.decode(HomeControlKit.Message.self)
        model.messageType = content.type
        model.title = content.title
        model.body = content.body

        try await model.save(on: req.db)
        guard let stored = model.stored else { throw Abort(.internalServerError) }
        return stored
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let model = try await Message.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await model.delete(on: req.db)
        return .noContent
    }

    @Sendable
    func sendPushNotifications(req: Request) async throws -> SendPushNotificationsResponse {
        guard let model = try await Message.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        let pushDevices = try await PushDeviceMessageTypeSettings
            .query(on: req.db)
            .with(\.$pushDevice)
            .filter(\.$messageType == model.messageType)
            .filter(\.$isEnabled == true)
            .all()
            .map { $0.pushDevice }

        let notification = APNSAlertNotification(
            alert: .init(title: .raw(model.title), body: .raw(model.body)),
            expiration: .none,
            priority: .immediately,
            topic: "de.pageler.christoph.home-control.mobile",
            payload: PushMessagePayload(messageType: model.messageType)
        )

        var response = SendPushNotificationsResponse()
        for pushDevice in pushDevices {
            do {
                try await req.apns.client.sendAlertNotification(notification, deviceToken: pushDevice.deviceToken)
                response.numberOfSentNotifications += 1
            } catch {
                response.numberOfFailedNotifications += 1
                req.logger.critical("Failed to send push notification to \(pushDevice.deviceToken): \(error.localizedDescription)")
            }
        }

        return response
    }

    struct SendPushNotificationsResponse: Content {
        var numberOfSentNotifications = 0
        var numberOfFailedNotifications = 0
    }
}
