//
//  BnRequest.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-02-06.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

public enum BnTimeInForce: String, Decodable, StringConvertible {
    case goodTillCancel = "GTC"
    case immediateOrCancel = "IOC"
    case fillOrKill = "FOK"
}

public enum BnOrderStatus: String, Decodable, StringConvertible {
    case new = "NEW"
    case partiallyFilled = "PARTIALLY_FILLED"
    case filled = "FILLED"
    case canceled = "CANCELED"
    case pendingCancel = "PENDING_CANCEL" // currently unused
    case rejected = "REJECTED"
    case expired = "EXPIRED"
}

public enum BnKlineInterval: String, Decodable, StringConvertible {
    case oneMinute = "1m"
    case threeMinutes = "3m"
    case fiveMinutes = "5m"
    case fifteenMinutes = "15m"
    case thirtyMinutes = "30m"
    case oneHour = "1h"
    case twoHours = "2h"
    case fourHours = "4h"
    case sixHours = "6h"
    case eightHours = "8h"
    case twelveHours = "12h"
    case oneDay = "1d"
    case threeDays = "3d"
    case oneWeek = "1w"
    case oneMonth = "1M"
}

public enum BnOrderType: String, Decodable, StringConvertible {
    case limit = "LIMIT"
    case market = "MARKET"
    case stopLoss = "STOP_LOSS"
    case stopLossLimit = "STOP_LOSS_LIMIT"
    case takeProfit = "TAKE_PROFIT"
    case takeProfitLimit = "TAKE_PROFIT_LIMIT"
    case limitMaker = "LIMIT_MAKER"
}

public enum BnOrderSide: String, Decodable, StringConvertible {
    case buy = "BUY"
    case sell = "SELL"
}

public protocol BnOrderResponse: Decodable { }

extension BnResponse.Order.Ack: BnOrderResponse { }
extension BnResponse.Order.Result: BnOrderResponse { }
extension BnResponse.Order.Full: BnOrderResponse { }

public enum BnOrderResponseType: String, StringConvertible {
    case ack = "ACK"
    case result = "RESULT"
    case full = "FULL"
}

public typealias BnQuery = [(String, StringConvertible?)]

public enum BnSecurity {
    case none
    case apiKey
    case signature
}

public func ignore<T>(x: T) { }

public struct BnRequest<T: Decodable> {
    private let api: BnRestAPI
    private let security: BnSecurity
    private let endpoint: String
    private let method: RestMethod
    private let query: BnQuery

    public init(api: BnRestAPI, security: BnSecurity = .none, endpoint: String, method: RestMethod = .get, query: BnQuery = []) {
        self.api = api
        self.security = security
        self.endpoint = endpoint
        self.method = method
        self.query = query
    }

    public func handled(by handler: @escaping (T) -> Void) {
        api.request(at: endpoint, with: method, query: query.compactMap(querify), security: security, handle: handler)
    }
}

public extension BnRestAPI {
    public var ping: BnRequest<BnResponse.Ping> {
        return BnRequest(api: self, endpoint: "v1/ping")
    }

    public var time: BnRequest<BnResponse.Time> {
        return BnRequest(api: self, endpoint: "v1/time")
    }

    public var exchangeInfo: BnRequest<BnResponse.ExchangeInfo> {
        return BnRequest(api: self, endpoint: "v1/exchangeInfo")
    }

    public func depth(symbol: BnSymbol, limit: Int? = nil) -> BnRequest<BnResponse.Depth> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v1/depth", query: [("symbol", symbol), ("limit", limit)])
    }

    public func trades(symbol: BnSymbol, limit: Int? = nil) -> BnRequest<[BnResponse.Trade]> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v1/trades", query: [("symbol", symbol), ("limit", limit)])
    }

    public func historicalTrades(symbol: BnSymbol, limit: Int? = nil, fromId: Int64? = nil) -> BnRequest<[BnResponse.HistoricalTrade]> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v1/historicalTrades", query: [("symbol", symbol), ("limit", limit), ("fromId", fromId)])
    }

    public func aggTrades(symbol: BnSymbol, fromId: Int64? = nil, startTime: Int64? = nil, endTime: Int64? = nil, limit: Int? = nil) -> BnRequest<[BnResponse.AggTrade]> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v1/aggTrades", query: [("symbol", symbol), ("fromId", fromId), ("startTime", startTime), ("endTime", endTime), ("limit", limit)])
    }

    public func klines(symbol: BnSymbol, interval: BnKlineInterval, limit: Int? = nil, startTime: Int64? = nil, endTime: Int64? = nil) -> BnRequest<[BnResponse.Kline]> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v1/klines", query: [("symbol", symbol), ("interval", interval), ("limit", limit), ("startTime", startTime), ("endTime", endTime)])
    }

    public func change24h(symbol: BnSymbol) -> BnRequest<BnResponse.Change24h> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v1/ticker/24hr", query: [("symbol", symbol)])
    }

    public var change24h: BnRequest<[BnResponse.Change24h]> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v1/ticker/24hr")
    }

    public func price(symbol: BnSymbol) -> BnRequest<BnResponse.Price> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v3/ticker/price", query: [("symbol", symbol)])
    }

    public var price: BnRequest<[BnResponse.Price]> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v3/ticker/price")
    }

    public func bookTicker(symbol: BnSymbol) -> BnRequest<BnResponse.BookTicker> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v3/ticker/bookTicker", query: [("symbol", symbol)])
    }

    public var bookTicker: BnRequest<[BnResponse.BookTicker]> {
        return BnRequest(api: self, security: .apiKey, endpoint: "v3/ticker/bookTicker")
    }

    public func queryOrder(symbol: BnSymbol, orderId: Int64? = nil, origClientOrderId: String? = nil) -> BnRequest<BnResponse.QueryOrder> {
        return BnRequest(api: self, security: .signature, endpoint: "v3/order", method: .get, query: [("symbol", symbol), ("orderId", orderId), ("origClientOrderId", origClientOrderId)])
    }

    public func cancelOrder(symbol: BnSymbol, orderId: Int64? = nil, origClientOrderId: String? = nil, newClientOrderId: String? = nil) -> BnRequest<BnResponse.CancelOrder> {
        return BnRequest(api: self, security: .signature, endpoint: "v3/order", method: .delete, query: [("symbol", symbol), ("orderId", orderId), ("origClientOrderId", origClientOrderId), ("newClientOrderId", newClientOrderId)])
    }

    public func openOrders(symbol: BnSymbol) -> BnRequest<BnResponse.OpenOrders> {
        return BnRequest(api: self, security: .signature, endpoint: "v3/openOrders", query: [("symbol", symbol)])
    }

    public var openOrders: BnRequest<[BnResponse.OpenOrders]> {
        return BnRequest(api: self, security: .signature, endpoint: "v3/openOrders")
    }

    public func allOrders(symbol: BnSymbol, orderId: Int64? = nil, limit: Int? = nil) -> BnRequest<[BnResponse.AllOrders]> {
        return BnRequest(api: self, security: .signature, endpoint: "v3/allOrders", query: [("symbol", symbol), ("orderId", orderId), ("limit", limit)])
    }

    public var account: BnRequest<BnResponse.Account> {
        return BnRequest(api: self, security: .signature, endpoint: "v3/account")
    }

    public func myTrades(symbol: BnSymbol, limit: Int? = nil, fromId: Int64? = nil) -> BnRequest<BnResponse.ExchangeInfo> {
        return BnRequest(api: self, security: .signature, endpoint: "v3/myTrades", query: [("symbol", symbol), ("limit", limit), ("fromId", fromId)])
    }

    public var order: BnOrderMaker {
        return BnOrderMaker(api: self)
    }
}

public struct BnOrderMaker {
    private let api: BnRestAPI

    public init(api: BnRestAPI) {
        self.api = api
    }

    //    Any LIMIT or LIMIT_MAKER type order can be made an iceberg order by sending an icebergQty.
    //    Any order with an icebergQty MUST have timeInForce set to GTC.

    public func limit(symbol: BnSymbol, side: BnOrderSide, timeInForce: BnTimeInForce, quantity: Double, price: Double, newClientOrderId: String? = nil, icebergQty: Double? = nil) -> BnOrder {
        return BnOrder(api, symbol: symbol, side: side, type: .limit, timeInForce: timeInForce, quantity: quantity, price: price, newClientOrderId: newClientOrderId, icebergQty: icebergQty)
    }

    public func market(symbol: BnSymbol, side: BnOrderSide, quantity: Double, newClientOrderId: String? = nil) -> BnOrder {
        return BnOrder(api, symbol: symbol, side: side, type: .market, quantity: quantity, newClientOrderId: newClientOrderId)
    }

    public func stopLoss(symbol: BnSymbol, side: BnOrderSide, quantity: Double, stopPrice: Double, newClientOrderId: String? = nil) -> BnOrder {
        return BnOrder(api, symbol: symbol, side: side, type: .stopLoss, quantity: quantity, stopPrice: stopPrice, newClientOrderId: newClientOrderId)
    }

    public func stopLossLimit(symbol: BnSymbol, side: BnOrderSide, timeInForce: BnTimeInForce, quantity: Double, price: Double, stopPrice: Double, newClientOrderId: String? = nil, icebergQty: Double? = nil) -> BnOrder {
        return BnOrder(api, symbol: symbol, side: side, type: .stopLossLimit, timeInForce: timeInForce, quantity: quantity, price: price, stopPrice: stopPrice, newClientOrderId: newClientOrderId, icebergQty: icebergQty)
    }

    public func takeProfit(symbol: BnSymbol, side: BnOrderSide, quantity: Double, stopPrice: Double, newClientOrderId: String? = nil) -> BnOrder {
        return BnOrder(api, symbol: symbol, side: side, type: .takeProfit, quantity: quantity, stopPrice: stopPrice, newClientOrderId: newClientOrderId)
    }

    public func takeProfitLimit(symbol: BnSymbol, side: BnOrderSide, timeInForce: BnTimeInForce, quantity: Double, price: Double, stopPrice: Double, newClientOrderId: String? = nil, icebergQty: Double? = nil) -> BnOrder {
        return BnOrder(api, symbol: symbol, side: side, type: .takeProfitLimit, timeInForce: timeInForce, quantity: quantity, price: price, stopPrice: stopPrice, newClientOrderId: newClientOrderId, icebergQty: icebergQty)
    }

    public func limitMaker(symbol: BnSymbol, side: BnOrderSide, quantity: Double, price: Double, newClientOrderId: String? = nil) -> BnOrder {
        return BnOrder(api, symbol: symbol, side: side, type: .limitMaker, quantity: quantity, price: price, newClientOrderId: newClientOrderId)
    }
}

public struct BnOrder {
    public func handled<T: BnOrderResponse>(by handler: @escaping (T) -> Void) {
        let responseType: BnOrderResponseType

        switch T.self {
        case is BnResponse.Order.Ack.Type: responseType = .ack
        case is BnResponse.Order.Result.Type: responseType = .result
        case is BnResponse.Order.Full.Type: responseType = .full
        default: fatalError()
        }

        let requestQuery = (query + [("newOrderRespType", responseType)]).compactMap(querify)
        api.request(at: "v3/order", with: .post, query: requestQuery, security: .signature, handle: handler)
    }

    public struct Test {
        public let order: BnOrder

        public func handled(by handler: @escaping (BnResponse.TestOrder) -> Void) {
            order.api.request(at: "v3/order/test", with: .post, query: order.query.compactMap(querify), security: .signature, handle: handler)
        }
    }

    public let api: BnRestAPI

    public let symbol: BnSymbol
    public let side: BnOrderSide
    public let type: BnOrderType
    public let timeInForce: BnTimeInForce?
    public let quantity: Double // DECIMAL
    public let price: Double? // DECIMAL

    public let newClientOrderId: String? // A unique id for the order. Automatically generated if not sent.

    public let stopPrice: Double? // DECIMAL Used with STOP_LOSS, STOP_LOSS_LIMIT, TAKE_PROFIT, and TAKE_PROFIT_LIMIT orders
    public let icebergQty: Double? // DECIMAL Used with LIMIT, STOP_LOSS_LIMIT, and TAKE_PROFIT_LIMIT to create an iceberg order

    public init(_ api: BnRestAPI, symbol: BnSymbol, side: BnOrderSide, type: BnOrderType, timeInForce: BnTimeInForce? = nil, quantity: Double, price: Double? = nil, stopPrice: Double? = nil, newClientOrderId: String? = nil, icebergQty: Double? = nil) {
        self.api = api

        self.symbol = symbol
        self.side = side
        self.type = type

        self.timeInForce = timeInForce
        self.quantity = quantity
        self.price = price
        self.stopPrice = stopPrice

        self.newClientOrderId = newClientOrderId
        self.icebergQty = icebergQty
    }

    public var test: Test {
        return Test(order: self)
    }

    private var query: BnQuery {
        return [("symbol", symbol), ("side", side), ("type", type), ("timeInForce", timeInForce), ("quantity", quantity), ("price", price), ("stopPrice", stopPrice), ("icebergQty", icebergQty), ("newClientOrderId", newClientOrderId)]
    }
}

private func querify(name: String, value: StringConvertible?) -> URLQueryItem? {
    guard let value = value else { return nil }
    return URLQueryItem(name: name, value: value.stringValue)
}

