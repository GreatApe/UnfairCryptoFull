//
//  BxSettlement.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-03-08.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public extension BxRestAPI {
    /** Settlement : Historical Settlement Data */
    public var settlement: Settlement {
        return Settlement(api: self)
    }

    public struct Settlement {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get settlement history */
        public var get: BxRequest<[BxResponse.Settlement], BxParameters.Main, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "settlement")
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Settlement: Decodable {
        public let timestamp: Date
        public let symbol: BxSymbol
        public let settlementType: SettlementType
        public let settledPrice: Double
        public let optionStrikePrice: Double?
        public let optionUnderlyingPrice: Double?
        public let bankrupt: Double?
        public let taxBase: Double?
        public let taxRate: Double?

        public enum SettlementType: String, Decodable {
            case settlement = "Settlement"
        }
    }
}

