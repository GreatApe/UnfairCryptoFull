//
//  BxOrderbook.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-02-24.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public extension BxRestAPI {
    /** OrderBook : Level 2 Book Data */
    public var orderbook: Orderbook {
        return Orderbook(api: self)
    }

    public struct Orderbook {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get current orderbook in vertical format for all symbols */
        public func get(symbol: BxSymbol) -> BxRequest<[BxResponse.Orderbook.Order], BxParameters.Orderbook, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "orderBook/L2", params: ["symbol" : symbol])
        }

        /** Get current orderbook in vertical format for a specific symbol */
        public func get(rootSymbol: BxRootSymbol) -> BxRequest<[BxResponse.Orderbook.Order], BxParameters.Orderbook, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "orderBook/L2", params: ["symbol" : rootSymbol])
        }
    }
}

// MARK - Response

public enum BxSide: String, Decodable, StringConvertible {
    case buy = "Buy"
    case sell = "Sell"
}

public extension BxResponse {
    public struct Orderbook {
        public struct Order: Decodable {
            public let symbol: BxSymbol
            public let id: Int
            public let side: BxSide
            public let size: Double // FIXME: int?
            public let price: Double
        }
    }
}

// MARK - Convenience



