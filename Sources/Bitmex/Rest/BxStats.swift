//
//  BxStats.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-03-09.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public extension BxRestAPI {
    /** Stats : Exchange Statistics */
    public var stats: Stats {
        return Stats(api: self)
    }

    public struct Stats {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get exchange-wide and per-series turnover and volume statistics */
        public var get: BxRequest<[BxResponse.Stats], BxParameters.None, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "stats")
        }

        /** Get historical exchange-wide and per-series turnover and volume statistics */
        public var history: BxRequest<[BxResponse.Stats.History], BxParameters.None, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "stats/history")
        }

        /** Get a summary of exchange statistics in USD */
        public var historyUSD: BxRequest<[BxResponse.Stats.HistoryUSD], BxParameters.None, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "stats/historyUSD")
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Stats: Decodable {
        public let rootSymbol: BxRootSymbol
        public let currency: BxCurrency
        public let volume24h: Double?
        public let turnover24h: Double
        public let openInterest: Double?
        public let openValue: Double

        public struct History: Decodable {
            public let date: Date
            public let rootSymbol: BxRootSymbol
            public let currency: BxCurrency
            public let volume: Double?
            public let turnover: Double
        }

        public struct HistoryUSD: Decodable {
            public let rootSymbol: BxRootSymbol
            public let currency: BxCurrency
            public let turnover24h: Double
            public let turnover30d: Double
            public let turnover365d: Double
            public let turnover: Double
        }
    }
}
