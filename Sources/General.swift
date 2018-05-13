//
//  General.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-01-26.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation
import Alamofire

public protocol StringConvertible { var stringValue: String { get } }
extension String: StringConvertible { public var stringValue: String { return self } }
extension Bool: StringConvertible { public var stringValue: String { return self ? "true" : "false" } }
extension Int: StringConvertible { public var stringValue: String { return String(self) } }
extension Int64: StringConvertible { public var stringValue: String { return String(self) } }
extension Double: StringConvertible { public var stringValue: String { return String(self) } }

public extension RawRepresentable where RawValue == String { public var stringValue: String { return rawValue } }

extension Array: StringConvertible where Element: StringConvertible {
    public var stringValue: String {
        return self.map { $0.stringValue }.joined(separator: ",")
    }
}

public protocol Subscribable {
    func subscribe(callback: @escaping (Set<String>) -> Void) -> UUID
    func unsubscribe(token: UUID)
}

public enum SocketState {
    case disconnected
    case connected
}

public enum RestMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"

    var http: HTTPMethod {
        return HTTPMethod(rawValue: rawValue)!
    }
}

public protocol QuoteStreamer: Subscribable {
    var bids: [String : [Quote]] { get }
    var asks: [String : [Quote]] { get }
    var state: SocketState { get }
}

public struct Quote: Decodable, Equatable, CustomStringConvertible {
    public let price: Double
    public let size: Double

    public init(price: Double, size: Double) {
        self.price = price
        self.size = size
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        price = try container.decode(String.self).toDouble()
        size = try container.decode(String.self).toDouble()
    }

    public var description: String {
        return "(price: \(price), size: \(size))"
    }
}

public enum Side: String, Decodable {
    case buy = "Buy"
    case sell = "Sell"
}

extension Quote: Comparable {
    public static func <(lhs: Quote, rhs: Quote) -> Bool {
        return  lhs.price < rhs.price
    }
}

public typealias QuoteBook = (bids: [Quote], asks: [Quote])

extension String {
    func toDouble() throws -> Double {
        guard let double = Double(self) else {
            throw NSError(domain: "JSON", code: 555, userInfo: ["Issue" : "Failed to convert string to double (\(self))"])
        }
        return double
    }
}

public enum RootSymbol: String, Decodable {
    public static var all: [RootSymbol] {
        return [.xbt, .ada, .bch, .dash, .eth, .etc, .ltc, .xmr, .xrp, .xlm, .zec, .neo]
    }

    case xbt = "XBT"
    case ada = "ADA"
    case bch = "BCH"
    case dash = "DASH"
    case eth = "ETH"
    case etc = "ETC"
    case ltc = "LTC"
    case xmr = "XMR"
    case xrp = "XRP"
    case xlm = "XLM"
    case zec = "ZEC"
    case neo = "NEO"

    public init?(bxSymbol: String) {
        guard let rootSymbol = RootSymbol.all.first(where: { bxSymbol.hasPrefix($0.bxRootSymbol) }) else {
            return nil
        }

        self = rootSymbol
    }

    public init?(bnSymbol: String) {
        guard let rootSymbol = RootSymbol.all.first(where: { bnSymbol == $0.bnStream }) else {
            return nil
        }

        self = rootSymbol
    }

    public var decimals: Int {
        switch self {
        case .xbt: return 1
        case .ada: return 8
        case .bch: return 4
        case .dash: return 6
        case .eth: return 5
        case .etc: return 6
        case .ltc: return 5
        case .xmr: return 6
        case .xrp: return 8
        case .xlm: return 8
        case .zec: return 5
        case .neo: return 5 // fixme
        }
    }

    public var bnStream: String {
        switch self {
        case .xbt: return "btcusdt"
        case .ada: return "adabtc"
        case .bch: return "bccbtc"
        case .dash: return "dashbtc"
        case .eth: return "ethbtc"
        case .etc: return "etcbtc"
        case .ltc: return "ltcbtc"
        case .xmr: return "xmrbtc"
        case .xrp: return "xrpbtc"
        case .xlm: return "xlmbtc"
        case .zec: return "zecbtc"
        case .neo: return "zecbtc" // fixme
        }
    }

    //    public var bnSymbol: String {
    //        switch self {
    //        case .xbt: return "btcusdt"
    //        case .ada: return "adabtc"
    //        case .bch: return "bccbtc"
    //        case .dash: return "dashbtc"
    //        case .eth: return "ethbtc"
    //        case .etc: return "etcbtc"
    //        case .ltc: return "ltcbtc"
    //        case .xmr: return "xmrbtc"
    //        case .xrp: return "xrpbtc"
    //        case .xlm: return "xlmbtc"
    //        case .zec: return "zecbtc"
    //        }
    //    }

    public var bxRootSymbol: String {
        return rawValue
    }
}


