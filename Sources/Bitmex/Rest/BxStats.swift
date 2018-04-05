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
        let rootSymbol: BxRootSymbol
        let currency: BxCurrency
        let volume24h: Double?
        let turnover24h: Double
        let openInterest: Double?
        let openValue: Double

        public struct History: Decodable {
            let date: Date
            let rootSymbol: BxRootSymbol
            let currency: BxCurrency
            let volume: Double?
            let turnover: Double
        }

        public struct HistoryUSD: Decodable {
            let rootSymbol: BxRootSymbol
            let currency: BxCurrency
            let turnover24h: Double
            let turnover30d: Double
            let turnover365d: Double
            let turnover: Double
        }
    }
}
