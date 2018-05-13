//
//  BxTrade.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-03-10.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public extension BxRestAPI {
    /** Trade : Individual & Bucketed Trades */
    public var trade: Trade {
        return Trade(api: self)
    }

    public struct Trade {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get Trades */
        public var get: BxRequest<[BxResponse.Trade], BxParameters.Main, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "trade")
        }

        /** Get previous trades in time buckets */
        public func bucketed(binSize: BxBinSize, partial: Bool = false) -> BxRequest<[BxResponse.Trade.BucketedTrade], BxParameters.Main, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "trade/bucketed", params: ["binSize" : binSize, "partial" : partial])
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Trade: Decodable {
        public let timestamp: Date
        public let symbol: BxSymbol
        public let side: BxSide
        public let size: Double
        public let price: Double
        public let tickDirection: BxTickDirection
        public let trdMatchID: String
        public let grossValue: Int
        public let homeNotional: Int
        public let foreignNotional: Int

        public struct BucketedTrade: Decodable {
            public let timestamp: Date
            public let symbol: BxSymbol
            public let open: Int
            public let high: Int
            public let low: Int
            public let close: Int
            public let trades: Int
            public let volume: Int
            public let vwap: Int
            public let lastSize: Int
            public let turnover: Int
            public let homeNotional: Int
            public let foreignNotional: Int
        }
    }
}
