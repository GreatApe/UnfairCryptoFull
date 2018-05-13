//
//  BxPosition.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-02-24.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

public typealias Satoshi = Double

public enum BxMarginType {
    case isolated
    case cross
}

public enum BxLeverage {
    case fixed(Double)
    case crossMargin

    public var value: Double {
        switch self {
        case let .fixed(val): return val
        case .crossMargin: return 0
        }
    }
}

// MARK - Request

public extension BxRestAPI {
    /** Position : Summary of Open and Closed Positions */
    public var position: Position {
        return Position(api: self)
    }

    public struct Position {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get your positions */
        public var get: BxRequest<[BxResponse.Position], BxParameters.None, BxYes, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "position", security: .signature)
        }

        /** Enable isolated margin or cross margin per-position */
        public func isolate(_ symbol: BxSymbol, margin: BxMarginType = .isolated) -> BxRequest<BxResponse.Position, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            let params: BxParams =  ["symbol" : symbol, "enabled" : margin == .isolated]
            return BxRequest(api: api, endpoint: "position/isolate", method: .post, security: .signature, params: params)
        }

        /** Choose leverage for a position */
        public func leverage(_ symbol: BxSymbol, leverage: BxLeverage) -> BxRequest<BxResponse.Position, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "position/leverage", method: .post, security: .signature, params: ["symbol" : symbol, "leverage" : leverage.value])
        }

        /** Update your risk limit */
        public func riskLimit(_ symbol: BxSymbol, riskLimit: Satoshi) -> BxRequest<BxResponse.Position, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "position/riskLimit", method: .post, security: .signature, params: ["symbol" : symbol, "riskLimit" : riskLimit])
        }

        /** Transfer equity in or out of a position */
        public func transferMargin(_ symbol: BxSymbol, amount: Satoshi) -> BxRequest<BxResponse.Position, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "position/transferMargin", method: .post, security: .signature, params: ["symbol" : symbol, "amount" : amount])
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Position: Decodable { // FIXME: go through types
        public let account: Float
        public let symbol: BxSymbol
        public let currency: String
        public let underlying: String
        public let quoteCurrency: String
        public let commission: Float
        public let initMarginReq: Float
        public let maintMarginReq: Float
        public let riskLimit: Float
        public let leverage: Float
        public let crossMargin: Bool
        public let deleveragePercentile: Float
        public let rebalancedPnl: Float
        public let prevRealisedPnl: Float
        public let prevUnrealisedPnl: Float
        public let prevClosePrice: Float
        public let openingTimestamp: Date
        public let openingQty: Int
        public let openingCost: Float
        public let openingComm: Float
        public let openOrderBuyQty: Int
        public let openOrderBuyCost: Float
        public let openOrderBuyPremium: Float
        public let openOrderSellQty: Float
        public let openOrderSellCost: Float
        public let openOrderSellPremium: Float
        public let execBuyQty: Int
        public let execBuyCost: Float
        public let execSellQty: Int
        public let execSellCost: Float
        public let execQty: Int
        public let execCost: Float
        public let execComm: Float
        public let currentTimestamp: Date
        public let currentQty: Int
        public let currentCost: Float
        public let currentComm: Float
        public let realisedCost: Float
        public let unrealisedCost: Float
        public let grossOpenCost: Float
        public let grossOpenPremium: Float
        public let grossExecCost: Float
        public let isOpen: Bool
        public let markPrice: Float
        public let markValue: Float
        public let riskValue: Float
        public let homeNotional: Float
        public let foreignNotional: Float
        public let posState: String
        public let posCost: Float
        public let posCost2: Float
        public let posCross: Float
        public let posInit: Float
        public let posComm: Float
        public let posLoss: Float
        public let posMargin: Float
        public let posMaint: Float
        public let posAllowance: Float
        public let taxableMargin: Float
        public let initMargin: Float
        public let maintMargin: Float
        public let sessionMargin: Float
        public let targetExcessMargin: Float
        public let varMargin: Float
        public let realisedGrossPnl: Float
        public let realisedTax: Float
        public let realisedPnl: Float
        public let unrealisedGrossPnl: Float
        public let longBankrupt: Float
        public let shortBankrupt: Float
        public let taxBase: Float
        public let indicativeTaxRate: Float
        public let indicativeTax: Float
        public let unrealisedTax: Float
        public let unrealisedPnl: Float
        public let unrealisedPnlPcnt: Float
        public let unrealisedRoePcnt: Float
        public let simpleQty: Float
        public let simpleCost: Float
        public let simpleValue: Float
        public let simplePnl: Float
        public let simplePnlPcnt: Float
        public let avgCostPrice: Float
        public let avgEntryPrice: Float
        public let breakEvenPrice: Float
        public let marginCallPrice: Float
        public let liquidationPrice: Float
        public let bankruptPrice: Float
        public let timestamp: Date
        public let lastPrice: Float
        public let lastValue: Float
    }
}

