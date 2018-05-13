//
//  BxNotification.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-03-08.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public extension BxRestAPI {
    /** Notification : Account Notifications */
    public var notification: Notification {
        return Notification(api: self)
    }

    public struct Notification {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get your current notifications */
        public var get: BxRequest<[BxResponse.Notification], BxParameters.None, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "notification", security: .signature)
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Notification: Decodable {
        public let id: Int
        public let date: Date
        public let title: String
        public let body: String
        public let ttl: Int
        public let type: String // fixme: enum
        public let closable: Bool
        public let persist: Bool
        public let waitForVisibility: Bool
        public let sound: String
    }
}
