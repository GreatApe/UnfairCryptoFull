//
//  Bitmex.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-02-01.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation
import CryptoSwift

public struct Bitmex {
    
    // MARK - Public

    /** The web socket interface of Bitmex */
    public static let socket = BxSocketAPI(baseUrl: socketUrl, apiId: api.id, apiSecret: api.secret)

    /** The rest interface of Bitmex */
    public static let rest = BxRestAPI(baseUrl: restUrl, apiId: api.id, apiSecret: api.secret)

    // MARK - Private

    private init() {}
    private static let socketUrl = "wss://www.bitmex.com/realtime"
    private static let restUrl = "https://www.bitmex.com/api/v1/"

    /** Set up Bitmex with API id and API secret */
    public static func setup(id: String, secret: String) {
        api.id = id
        api.secret = secret
    }

    private class ApiDetails {
        var id = "---"
        var secret = "---"
    }

    private static let api = ApiDetails()

    // MARK - Internal

    static var nonce: Int64 { return Int64(round(Date().timeIntervalSinceReferenceDate*1000)) }

    static func signature(secret: String, verb: RestMethod, path: String, nonce: Int64, data: String = "") -> String {
        let string = verb.rawValue + path + String(nonce) + data
        return try! HMAC(key: secret, variant: .sha256).authenticate(Array(string.utf8)).toHexString()
    }
}

public struct BxInstrumentOld: Decodable, CustomStringConvertible {
    public let symbol: String
    public let rootSymbol: RootSymbol
    public let expiry: Date?

    public let fairBasisRate: Float

    public var description: String {
        return "\(symbol): \(Int(round(fairBasisRate*100)))%"
    }
}

//public struct BxPosition: Decodable, CustomStringConvertible {
//    public let account: Int
//    public let symbol: String
//    public let currency: String
//    public let underlying: String
//
//    public let lastValue: Float
//
//    public var description: String {
//        return "\(symbol): \(underlying) > \(lastValue)"
//    }
//}



