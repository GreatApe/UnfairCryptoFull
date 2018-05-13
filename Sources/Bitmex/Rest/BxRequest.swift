//
//  BxRequest.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-02-24.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation
import Alamofire

public typealias BxParams = [String : StringConvertible?]

public struct BxRequest<T: Decodable, P: BxParameterType, F: BxFilterable, L: BxLimitable, C: BxColumnType> {
    private let api: BxRestAPI
    private let endpoint: String
    private let method: RestMethod
    private let security: BxSecurity
    private let timeFormat: BxTimeFormat
    private let params: BxParams

    public init(api: BxRestAPI, endpoint: String, method: RestMethod = .get, security: BxSecurity = .none, timeFormat: BxTimeFormat = .ms, params: BxParams = [:]) {
        self.api = api
        self.security = security
        self.endpoint = endpoint
        self.method = method
        self.timeFormat = timeFormat
        self.params = params
    }

    private init(_ api: BxRestAPI, _ endpoint: String, _ method: RestMethod, _ security: BxSecurity, _ timeFormat: BxTimeFormat, _ params: BxParams = [:]) {
        self.api = api
        self.security = security
        self.endpoint = endpoint
        self.method = method
        self.timeFormat = timeFormat
        self.params = params
    }

    private func withParameters(_ parameters: BxParams) -> BxRequest<T, BxParameters.Chosen, F, L, C> {
        return BxRequest<T, BxParameters.Chosen, F, L, C>(api: api, endpoint: endpoint, method: method, security: security, timeFormat: timeFormat, params: params.merging(parameters) { $1 })
    }

    private func withMultiParameters(_ parameters: BxParams) -> BxRequest {
        return BxRequest(api: api, endpoint: endpoint, method: method, security: security, timeFormat: timeFormat, params: params.merging(parameters) { $1 })
    }

    // This type is just a workaround, we can't use S as type instead of T directly inside BxRequest
    private struct ColumnFactory<T2: Decodable> {
        let request: BxRequest
        func withColumns(_ columns: BxParams) -> BxRequest<T2, P, F, L, BxColumns.Chosen> {
            return BxRequest<T2, P, F, L, BxColumns.Chosen>(api: request.api, endpoint: request.endpoint, method: request.method, security: request.security, timeFormat: request.timeFormat, params: request.params.merging(columns) { $1 })
        }
    }

    /** Handle a successful request to the REST API with a closure taking the response type */
    public func handleSuccess(_ onSuccess: @escaping (T) -> Void) {
        let handler = { (result: Result<T>) in
            if case let .success(value) = result { onSuccess(value) }
        }
        handle(handler)
    }

    /** Handle the result of a request to the REST API, with one closure for success and one for errors */
    public func handle(onSuccess: @escaping (T) -> Void, onError: @escaping (Error) -> Void) {
        let handler = { (result: Result<T>) in
            switch result {
            case let .success(value): onSuccess(value)
            case let .failure(error): onError(error)
            }
        }
        handle(handler)
    }

    /** Handle the result of a request to the REST API, with a closure taking a Result enum */
    public func handle(_ handler: @escaping (Result<T>) -> Void) {
        api.customRequest(at: endpoint, with: method, params: params, security: security, timeFormat: timeFormat, handle: handler)
    }
}

// MARK - Meta

public protocol BxFilterable { }
public protocol BxLimitable { }

public class BxYes: BxFilterable, BxLimitable { }
public class BxNo: BxFilterable, BxLimitable { }

public protocol BxParameterType { }

public struct BxParameters {
    public class None: BxParameterType { }

    // Custom
    public class ApiKey: BxParameterType { }
    public class Chat: BxParameterType { }
    public class Leaderboard: BxParameterType { }
    public class Schema: BxParameterType { }
    public class Orderbook: BxParameterType { }
    public class CreateOrder: BxParameterType { }
    public class PeggableOrder: CreateOrder { }
    public class AmendOrder: BxParameterType { }

    // Simple
    public class Text: BxParameterType { }
    public class Filter: BxParameterType { }
    public class Enable: BxParameterType { }
    public class Overwrite: BxParameterType { }

    // Full
    public class Main: BxParameterType { }

    // Already chosen
    public class Chosen: BxParameterType { }
}

// MARK - Parameters

public typealias BxFilter = [String : String]

// Custom

extension BxRequest where P: BxParameters.ApiKey {
    /** Add parameters to a request for an API key */
    public func parameters(name: String = "", cidr: String = "", permissions: [BxApiPermission] = [], otpToken: String = "", enabled: Bool = false) -> BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters(["name" : name, "cidr" : cidr, "permissions" : permissions, "token" : otpToken, "enabled" : enabled])
    }
}

extension BxRequest where P: BxParameters.Chat {
    /** Select channel ID for a request for chat messages */
    public func channelID(_ id: Int) -> BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters(["channelID" : id])
    }
}

extension BxRequest where P: BxParameters.Leaderboard {
    /** Select ranking type to use when requesting leaderboard */
    public func method(_ rankingType: BxRankingType) -> BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters(["method" : rankingType])
    }
}

extension BxRequest where P: BxParameters.Schema {
    /** Select model to use when requesting API schema ??? */
    public func model(_ model: String) -> BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters(["model" : model])
    }
}

extension BxRequest where P: BxParameters.Orderbook {
    /** Select orderbook depth per side. */
    public func depth(_ depth: Int) -> BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters(["depth" : depth])
    }
}

extension BxRequest where P: BxParameters.CreateOrder {
    /** Set quantity to display in the book. Use 0 for a fully hidden order. */
    public func displayQuantity(_ quantity: Int) -> BxRequest {
        return withMultiParameters(["displayQuantity" : quantity])
    }

    /** Set Client Order Id. This user selected id will come back on the order and any related executions. Maximum 36 characters. */
    public func clientOrderId(_ id: Int) -> BxRequest {
        return withMultiParameters(["clOrdID" : id])
    }

    /** Set Client Order Link ID for contingent orders. Linked Orders are an advanced capability. It is very powerful, but its use requires careful coding and testing. Please follow the instructions carefully and use the Testnet Exchange while developing */
    public func clientOrderLinkId(_ id: Int, contingencyType: BxContingencyType) -> BxRequest {
        return withMultiParameters(["clOrdLinkID" : id, "contingencyType" : contingencyType])
    }

    // FIXME: Can there be several? can they have options?
    /** *AllOrNone* instruction requires *displayQty* to be 0. *MarkPrice*, *IndexPrice* or *LastPrice* instruction valid for *Stop*, *StopLimit*, *MarketIfTouched*, and *LimitIfTouched* orders. */
    public func executionInstructions(_ instructions: BxExecutionInstructions) -> BxRequest {
        return withMultiParameters(["execInst" : instructions])
    }

    /** Sets the Time In Force */
    public func timeInForce(_ time: BxTimeInForce) -> BxRequest {
        return withMultiParameters(["timeInForce" : time])
    }
}

extension BxRequest where P: BxParameters.PeggableOrder {
    // FIXME: Comment more
    /** Peg order */
    public func peg(offset: Double, type: BxPegPriceType) -> BxRequest {
        return withMultiParameters(["pegOffsetValue" : offset, "pegPriceType" : type])
    }
}

extension BxRequest where P: BxParameters.AmendOrder {
    // FIXME: Is this what they mean in the docs?
    /** Amend the Client Id. A Client Id must have been specified in this request for this to work */
    public func amendClientId(_ newValue: String) -> BxRequest {
        return withMultiParameters(["clOrdID" : newValue])
    }

    /** Amend order quantity in units of the underlying instrument (i.e. Bitcoin) */
    public func amendSimpleOrderQuantity(_ newValue: Double) -> BxRequest {
        return withMultiParameters(["simpleOrderQty" : newValue])
    }

    /** Amend order quantity in units of the instrument (i.e. contracts) */
    public func amendOrderQuantity(_ newValue: Int) -> BxRequest {
        return withMultiParameters(["orderQty" : newValue])
    }

    /** Leaves quantity in units of the underlying instrument (i.e. Bitcoin). Useful for amending partially filled orders */
    public func amendSimpleLeavesQuantity(_ newValue: Double) -> BxRequest {
        return withMultiParameters(["simpleLeavesQty" : newValue])
    }

    /** Leaves quantity in units of the instrument (i.e. contracts). Useful for amending partially filled orders */
    public func amendLeavesQuantity(_ newValue: Int) -> BxRequest {
        return withMultiParameters(["leavesQty" : newValue])
    }

    /** Amend the price of order. For 'Limit', 'StopLimit', and 'LimitIfTouched' orders */
    public func amendPrice(_ newValue: Double) -> BxRequest {
        return withMultiParameters(["price" : newValue])
    }

    /** Amend the trigger price for 'Stop', 'StopLimit', 'MarketIfTouched', and 'LimitIfTouched' orders. Use a price below the current price for stop-sell orders and buy-if-touched orders */
    public func amendStopPx(_ newValue: Double) -> BxRequest {
        return withMultiParameters(["stopPx" : newValue])
    }

    /** Amend the peg offset value of the order */
    public func amendPegOffsetValue(_ newValue: Double) -> BxRequest {
        return withMultiParameters(["pegOffsetValue" : newValue])
    }

    /** An annotation for the amendations. e.g. 'Adjust skew'. */
    public func addText(_ string: String) -> BxRequest {
        return withMultiParameters(["text" : string])
    }
}

// Simple
extension BxRequest where P: BxParameters.Text {
    /** An annotation. e.g. 'Spread Exceeded'. */
    public func addText(_ string: String) -> BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters(["text" : string])
    }
}

extension BxRequest where P: BxParameters.Enable {
    /** Set "enable" to true in the request */
    public var setEnabled: BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters(["enable" : true])
    }
}

extension BxRequest where P: BxParameters.Overwrite {
    /** Set "overwrite" to true in the request */
    public var setOverwrite: BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters(["overwrite" : true])
    }
}

// Full

extension BxRequest where P: BxParameters.Main { // Fixme: implement
    /** Set parameters in the request */
    public func addParameters(symbol: BxSymbol, startTime: Date? = nil, endTime: Date? = nil) -> BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters(["symbol" : symbol])
    }

    /** Set parameters in the request */
    public func addParameters(rootSymbol: BxRootSymbol, startTime: Date? = nil, endTime: Date? = nil) -> BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters([:])
    }

    // FIXME: check if interval also should be passed as symbol
    /** Set parameters in the request */
    public func addParameters(interval: BxInterval, startTime: Date? = nil, endTime: Date? = nil) -> BxRequest<T, BxParameters.Chosen, F, L, C> {
        return withParameters([:])
    }
}

// MARK - Filterable

extension BxRequest where F: BxYes { // FIXME: implement
    /** Apply a filter to the request */
    public func filter(with aFilter: BxFilter) -> BxRequest<T, P, BxNo, L, C> {
        return BxRequest<T, P, BxNo, L, C>(api, endpoint, method, security, timeFormat, params.merging(["filter" : aFilter]) { $1 })
    }
}

// MARK - Limitable

extension BxRequest where L: BxYes {
    /** Limit the responses by setting the maximum number and start id for response objects to receive*/
    public func limitResults(count: Int? = nil, startId: Int? = nil, reverse: Bool = false) -> BxRequest<T, P, F, BxNo, C> {
        let newParams: BxParams = ["count" : count, "start" : startId, "reverse" : reverse]
        return BxRequest<T, P, F, BxNo, C>(api, endpoint, method, security, timeFormat, params.merging(newParams) { $1 })
    }
}

// MARK - Columns

extension BxRequest where C: BxColumns.Custom {
    /** Provide an example object to receive a customised response. Must be Decodable. */
    public func includeColumns<T2: Decodable>(exampleObject s: T2) -> BxRequest<T2, P, F, L, BxColumns.Chosen> {
        let columns = Mirror(reflecting: s).children.compactMap { $0.label }
        let columnString = columns.joined(separator: ",")
        return ColumnFactory(request: self).withColumns(["columns" : columnString])
    }
}

extension BxRequest where C: BxColumns.Customs {
    /** Provide an example object to receive a customised response. Must be Decodable. */
    public func includeColumns<T2: Decodable>(exampleObject s: T2) -> BxRequest<[T2], P, F, L, BxColumns.Chosen> {
        let columns = Mirror(reflecting: s).children.compactMap { $0.label }
        let columnString = columns.joined(separator: ",")
        return ColumnFactory(request: self).withColumns(["columns" : columnString])
    }
}

public protocol BxColumnType { }

public struct BxColumns {
    public class Default: BxColumnType { }
    public class Custom: BxColumnType { }
    public class Customs: BxColumnType { }

    public class Chosen: BxColumnType { }
}

// MARK - 

public enum BxTFAType: String, StringConvertible {
    case googleAuthenticator = "GA"
    case yubikey = "Yubikey"
}

public struct BxPassword {
    public let old: String
    public let new: String
    public let confirmNew: String

    public init(_ oldPassword: String, _ newPassword: String, _ confirmNewPassword: String) {
        self.old = oldPassword
        self.new = newPassword
        self.confirmNew = confirmNewPassword
    }
}

public enum BxTimeframe: String, Decodable {
    case daily
    case weekly
    case monthly
    case quarterly
    case biquarterly
    case perpetual
}

public enum BxExpiration {
    public enum Month: String {
        case jan = "F", feb = "G", mar = "H", apr = "J", may = "K", jun = "M", jul = "N", aug = "Q", sep = "U", oct = "V", now = "X", dec = "Z"
    }

    case none
    case absolute(year: Int, month: Month)
    case relative(days: Int)
}

public typealias BxSymbol = String

//public struct BxSymbol: Decodable {
//    public let name: String
//    public let rootSymbol: BxRootSymbol
//    public let expiration: BxExpiration
//}

public typealias BxCurrency = String // Fixme: enum

public typealias BxRootSymbol = String

//public enum BxRootSymbol: String, Codable, StringConvertible {
//    case xbt = "XBT"
//    case ada = "ADA"
//    case bch = "BCH"
//    case dash = "DASH"
//    case eth = "ETH"
//    case etc = "ETC"
//    case ltc = "LTC"
//    case xmr = "XMR"
//    case xrp = "XRP"
//    case xlm = "XLM"
//    case zec = "ZEC"
//    case neo = "NEO"
//
//    case xbu = "XBU"
//    case bvol = "BVOL"
//    case xlt = "XLT"
//    case a50 = "A50"
//    case fct = "FCT"
//}

public enum BxState: String, Codable, StringConvertible {
    case open = "Open"
    case settled = "Settled"
    case unlisted = "Unlisted"
}

public struct BxPreferences: Codable, StringConvertible {
//    public let alertOnLiquidations: Bool?
//    public let animationsEnabled: Bool?
//    public let announcementsLastSeen: Date
//    public let chatChannelID: Double?
//    public let colorTheme: String?
//    public let currency: String
//    public let debug: Bool?
//    public let disableEmails: [String]?
    public let hideConfirmDialogs: [String]
//    public let hideConnectionModal: Bool?
//    public let hideFromLeaderboard: Bool
//    public let hideNameFromLeaderboard: Bool
//    public let hideNotifications: [String]?
//    public let locale: BxLocale
//    public let msgsSeen: [String]
//    //            public let orderBookBinning": {},
//    public let orderBookType: String?
//    public let orderClearImmediate: Bool
//    public let orderControlsPlusMinus: Bool?
    public let showLocaleNumbers: Bool
//    public let sounds: [String]?
//    public let strictIPCheck: Bool
//    public let strictTimeout: Bool
//    public let tickerGroup: String?
//    public let tickerPinned: Bool?
//    public let tradeLayout: String

    public var stringValue: String { // FIXME: how to serialise and send this?
//        public let encoder = JSONEncoder()
//        if let json = try? encoder.encode(self), let string = String(data: json, encoding: .utf8) {
//            let escaped = URLEncoding.init().escape(string)
//            print(escaped)
//            return escaped
//        }
//
        return ""
    }
}

public typealias BxTickDirection = String

//public enum BxTickDirection: String, Codable {
//    case minus = "MinusTick"
//    case zeroMinus = "ZeroMinusTick"
//    case zeroPlus = "ZeroPlusTick"
//    case plus = "PlusTick"
//}

public struct BxInterval: Decodable, StringConvertible {
    public let rootSymbol: BxRootSymbol
    public let timeframe: BxTimeframe

    public var stringValue: String {
        return rootSymbol.stringValue + ":" + timeframe.stringValue
    }
}

// MARK - Helpers

public extension BxExpiration {
    public init?(_ string: String) {
        if string.count == 3, let month = Month(rawValue: String(string.prefix(1))), let year = Int(string.suffix(2)) {
            self = .absolute(year: year, month: month)
        }
        else if string.count == 2, let last = string.last, last == "D", let numDays = Int(string.prefix(1)) {
            self = .relative(days: numDays)
        }
        else {
            self = .none
        }
    }
}

// MARK - Decodable

//public extension BxInterval {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let string = try container.decode(String.self)
//        let parts = string.split(separator: ":")
//        guard parts.count == 2, let rootSymbol = BxRootSymbol(rawValue: String(parts[0])), let timeframe = BxTimeframe(rawValue: String(parts[1])) else {
//            throw NSError(domain: "BxResponse.Instrument.Intervals.Interval error in root symbol: \(string)", code: 123, userInfo: nil)
//        }
//
//        self.rootSymbol = rootSymbol
//        self.timeframe = timeframe
//    }
//}

public extension BxInterval {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        let parts = string.split(separator: ":")
        guard parts.count == 2, let timeframe = BxTimeframe(rawValue: String(parts[1])) else {
            throw NSError(domain: "BxResponse.Instrument.Intervals.Interval error in root symbol: \(string)", code: 123, userInfo: nil)
        }

        self.rootSymbol = String(parts[0])
        self.timeframe = timeframe
    }
}

//public extension BxSymbol {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        name = try container.decode(String.self)
//        var string = name
//
//        while BxRootSymbol(rawValue: string) == nil {
//            guard string.count > 0 else {
//                throw NSError(domain: "BxSymbol error in root symbol: \(name)", code: 123, userInfo: nil)
//            }
//
//            string = String(string.dropLast())
//        }
//
//        rootSymbol = BxRootSymbol(rawValue: string)!
//
//        let remainder = String(name.suffix(name.count - string.count))
//
//        guard let expiry = BxExpiration(remainder) else {
//            throw NSError(domain: "BxSymbol error in expiration: \(remainder)", code: 123, userInfo: nil)
//        }
//
//        expiration = expiry
//    }
//}

public enum BxKey: String {
    case fee
}

