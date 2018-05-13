//
//  BxQuote.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-03-08.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public enum BxBinSize: String, StringConvertible {
    case perMinute = "1m"
    case per5Minutes = "5m"
    case hourly = "1h"
    case daily = "1d"
}

public extension BxRestAPI {
    /** Quote : Best Bid/Offer Snapshots & Historical Bins */
    public var quote: Quote {
        return Quote(api: self)
    }

    public struct Quote {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get Quotes */
        public var get: BxRequest<[BxResponse.Quote], BxParameters.Main, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "quote")
        }

        /** Get previous quotes in time buckets */
        public func bucketed(binSize: BxBinSize, partial: Bool = false) -> BxRequest<[BxResponse.Quote], BxParameters.Main, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "quote/bucketed", params: ["binSize" : binSize, "partial" : partial])
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Quote: Decodable {
        public let timestamp: Date
        public let symbol: String
        public let bidSize: Int
        public let bidPrice: Double
        public let askSize: Int
        public let askPrice: Double
    }
}
