//
//  BxOrder.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-02-25.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

public enum BxTimeInForce: String, Decodable, StringConvertible {
    case day = "Day"
    case goodTillCancel = "GoodTillCancel"
    case immediateOrCancel = "ImmediateOrCancel"
    case fillOrKill = "FillOrKill"
}

public enum BxPegPriceType: String, Decodable, StringConvertible {
    case last = "LastPeg"
    case midPrice = "MidPricePeg"
    case market = "MarketPeg"
    case primary = "PrimaryPeg"
    case trailingStop = "TrailingStopPeg"
}

public enum BxOrderType: String, Decodable, StringConvertible {
    case limit = "Limit"
    case market = "Market"
    case marketWithLeftOverAsLimit = "MarketWithLeftOverAsLimit"
    case stop = "Stop"
    case stopLimit = "StopLimit"
    case marketIfTouched = "MarketIfTouched"
    case limitIfTouched = "LimitIfTouched"
    case pegged = "Pegged" // FIXME: does this exist?
}

// FIXME: can there be more than one?
public enum BxExecutionInstructions: String, Decodable, StringConvertible {
    /** Also known as a Post-Only order. If this order would have executed on placement, it will cancel instead */
    case participateDoNotInitiate = "ParticipateDoNotInitiate"

    /** Valid only for hidden orders (*displayQauntity* = 0). Use to only execute if the entire order would fill */
    case allOrNone = "AllOrNone"

    case markPrice = "MarkPrice"
    case lastPrice = "LastPrice"
    case indexPrice = "IndexPrice"

    /** *Close* implies *ReduceOnly*. A *Close* order will cancel other active limit orders with the same side and symbol if the open quantity exceeds the current position. This is useful for stops: by canceling these orders, a *Close* Stop is ensured to have the margin required to execute, and can only execute up to the full size of your position. If orderQty is not specified, a *Close* order has an orderQty equal to your current position's size */
    case close = "Close"

    /** A *ReduceOnly* order can only reduce your position, not increase it. If you have a *ReduceOnly* limit order that rests in the order book while the position is reduced by other orders, then its order quantity will be amended down or canceled. If there are multiple *ReduceOnly* orders the least agresssive will be amended first */
    case reduceOnly = "ReduceOnly"
}

public enum BxContingencyType: String, Decodable, StringConvertible {
    /** A very flexible version of the standard Stop/Take Profit technique. Multiple orders may be linked together using a single *clientOrderLinkId*. Send a contingencyType of *OneCancelsTheOther* on the orders. The first order that fully or partially executes (or activates for Stop orders) will cancel all other orders with the same *clientOrderLinkId* */
    case oneCancelsTheOther = "OneCancelsTheOther"

    /** Send a contingencyType of *OneTriggersTheOther* on the primary order and then subsequent orders with the same *clientOrderLinkId* will be not be triggered until the primary order fully executes */
    case oneTriggersTheOther = "OneTriggersTheOther"

    /** Send a contingencyType of *OneUpdatesTheOtherAbsolute* on the orders. Then as one order has a execution, other orders with the same *clientOrderLinkId* will have their order quantity amended down by the execution quantity */
    case oneUpdatesTheOtherAbsolute = "OneUpdatesTheOtherAbsolute"

    /** Send a contingencyType of *OneUpdatesTheOtherProportional* on the orders. Then as one order has a execution, other orders with the same *clientOrderLinkId* will have their order quantity reduced proportionally by the fill percentage */
    case oneUpdatesTheOtherProportional = "OneUpdatesTheOtherProportional"
}

// MARK - Creating orders

public struct BxCreateOrderRequest {
    private let api: BxRestAPI
    private let symbol: BxSymbol
    private let side: BxSide
    private let quantity: Double
    private let isSimpleQuantity: Bool

    init(api: BxRestAPI, symbol: BxSymbol, side: BxSide, quantity: Double, isSimpleQuantity: Bool) {
        self.api = api
        self.symbol = symbol
        self.side = side
        self.quantity = quantity
        self.isSimpleQuantity = isSimpleQuantity
    }

    /** The default order type */
    public func limit(price: Double) -> BxRequest<BxResponse.Order, BxParameters.CreateOrder, BxNo, BxNo, BxColumns.Custom> {
        return order(.limit, params: ["price" : price])
    }

    /** A traditional Market order. A Market order will execute until filled or your bankruptcy price is reached, at which point it will cancel */
    public func market(price: Double) -> BxRequest<BxResponse.Order, BxParameters.CreateOrder, BxNo, BxNo, BxColumns.Custom> {
        return order(.market, params: ["price" : price])
    }

    // FIXME: More comment
    /** A market order that, after eating through the order book as far as permitted by available margin, will become a limit order */
    public func marketWithLeftOverAsLimit(price: Double) -> BxRequest<BxResponse.Order, BxParameters.CreateOrder, BxNo, BxNo, BxColumns.Custom> {
        return order(.marketWithLeftOverAsLimit, params: ["price" : price])
    }

    /** A Stop Market order. When the stopPx is reached, the order will be entered into the book */ // FIXME: pegOffsetValue optional or not?
    public func stop(stopPx: Double, pegOffsetValue: Double? = nil) -> BxRequest<BxResponse.Order, BxParameters.PeggableOrder, BxNo, BxNo, BxColumns.Custom> {
        return peggableOrder(.stop, params: ["stopPx" : stopPx])
    }

    /** Like a Stop Market, but enters a Limit order instead of a Market order */ // FIXME: pegOffsetValue optional or not?
    public func stopLimit(stopPx: Double, price: Double) -> BxRequest<BxResponse.Order, BxParameters.PeggableOrder, BxNo, BxNo, BxColumns.Custom> {
        return peggableOrder(.stopLimit, params: ["price" : price, "stopPx" : stopPx])
    }

    // FIXME: pegOffsetValue optional or not?
    /** Similar to a Stop, but triggers are done in the opposite direction. Useful for Take Profit orders */
    public func marketIfTouched(stopPx: Double, pegOffsetValue: Double? = nil) -> BxRequest<BxResponse.Order, BxParameters.PeggableOrder, BxNo, BxNo, BxColumns.Custom> {
        return peggableOrder(.marketIfTouched, params: ["stopPx" : stopPx])
    }

    /** As above; use for Take Profit Limit orders */ // FIXME: pegOffsetValue optional or not?
    public func limitIfTouched(price: Double) -> BxRequest<BxResponse.Order, BxParameters.PeggableOrder, BxNo, BxNo, BxColumns.Custom> {
        return peggableOrder(.limitIfTouched, params: ["price" : price])
    }

    /** FIME: does this exist */
    public func pegged(price: Double) -> BxRequest<BxResponse.Order, BxParameters.CreateOrder, BxNo, BxNo, BxColumns.Custom> {
        return order(.pegged, params: ["price" : price])
    }

    // MARK - Private Helper Methods
    private func allParams(type: BxOrderType, params: BxParams) -> BxParams {
        let quantityKey = isSimpleQuantity ? "simpleOrderQty" : "orderQty"
        return params.merging([quantityKey : quantity, "ordType" : type]) { $1 }
    }

    private func order(_ type: BxOrderType, params: BxParams) -> BxRequest<BxResponse.Order, BxParameters.CreateOrder, BxNo, BxNo, BxColumns.Custom> {
        return BxRequest(api: api, endpoint: "order", method: .post, security: .signature, params: allParams(type: type, params: params))
    }

    private func peggableOrder(_ type: BxOrderType, params: BxParams) -> BxRequest<BxResponse.Order, BxParameters.PeggableOrder, BxNo, BxNo, BxColumns.Custom> {
        return BxRequest(api: api, endpoint: "order", method: .post, security: .signature, params: allParams(type: type, params: params))
    }
}

// MARK - Request

public extension BxRestAPI {
    /** Order : Placement, Cancellation, Amending, and History */
    public var order: Order {
        return Order(api: self)
    }

    public struct Order {
        private let api: BxRestAPI

        init(api: BxRestAPI) {
            self.api = api
        }

        /** Get your orders */
        public var get: BxRequest<[BxResponse.Order], BxParameters.Main, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "order", security: .signature)
        }

        /** Amend an order with a specified order id */
        public func amend(orderId: String) -> BxRequest<BxResponse.Order, BxParameters.AmendOrder, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "order", method: .put, security: .signature, params: ["orderID" : orderId])
        }

        /** Amend an order with a specified Client id. Client id may have been specified when creating the order */
        public func amend(clientId: String) -> BxRequest<BxResponse.Order, BxParameters.AmendOrder, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "order", method: .put, security: .signature, params: ["origClOrdID" : clientId])
        }

        /** Create an order */
        public func create(symbol: BxSymbol, side: BxSide, quantity: Double) -> BxCreateOrderRequest {
            return BxCreateOrderRequest(api: api, symbol: symbol, side: quantity < 0 ? .sell : side, quantity: quantity, isSimpleQuantity: false)
        }

        /** Create an order. A simple quantity is specified in terms of the number of units of the underlying instrument, e.g. Bitcoin */
        public func create(symbol: BxSymbol, side: BxSide, simpleQuantity: Int) -> BxCreateOrderRequest {
            return BxCreateOrderRequest(api: api, symbol: symbol, side: simpleQuantity < 0 ? .sell : side, quantity: Double(simpleQuantity), isSimpleQuantity: true)
        }

        /** Cancel one or more orders using Order Ids. Send multiple order Ids to cancel in bulk */
        public func cancel(orderIds: String...) -> BxRequest<[BxResponse.Order], BxParameters.Text, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "order", method: .delete, security: .signature, params: ["orderID" : orderIds])
        }

        /** Cancel one or more orders using Client Order Ids. Send multiple Ids to cancel in bulk */
        public func cancel(clientOrderIds: String...) -> BxRequest<[BxResponse.Order], BxParameters.Text, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "order", method: .delete, security: .signature, params: ["clOrdID" : clientOrderIds])
        }

        /** Cancels all of your orders */
        public var cancelAll: BxRequest<[BxResponse.Order], BxParameters.Text, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "order/all", method: .delete, security: .signature)
        }

        /** Cancels all of your orders for a given symbol*/
        public func cancelAll(symbol: BxSymbol) -> BxRequest<[BxResponse.Order], BxParameters.Text, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "order/all", method: .delete, security: .signature)
        }

//        /** Amend multiple orders for the same symbol */
//        public var bulkAmend: BxRequest<[BxResponse.Order], BxNo, BxParameters.Main, BxYes, BxColumns.Customs> {
//            return BxRequest(api: api, endpoint: "order/bulk", method: .put, security: .signature, params: ["xxx" : xxx])
//        }
//
//        /** Create multiple new orders for the same symbol */
//        public var bulkCreate: BxRequest<[BxResponse.Order], BxNo, BxParameters.Main, BxYes, BxColumns.Customs> {
//            return BxRequest(api: api, endpoint: "order/bulk", method: .post, security: .signature, params: ["xxx" : xxx])
//        }

        /** Automatically cancel all your orders after a specified timeout (in milliseconds). Set timeout to 0 to cancel timer. */
        public func cancelAllAfter(timeout: Int) -> BxRequest<BxResponse.CancelAllAfter, BxParameters.Main, BxNo, BxYes, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "order/cancelAllAfter", method: .post, security: .signature, params: ["timeout" : timeout])
        }
    }
}

// MARK - Response

// FIXME: fill
public extension BxResponse {
    public struct Order: Decodable {
        public let orderID: String
        public let clOrdID: String
        public let clOrdLinkID: String
        public let account: Double
        public let symbol: BxSymbol
        public let side: BxSide
        public let simpleOrderQty: Double
        public let orderQty: Double
        public let price: Double
        public let displayQty: Double
        public let stopPx: Double
        public let pegOffsetValue: Double
        public let pegPriceType: BxPegPriceType
        public let currency: BxCurrency
        public let settlCurrency: String // FIXME: BxCurrency?
        public let ordType: BxOrderType
        public let timeInForce: BxTimeInForce
        public let execInst: BxExecutionInstructions
        public let contingencyType: BxContingencyType
        public let exDestination: String
        public let ordStatus: String // FIXME: enum
        public let triggered: String
        public let workingIndicator: Bool
        public let ordRejReason: String
        public let simpleLeavesQty: Double
        public let leavesQty: Double
        public let simpleCumQty: Double
        public let cumQty: Double
        public let avgPx: Double
        public let multiLegReportingType: String // Fixme: enum?
        public let text: String
        public let transactTime: Date
        public let timestamp: Date
    }

    public struct CancelAllAfter: Decodable { }
}



