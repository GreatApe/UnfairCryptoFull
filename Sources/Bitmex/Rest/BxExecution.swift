//
//  BxExecution.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-03-08.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public extension BxRestAPI {
    /** Execution : Raw Order and Balance Data */
    public var execution: Execution {
        return Execution(api: self)
    }

    public struct Execution {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get all raw executions for your account */
        public var get: BxRequest<[BxResponse.Execution], BxParameters.Main, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "execution", security: .signature)
        }

        /** Get all balance-affecting executions. This includes each trade, insurance charge, and settlement */
        public var tradeHistory: BxRequest<[BxResponse.Execution], BxParameters.Main, BxNo, BxYes, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "execution/tradeHistory", security: .signature)
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Execution: Decodable {
        public let execID: String
        public let orderID: String
        public let clOrdID: String
        public let clOrdLinkID: String
        public let account: Double
        public let symbol: String
        public let side: String
        public let lastQty: Double
        public let lastPx: Double
        public let underlyingLastPx: Double
        public let lastMkt: String
        public let lastLiquidityInd: String
        public let simpleOrderQty: Double
        public let orderQty: Double
        public let price: Double
        public let displayQty: Double
        public let stopPx: Double
        public let pegOffsetValue: Double
        public let pegPriceType: String
        public let currency: String
        public let settlCurrency: String
        public let execType: String
        public let ordType: String
        public let timeInForce: String
        public let execInst: String
        public let contingencyType: String
        public let exDestination: String
        public let ordStatus: String
        public let triggered: String
        public let workingIndicator: Bool
        public let ordRejReason: String
        public let simpleLeavesQty: Double
        public let leavesQty: Double
        public let simpleCumQty: Double
        public let cumQty: Double
        public let avgPx: Double
        public let commission: Double
        public let tradePublishIndicator: String
        public let multiLegReportingType: String
        public let text: String
        public let trdMatchID: String
        public let execCost: Double
        public let execComm: Double
        public let homeNotional: Double
        public let foreignNotional: Double
        public let transactTime: Date
        public let timestamp: Date
    }
}
