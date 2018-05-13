//
//  BxAnnouncement.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-02-24.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public extension BxRestAPI {

    /** Announcement : Public Announcements */
    public var announcement: Announcement {
        return Announcement(api: self)
    }

    public struct Announcement {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get site announcements */
        public var all: BxRequest<[BxResponse.Announcement], BxParameters.None, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "announcement", timeFormat: .s)
        }

        /** Get urgent (banner) announcements */
        public var urgent: BxRequest<[BxResponse.Announcement], BxParameters.None, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "announcement/urgent", security: .signature, timeFormat: .s)
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Announcement: Decodable {
        public let id: Int
        public let link: String
        public let title: String
        public let content: String
        public let date: Date
    }
}

