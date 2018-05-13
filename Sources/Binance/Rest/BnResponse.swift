//
//  BnResponse.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-02-04.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

public struct BnResponse {
    public struct Ping: Decodable { }

    public struct Time: Decodable {
        public let serverTime: Date
    }

    public struct ExchangeInfo: Decodable {
        public let timezone: String
        public let serverTime: Date

        struct RateLimit: Decodable {
            enum RateLimitType: String, Decodable {
                case requests = "REQUESTS"
                case orders = "ORDERS"
            }

            enum RateLimitInterval: String, Decodable {
                case second = "SECOND"
                case minute = "MINUTE"
                case day = "DAY"
            }
            public let rateLimitType: RateLimitType
            public let interval: RateLimitInterval
            public let limit: Int
        }

        public let rateLimits: [RateLimit]
        public enum ExchangeFilter: Decodable {
            case maxNumOrders(limit: Int)
            case maxAlgoOrders(limit: Int)
        }

        public let exchangeFilters: [ExchangeFilter] // FIXME: test

        public struct SymbolInfo: Decodable {
            public let symbol: BnSymbol

            enum SymbolStatus: String, Decodable {
                case preTrading = "PRE_TRADING"
                case trading = "TRADING"
                case postTrading = "POST_TRADING"
                case endOfDay = "END_OF_DAY"
                case halt = "HALT"
                case auctionMatch = "AUCTION_MATCH"
                case onBreak = "BREAK"
            }

            public let status: SymbolStatus

            public let baseAsset: BnAsset // enum: fixme: test
            public let baseAssetPrecision: Int
            public let quoteAsset: BnAsset // enum: fixme: test
            public let quotePrecision: Int

            public let orderTypes: [BnOrderType]
            public let icebergAllowed: Bool

            public enum Filter: Decodable {
                case priceFilter(minPrice: Double, maxPrice: Double, tickSize: Double)
                case lotSize(minQuantity: Double, maxQuantity: Double, stepSize: Double)
                case minNotional(minNotional: Double)
                case maxNumOrders(limit: Int)
                case maxAlgoOrders(limit: Int)
            }

            public let filters: [Filter]
        }

        public let symbols: [SymbolInfo]
    }

    public struct Depth: Decodable {
        public let lastUpdateId: Int
        public let bids: [Quote]
        public let asks: [Quote]
    }

    public struct Trade: Decodable {
        public let id: Int64
        public let price: Double
        public let quantity: Double
        public let time: Date
        public let isBuyerMaker: Bool
        public let isBestMatch: Bool
    }

    public typealias HistoricalTrade = Trade

    public struct AggTrade: Decodable {
        public let aggregateTradeId: Int64
        public let price: Double
        public let quantity: Double
        public let firstTradeId: Int64
        public let lastTradeId: Int64
        public let timestamp: Date
        public let isBuyerMaker: Bool
        public let isBestMatch: Bool
    }

    public struct Kline: Decodable {
        public let openTime: Date
        public let open: Double
        public let high: Double
        public let low: Double
        public let close: Double
        public let volume: Double
        public let closeTime: Date
        public let quoteAssetVolume: Double
        public let numberOfTrades: Int
        public let takerBuyBaseAssetVolume: Double
        public let takerBuyQuoteAssetVolume: Double
    }

    public struct Change24h: Decodable {
        public let symbol: BnSymbol
        public let priceChange: Double
        public let priceChangePercent: Double
        public let weightedAvgPrice: Double
        public let prevClosePrice: Double
        public let lastPrice: Double
        public let lastQty: Double
        public let bidPrice: Double
        public let askPrice: Double
        public let openPrice: Double
        public let highPrice: Double
        public let lowPrice: Double
        public let volume: Double
        public let quoteVolume: Double
        public let openTime: Date
        public let closeTime: Date
        public let fristId: Int64  // First tradeId
        public let lastId: Int64   // Last tradeId
        public let count: Int      // Trade count
    }

    public struct Price: Decodable {
        public let symbol: BnSymbol
        public let price: Double
    }

    public struct BookTicker: Decodable {
        public let symbol: BnSymbol
        public let bidPrice: Double
        public let bidQuantity: Double
        public let askPrice: Double
        public let askQuantity: Double
    }

    public struct Order {
        public struct Ack: Decodable {
            public let symbol: BnSymbol
            public let orderId: Int64
            public let clientOrderId: String
            public let transactTime: Date
        }

        public struct Result: Decodable {
            public let symbol: BnSymbol
            public let orderId: Int64
            public let clientOrderId: String
            public let transactTime: Date

            public let price: Double
            public let originalQuantity: Double
            public let executedQuantity: Double
            public let status: BnOrderStatus
            public let timeInForce: BnTimeInForce
            public let type: BnOrderType
            public let side: BnOrderSide
        }

        public struct Full: Decodable {
            public let symbol: BnSymbol
            public let orderId: Int64
            public let clientOrderId: String
            public let transactTime: Date

            public let price: Double
            public let originalQuantity: Double
            public let executedQuantity: Double
            public let status: BnOrderStatus
            public let timeInForce: BnTimeInForce
            public let type: BnOrderType
            public let side: BnOrderSide

            public struct Fill: Decodable {
                public let price: Double
                public let quantity: Double
                public let commission: Double
                public let commissionAsset: BnAsset // fixme: test
            }

            public let fills: [Fill]
        }
    }

    public struct TestOrder: Decodable { }

    public struct QueryOrder: Decodable {
        public let symbol: BnSymbol
        public let orderId: Int64
        public let clientOrderId: String
        public let price: Double
        public let originalQuantity: Double
        public let executedQuantity: Double
        public let status: BnOrderStatus
        public let timeInForce: BnTimeInForce
        public let type: BnOrderType
        public let side: BnOrderSide

        public let stopPrice: Double
        public let icebergQuantity: Double
        public let time: Date
        public let isWorking: Bool
    }

    public struct CancelOrder: Decodable {
        public let symbol: BnSymbol
        public let origClientOrderId: String
        public let orderId: Int64
        public let clientOrderId: String
    }

    public typealias OpenOrders = QueryOrder

    public typealias AllOrders = QueryOrder

    public struct Account: Decodable {
        public let makerCommission: Int
        public let takerCommission: Int
        public let buyerCommission: Int
        public let sellerCommission: Int

        public let canTrade: Bool
        public let canWithdraw: Bool
        public let canDeposit: Bool
        public let updateTime: Date

        struct Balance: Decodable {
            public let asset: BnAsset // fixme: test
            public let free: Double
            public let locked: Double
        }

        public let balances: [Balance]

        var nonEmptyBalances: [Balance] { return balances.filter { $0.free + $0.locked > 0 } }
    }

    public struct MyTrades: Decodable {
        public let id: Int64
        public let orderId: Int64
        public let price: Double
        public let quantity: Double
        public let commission: Double
        public let commissionAsset: BnAsset // fixme: test
        public let time: Date

        public let isBuyer: Bool
        public let isMaker: Bool
        public let isBestMatch: Bool
    }
}

// MARK - Extensions for Decodable Customisation

extension BnResponse.ExchangeInfo.ExchangeFilter {
    private enum CodingKeys: String, CodingKey {
        case filterType
        case limit
    }

    public init(from decoder: Decoder) throws {
        enum FilterType: String, Decodable {
            case maxNumOrders = "EXCHANGE_MAX_NUM_ORDERS"
            case maxAlgoOrders = "EXCHANGE_MAX_ALGO_ORDERS"
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let filterTypeRaw = try container.decode(String.self, forKey: .filterType)
        guard let filterType = FilterType(rawValue: filterTypeRaw) else {
            throw NSError(domain: "JSON", code: 555, userInfo: ["Issue" : "missing or unexpected filter type: \(filterTypeRaw)"])
        }

        switch filterType {
        case .maxNumOrders:
            let limit = try container.decode(Int.self, forKey: .limit)
            self = .maxNumOrders(limit: limit)
        case .maxAlgoOrders:
            let limit = try container.decode(Int.self, forKey: .limit)
            self = .maxAlgoOrders(limit: limit)
        }
    }
}

extension BnResponse.ExchangeInfo.SymbolInfo.Filter {
    private enum CodingKeys: String, CodingKey {
        case filterType
        case minPrice, maxPrice, tickSize
        case minQuantity = "minQty", maxQuantity = "maxQty", stepSize
        case minNotional
        case limit
    }

    public init(from decoder: Decoder) throws {
        enum FilterType: String, Decodable {
            case priceFilter = "PRICE_FILTER"
            case lotSize = "LOT_SIZE"
            case minNotional = "MIN_NOTIONAL"
            case maxNumOrders = "MAX_NUM_ORDERS"
            case maxAlgoOrders = "MAX_ALGO_ORDERS"
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let filterTypeRaw = try container.decode(String.self, forKey: .filterType)
        guard let filterType = FilterType(rawValue: filterTypeRaw) else {
            throw NSError(domain: "JSON", code: 555, userInfo: ["Issue" : "missing or unexpected filter type: \(filterTypeRaw)"])
        }

        switch filterType {
        case .priceFilter:
            let minPrice = try container.decode(String.self, forKey: .minPrice).toDouble()
            let maxPrice = try container.decode(String.self, forKey: .maxPrice).toDouble()
            let tickSize = try container.decode(String.self, forKey: .tickSize).toDouble()
            self = .priceFilter(minPrice: minPrice, maxPrice: maxPrice, tickSize: tickSize)
        case .lotSize:
            let minQuantity = try container.decode(String.self, forKey: .minQuantity).toDouble()
            let maxQuantity = try container.decode(String.self, forKey: .maxQuantity).toDouble()
            let stepSize = try container.decode(String.self, forKey: .stepSize).toDouble()
            self = .lotSize(minQuantity: minQuantity, maxQuantity: maxQuantity, stepSize: stepSize)
        case .minNotional:
            let minNotional = try container.decode(String.self, forKey: .minNotional).toDouble()
            self = .minNotional(minNotional: minNotional)
        case .maxNumOrders:
            let limit = try container.decode(Int.self, forKey: .limit)
            self = .maxNumOrders(limit: limit)
        case .maxAlgoOrders:
            let limit = try container.decode(Int.self, forKey: .limit)
            self = .maxAlgoOrders(limit: limit)
        }
    }
}

extension BnResponse.Trade {
    private enum CodingKeys: String, CodingKey {
        case id, price, quantity = "qty", time, isBuyerMaker, isBestMatch
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        price = try container.decode(String.self, forKey: .price).toDouble()
        quantity = try container.decode(String.self, forKey: .quantity).toDouble()
        time = try container.decode(Date.self, forKey: .time)
        isBuyerMaker = try container.decode(Bool.self, forKey: .isBuyerMaker)
        isBestMatch = try container.decode(Bool.self, forKey: .isBestMatch)
    }
}

extension BnResponse.AggTrade {
    private enum CodingKeys: String, CodingKey {
        case aggregateTradeId = "a"
        case price = "p"
        case quantity = "q"
        case firstTradeId = "f"
        case lastTradeId = "l"
        case timestamp = "T"
        case isBuyerMaker = "m"
        case isBestMatch = "M"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        aggregateTradeId = try container.decode(Int64.self, forKey: .aggregateTradeId)
        price =  try container.decode(String.self, forKey: .price).toDouble()
        quantity =  try container.decode(String.self, forKey: .quantity).toDouble()
        firstTradeId = try container.decode(Int64.self, forKey: .firstTradeId)
        lastTradeId = try container.decode(Int64.self, forKey: .lastTradeId)
        timestamp = try container.decode(Date.self, forKey: .lastTradeId)
        isBuyerMaker = try container.decode(Bool.self, forKey: .isBuyerMaker)
        isBestMatch = try container.decode(Bool.self, forKey: .isBestMatch)
    }
}

extension BnResponse.Kline {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        openTime = try container.decode(Date.self)
        open = try container.decode(String.self).toDouble()
        high = try container.decode(String.self).toDouble()
        low = try container.decode(String.self).toDouble()
        close = try container.decode(String.self).toDouble()
        volume = try container.decode(String.self).toDouble()
        closeTime = try container.decode(Date.self)
        quoteAssetVolume = try container.decode(String.self).toDouble()
        numberOfTrades = try container.decode(Int.self)
        takerBuyBaseAssetVolume = try container.decode(String.self).toDouble()
        takerBuyQuoteAssetVolume = try container.decode(String.self).toDouble()
    }
}

extension BnResponse.Change24h {
    private enum CodingKeys: String, CodingKey {
        case symbol, priceChange, priceChangePercent, weightedAvgPrice, prevClosePrice, lastPrice, lastQty, bidPrice, askPrice, openPrice, highPrice, lowPrice, volume, quoteVolume, openTime, closeTime, fristId, lastId, count
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(BnSymbol.self, forKey: .symbol)
        priceChange = try container.decode(String.self, forKey: .priceChange).toDouble()
        priceChangePercent = try container.decode(String.self, forKey: .priceChangePercent).toDouble()
        weightedAvgPrice = try container.decode(String.self, forKey: .weightedAvgPrice).toDouble()
        prevClosePrice = try container.decode(String.self, forKey: .prevClosePrice).toDouble()
        lastPrice = try container.decode(String.self, forKey: .lastPrice).toDouble()
        lastQty = try container.decode(String.self, forKey: .lastQty).toDouble()
        bidPrice = try container.decode(String.self, forKey: .bidPrice).toDouble()
        askPrice = try container.decode(String.self, forKey: .askPrice).toDouble()
        openPrice = try container.decode(String.self, forKey: .openPrice).toDouble()
        highPrice = try container.decode(String.self, forKey: .highPrice).toDouble()
        lowPrice = try container.decode(String.self, forKey: .lowPrice).toDouble()
        volume = try container.decode(String.self, forKey: .volume).toDouble()
        quoteVolume = try container.decode(String.self, forKey: .quoteVolume).toDouble()

        openTime = try container.decode(Date.self, forKey: .openTime)
        closeTime = try container.decode(Date.self, forKey: .closeTime)
        fristId = try container.decode(Int64.self, forKey: .fristId)
        lastId = try container.decode(Int64.self, forKey: .lastId)
        count = try container.decode(Int.self, forKey: .count)
    }
}

extension BnResponse.Price {
    private enum CodingKeys: String, CodingKey {
        case symbol, price
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(BnSymbol.self, forKey: .symbol)
        price = try container.decode(String.self, forKey: .price).toDouble()
    }
}

extension BnResponse.BookTicker {
    private enum CodingKeys: String, CodingKey {
        case symbol, bidPrice, bidQuantity = "bidQty", askPrice, askQuantity = "askQty"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(BnSymbol.self, forKey: .symbol)
        bidPrice = try container.decode(String.self, forKey: .bidPrice).toDouble()
        bidQuantity = try container.decode(String.self, forKey: .bidQuantity).toDouble()
        askPrice = try container.decode(String.self, forKey: .askPrice).toDouble()
        askQuantity = try container.decode(String.self, forKey: .askQuantity).toDouble()
    }
}

extension BnResponse.Account.Balance {
    private enum CodingKeys: String, CodingKey {
        case asset, free, locked
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        asset = try container.decode(BnAsset.self, forKey: .asset)
        free = try container.decode(String.self, forKey: .free).toDouble()
        locked = try container.decode(String.self, forKey: .locked).toDouble()
    }
}

extension BnResponse.Order.Result {
    private enum CodingKeys: String, CodingKey {
        case symbol, orderId, clientOrderId, transactTime, price, originalQuantity = "origQty", executedQuantity = "executedQty", status, timeInForce, type, side
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(BnSymbol.self, forKey: .symbol)
        orderId = try container.decode(Int64.self, forKey: .orderId)
        clientOrderId = try container.decode(String.self, forKey: .clientOrderId)
        transactTime = try container.decode(Date.self, forKey: .transactTime)

        price = try container.decode(String.self, forKey: .price).toDouble()
        originalQuantity = try container.decode(String.self, forKey: .originalQuantity).toDouble()
        executedQuantity = try container.decode(String.self, forKey: .executedQuantity).toDouble()
        status = try container.decode(BnOrderStatus.self, forKey: .status)
        timeInForce = try container.decode(BnTimeInForce.self, forKey: .timeInForce)
        type = try container.decode(BnOrderType.self, forKey: .type)
        side = try container.decode(BnOrderSide.self, forKey: .side)
    }
}

extension BnResponse.Order.Full.Fill {
    private enum CodingKeys: String, CodingKey {
        case price, quantity = "qty", commission, commissionAsset
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        price = try container.decode(String.self, forKey: .price).toDouble()
        quantity = try container.decode(String.self, forKey: .quantity).toDouble()
        commission = try container.decode(String.self, forKey: .commission).toDouble()
        commissionAsset = try container.decode(BnAsset.self, forKey: .commissionAsset)
    }
}

extension BnResponse.Order.Full {
    private enum CodingKeys: String, CodingKey {
        case symbol, orderId, clientOrderId, transactTime, price, originalQuantity = "origQty", executedQuantity = "executedQty", status, timeInForce, type, side, fills
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(BnSymbol.self, forKey: .symbol)
        orderId = try container.decode(Int64.self, forKey: .orderId)
        clientOrderId = try container.decode(String.self, forKey: .clientOrderId)
        transactTime = try container.decode(Date.self, forKey: .transactTime)

        price = try container.decode(String.self, forKey: .price).toDouble()
        originalQuantity = try container.decode(String.self, forKey: .originalQuantity).toDouble()
        executedQuantity = try container.decode(String.self, forKey: .executedQuantity).toDouble()
        status = try container.decode(BnOrderStatus.self, forKey: .status)
        timeInForce = try container.decode(BnTimeInForce.self, forKey: .timeInForce)
        type = try container.decode(BnOrderType.self, forKey: .type)
        side = try container.decode(BnOrderSide.self, forKey: .side)
        fills = try container.decode([Fill].self, forKey: .fills)
    }
}

extension BnResponse.QueryOrder {
    private enum CodingKeys: String, CodingKey {
        case symbol, orderId, clientOrderId, price, originalQuantity = "origQty", executedQuantity = "executedQty", status, timeInForce, type, side, isMaker, stopPrice, icebergQuantity = "icebergQty", time, isWorking
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(BnSymbol.self, forKey: .symbol)
        orderId = try container.decode(Int64.self, forKey: .orderId)
        clientOrderId = try container.decode(String.self, forKey: .clientOrderId)
        price = try container.decode(String.self, forKey: .price).toDouble()
        originalQuantity = try container.decode(String.self, forKey: .originalQuantity).toDouble()
        executedQuantity = try container.decode(String.self, forKey: .executedQuantity).toDouble()
        status = try container.decode(BnOrderStatus.self, forKey: .status)
        timeInForce = try container.decode(BnTimeInForce.self, forKey: .timeInForce)
        type = try container.decode(BnOrderType.self, forKey: .type)
        side = try container.decode(BnOrderSide.self, forKey: .side)
        stopPrice = try container.decode(String.self, forKey: .stopPrice).toDouble()
        icebergQuantity = try container.decode(String.self, forKey: .icebergQuantity).toDouble()
        time = try container.decode(Date.self, forKey: .time)
        isWorking = try container.decode(Bool.self, forKey: .isWorking)
    }
}

extension BnResponse.MyTrades {
    private enum CodingKeys: String, CodingKey {
        case id, orderId, price, quantity = "qty", commission, commissionAsset, time, isBuyer, isMaker, isBestMatch
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        orderId = try container.decode(Int64.self, forKey: .orderId)
        price = try container.decode(String.self, forKey: .price).toDouble()
        quantity = try container.decode(String.self, forKey: .quantity).toDouble()
        commission = try container.decode(String.self, forKey: .commission).toDouble()
        commissionAsset = try container.decode(BnAsset.self, forKey: .commissionAsset)
        time = try container.decode(Date.self, forKey: .time)
        isBuyer = try container.decode(Bool.self, forKey: .isBuyer)
        isMaker = try container.decode(Bool.self, forKey: .isMaker)
        isBestMatch = try container.decode(Bool.self, forKey: .isBestMatch)
    }
}
