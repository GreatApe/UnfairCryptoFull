//
//  BxInstrument.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-02-24.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public extension BxRestAPI {
    /** Instrument : Tradeable Contracts, Indices, and History */
    public var instrument: Instrument {
        return Instrument(api: self)
    }

    public struct Instrument {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        // FIXME: check snr etc
        /** Get instruments */
        public var get: BxRequest<[BxResponse.Instrument], BxParameters.Main, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "instrument")
        }

        /** Get all active instruments and instruments that have expired in <24hrs */
        public var active: BxRequest<[BxResponse.Instrument.Active], BxParameters.None, BxNo, BxYes, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "instrument/active")
        }

        /** Helper method. Gets all active instruments and all indices. This is a join of the result of /indices and /active */
        public var activeAndIndices: BxRequest<[BxResponse.Instrument], BxParameters.None, BxNo, BxYes, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "instrument/activeAndIndices")
        }

        /** Return all active contract series and interval pairs */
        public var activeIntervals: BxRequest<BxResponse.Instrument.Intervals, BxParameters.None, BxNo, BxNo, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "instrument/activeIntervals")
        }

        /** Show constituent parts of an index */
        public var compositeIndex: BxRequest<[BxResponse.Instrument.Constituent], BxParameters.None, BxNo, BxYes, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "instrument/compositeIndex")
        }

        /** Get all price indices */
        public var indices: BxRequest<[BxResponse.Instrument], BxParameters.None, BxNo, BxYes, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "instrument/indices")
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Instrument: Decodable {
        public let symbol: BxSymbol
        public let rootSymbol: BxRootSymbol
        public let state: BxState
        public let typ: String?
        public let listing: Date?
        public let front: Date?
        public let expiry: Date?
        public let settle: Date?
        public let relistInterval: Date?
        public let inverseLeg: String?
        public let sellLeg: String?
        public let buyLeg: String?
        public let positionCurrency: String?
        public let underlying: String?
        public let quoteCurrency: String?
        public let underlyingSymbol: String?
        public let reference: String?
        public let referenceSymbol: String?
        public let calcInterval: Date?
        public let publishInterval: Date?
        public let publishTime: Date?
        public let maxOrderQty: Double?
        public let maxPrice: Double?
        public let lotSize: Double?
        public let tickSize: Double?
        public let multiplier: Double?
        public let settlCurrency: String?
        public let underlyingToPositionMultiplier: Double?
        public let underlyingToSettleMultiplier: Double?
        public let quoteToSettleMultiplier: Double?
        public let isQuanto: Bool?
        public let isInverse: Bool?
        public let initMargin: Double?
        public let maintMargin: Double?
        public let riskLimit: Double?
        public let riskStep: Double?
        public let limit: Double?
        public let capped: Bool?
        public let taxed: Bool?
        public let deleverage: Bool?
        public let makerFee: Double?
        public let takerFee: Double?
        public let settlementFee: Double?
        public let insuranceFee: Double?
        public let fundingBaseSymbol: String? // fixme
        public let fundingQuoteSymbol: String?
        public let fundingPremiumSymbol: String?
        public let fundingTimestamp: Date?
        public let fundingInterval: Date?
        public let fundingRate: Double?
        public let indicativeFundingRate: Double?
        public let rebalanceTimestamp: Date?
        public let rebalanceInterval: Date?
        public let openingTimestamp: Date?
        public let closingTimestamp: Date?
        public let sessionInterval: Date?
        public let prevClosePrice: Double?
        public let limitDownPrice: Double?
        public let limitUpPrice: Double?
        public let bankruptLimitDownPrice: Double?
        public let bankruptLimitUpPrice: Double?
        public let prevTotalVolume: Double?
        public let totalVolume: Double?
        public let volume: Double?
        public let volume24h: Double?
        public let prevTotalTurnover: Double?
        public let totalTurnover: Double?
        public let turnover: Double?
        public let turnover24h: Double?
        public let prevPrice24h: Double?
        public let vwap: Double?
        public let highPrice: Double?
        public let lowPrice: Double?
        public let lastPrice: Double?
        public let lastPriceProtected: Double?
        public let lastTickDirection: BxTickDirection
        public let lastChangePcnt: Double?
        public let bidPrice: Double?
        public let midPrice: Double?
        public let askPrice: Double?
        public let impactBidPrice: Double?
        public let impactMidPrice: Double?
        public let impactAskPrice: Double?
        public let hasLiquidity: Bool?
        public let openInterest: Double?
        public let openValue: Double?
        public let fairMethod: String?
        public let fairBasisRate: Double?
        public let fairBasis: Double?
        public let fairPrice: Double?
        public let markMethod: String // fixme: enum
        public let markPrice: Double?
        public let indicativeTaxRate: Double?
        public let indicativeSettlePrice: Double?
        public let settledPrice: Double?
        public let timestamp: Date?

        public struct Active: Decodable {
            public let symbol: BxSymbol
            public let rootSymbol: BxRootSymbol
            public let state: BxState
            public let typ: String
            public let listing: Date
            public let front: Date
            public let expiry: Date?
            public let settle: Date?
            public let relistInterval: Date?
            public let inverseLeg: String
            public let sellLeg: String
            public let buyLeg: String
            public let positionCurrency: String
            public let underlying: String
            public let quoteCurrency: String
            public let underlyingSymbol: String
            public let reference: String
            public let referenceSymbol: String
            public let calcInterval: Date?
            public let publishInterval: Date?
            public let publishTime: Date?
            public let maxOrderQty: Double
            public let maxPrice: Double
            public let lotSize: Double
            public let tickSize: Double
            public let multiplier: Double
            public let settlCurrency: String
            public let underlyingToPositionMultiplier: Double?
            public let underlyingToSettleMultiplier: Double?
            public let quoteToSettleMultiplier: Double?
            public let isQuanto: Bool
            public let isInverse: Bool
            public let initMargin: Double?
            public let maintMargin: Double?
            public let riskLimit: Double?
            public let riskStep: Double
            public let limit: Double?
            public let capped: Bool
            public let taxed: Bool
            public let deleverage: Bool
            public let makerFee: Double
            public let takerFee: Double
            public let settlementFee: Double
            public let insuranceFee: Double
            public let fundingBaseSymbol: String
            public let fundingQuoteSymbol: String
            public let fundingPremiumSymbol: String
            public let fundingTimestamp: Date?
            public let fundingInterval: Date?
            public let fundingRate: Double?
            public let indicativeFundingRate: Double?
            public let rebalanceTimestamp: Date?
            public let rebalanceInterval: Date?
            public let openingTimestamp: Date
            public let closingTimestamp: Date
            public let sessionInterval: Date
            public let prevClosePrice: Double?
            public let limitDownPrice: Double?
            public let limitUpPrice: Double?
            public let bankruptLimitDownPrice: Double?
            public let bankruptLimitUpPrice: Double?
            public let prevTotalVolume: Double
            public let totalVolume: Double
            public let volume: Double
            public let volume24h: Double
            public let prevTotalTurnover: Double
            public let totalTurnover: Double
            public let turnover: Double
            public let turnover24h: Double
            public let prevPrice24h: Double?
            public let vwap: Double?
            public let highPrice: Double?
            public let lowPrice: Double?
            public let lastPrice: Double?
            public let lastPriceProtected: Double?
            public let lastTickDirection: BxTickDirection
            public let lastChangePcnt: Double?
            public let bidPrice: Double
            public let midPrice: Double
            public let askPrice: Double
            public let impactBidPrice: Double?
            public let impactMidPrice: Double?
            public let impactAskPrice: Double?
            public let hasLiquidity: Bool
            public let openInterest: Double
            public let openValue: Double
            public let fairMethod: String
            public let fairBasisRate: Double?
            public let fairBasis: Double?
            public let fairPrice: Double
            public let markMethod: String // fixme: enum
            public let markPrice: Double
            public let indicativeTaxRate: Double?
            public let indicativeSettlePrice: Double?
            public let settledPrice: Double?
            public let timestamp: Date
        }

        public struct Constituent: Decodable {
            public let timestamp: Date
            public let symbol: String
            public let indexSymbol: String
            public let reference: String
            public let lastPrice: Double
            public let weight: Double
            public let logged: Date
        }

        public struct Intervals: Decodable {
            public let intervals: [BxInterval]
            public let symbols: [BxSymbol]
        }
    }
}

