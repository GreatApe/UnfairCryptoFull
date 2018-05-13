//
//  BxLeaderboard.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-03-08.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

public enum BxRankingType: String, StringConvertible {
    case notional
    case roe = "ROE"
}

public extension BxRestAPI {
    /** Leaderboard : Information on Top Users */
    public var leaderboard: Leaderboard {
        return Leaderboard(api: self)
    }

    public struct Leaderboard {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get current leaderboard */
        public var get: BxRequest<[BxResponse.Leaderboard], BxParameters.Leaderboard, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "leaderboard")
        }

        /** Get your alias on the leaderboard */
        public var name: BxRequest<[BxResponse.Leaderboard.Name], BxParameters.None, BxNo, BxNo, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "leaderboard/name", security: .signature)
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Leaderboard: Decodable {
        public let name: String
        public let isRealName: Bool
        public let profit: Int

        public struct Name: Decodable {
            public let name: String
        }
    }
}
