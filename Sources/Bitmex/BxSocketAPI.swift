//
//  BxSocketAPI.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-01-23.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation
import Starscream

public class BxSocketAPI: QuoteStreamer {
    private let baseUrl: URL
    private let apiId: String
    private let apiSecret: String

    private let socket: WebSocket
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private var orderbooks = [String : [Int64 : BxOrder]]()

    public init(baseUrl: String, apiId: String, apiSecret: String) {
        self.baseUrl = URL(string: baseUrl)!
        self.apiId = apiId
        self.apiSecret = apiSecret
        socket = WebSocket(url: self.baseUrl)
        socket.onText = onText
        socket.onConnect = onConnect
        socket.onDisconnect = onDisconnect
        socket.connect()
    }

    deinit {
        socket.disconnect()
    }

    private func onConnect() {
        state = .connected
//        let nonce = Bitmex.nonce
//        let sign = Bitmex.signature(secret: apiSecret, verb: .get, path: baseUrl.path, nonce: nonce)
//        send(.authKey(key: apiId, nonce: nonce, sign: sign))

//        send(.subscribe(.position))
        send(.subscribe(.orderBookL2))
    }

    private func onDisconnect(error: Error?) {
        state = .disconnected
        print("BITMEX DID DISCONNECT \(error?.localizedDescription ?? "-")")
    }

    private func send(_ op: BxOperation) {
        print("\n\(op.json)\n")
        socket.write(string: op.json)
    }

    // MARK - Streamer Protocol

    public var bids = [String : [Quote]]()
    public var asks = [String : [Quote]]()
    public var state: SocketState = .disconnected
    private var subscribers = [UUID : (Set<String>) -> Void]()

    public func subscribe(callback: @escaping (Set<String>) -> Void) -> UUID {
        let token = UUID()
        subscribers[token] = callback
        return token
    }

    public func unsubscribe(token: UUID) {
        subscribers[token] = nil
    }

    // MARK - Websocket

    private func onText(_ message: String) {
//        print("On TEXT"); print(message); print("\n\n\n\n"); return

        let json = message.data(using: .utf8)!

        do {
            let change = try decoder.decode(BxOrderbookChange.self, from: json)
//            print("Orderbook action: \(change.action.rawValue): \(change.data.count) x \(change.data.first?.symbol ?? "N/A")")

            var changedSymbols: Set<String> = []

            switch change.action {
            case .partial:
                for orderChange in change.data {
                    if orderbooks[orderChange.symbol] == nil {
                        orderbooks[orderChange.symbol] = [Int64 : BxOrder]()
                        changedSymbols.insert(orderChange.symbol)
                    }

                    orderbooks[orderChange.symbol]?[orderChange.id] = orderChange.order

                    if orderChange.order == nil { print("PARTIAL ERROR: \(orderChange)") }
                }
            case .insert:
                for orderChange in change.data {
                    orderbooks[orderChange.symbol]?[orderChange.id] = orderChange.order
                    changedSymbols.insert(orderChange.symbol)
                    if orderChange.order == nil { print("INSERT ERROR: \(orderChange)") }
                }
            case .delete:
                for orderChange in change.data {
                    orderbooks[orderChange.symbol]?[orderChange.id] = nil
                    changedSymbols.insert(orderChange.symbol)
                }
            case .update:
                for update in change.data {
                    if let oldOrder = orderbooks[update.symbol]?[update.id] {
                        orderbooks[update.symbol]?[update.id] = oldOrder.updated(update)
                        changedSymbols.insert(update.symbol)
                    }
                    else {
                        print("UPDATE ERROR: no old order")
                    }
                    // THis shouuld also work as rhs:
                    // orderbooks[update.symbol]?[update.id]?.updated(update)
                }
            }

            updateQuotes(changedSymbols)
        }
        catch {
            print("ERROR BX Parsing failed: \(error)")
        }
    }

    private func updateQuotes(_ changedSymbols: Set<String>) {
        for symbol in changedSymbols {
            bids[symbol] = orderbooks[symbol]?.values.filter { $0.side == .buy }.map { $0.quote }.sorted(by: >)
            asks[symbol] = orderbooks[symbol]?.values.filter { $0.side == .sell }.map { $0.quote }.sorted()
        }

        for callback in subscribers.values {
            callback(changedSymbols)
        }
    }

    subscript(_ symbol: String) -> (bids: [Quote], asks: [Quote]) {
        return (bids[symbol] ?? [], asks[symbol] ?? [])
    }
}


public struct BxOrderbookChange: Decodable {
    public enum Action: String, Decodable {
        case partial
        case update
        case insert
        case delete
    }

    public let action: Action
    public let data: [BxSubscriptionData]
}

public struct BxSubscriptionData: Decodable {
    public let symbol: String
    public let side: Side
    public let id: Int64
    public let size: Int?
    public let price: Double?

    public var order: BxOrder? {
        guard let size = size, let price = price else { return nil }
        return BxOrder(symbol: symbol, side: side, id: id, size: size, price: price)
    }
}

public struct BxOrder {
    public let symbol: String
    public let side: Side
    public let id: Int64
    public let size: Int
    public let price: Double

    public func updated(_ change: BxSubscriptionData) -> BxOrder {
        return BxOrder(symbol: symbol, side: side, id: id, size: change.size ?? size, price: change.price ?? price)
    }
}

extension BxOrder {
    var quote: Quote {
        return Quote(price: price, size: Double(size))
    }
}

public enum BxSubscription: String {
    case announcement         // Site announcements
    case chat                 // Trollbox chat
    case connectedcase        // Statistics of connected users/bots
    case instrument           // Instrument updates including turnover and bid/ask
    case insurance            // Daily Insurance Fund updates
    case liquidation          // Liquidation orders as they're entered into the book
    case orderBookL2          // Full level 2 orderBook
    case orderBook10          // Top 10 levels using traditional full book push
    case publicNotifications  // System-wide notifications (used for short-lived messages)
    case quote                // Top level of the book
    case quoteBin1m           // 1-minute quote bins
    case settlement           // Settlements
    case trade                // Live trades
    case tradeBin1m           // 1-minute ticker bins

    // The following subjects require authentication:

    case affiliate            // Affiliate status, such as total referred users & payout %
    case execution            // Individual executions; can be multiple per order
    case order                // Live updates on your orders
    case margin               // Updates on your current account balance and margin requirements
    case position             // Updates on your positions
    case privateNotifications // Individual notifications - currently not used
    case transact             // Deposit/Withdrawal updates
    case wallet               // Bitcoin address balance data, including total deposits & withdrawals
}

public enum BxOperation {
    case subscribe(BxSubscription)
    case authKey(key: String, nonce: Int64, sign: String)

    var op: String {
        switch self {
        case .subscribe: return "subscribe"
        case .authKey: return "authKey"
        }
    }

    var json: String {
        func bracketted(_ string: String) -> String { return "[" + string + "]" }
        func braced(_ string: String) -> String { return "{" + string + "}" }
        func quoted(_ string: String) -> String { return "\"" + string + "\"" }
        let comma = ","
        func keyValuePair(_ key: String, _ value: String) -> String { return quoted(key) + ":" + value }
        func operation(args: String...) -> String {
            return braced(keyValuePair("op", quoted(op)) + comma + keyValuePair("args", bracketted(args.joined(separator: comma))))
        }

        switch self {
        case let .subscribe(sub):
            return operation(args: quoted(sub.rawValue))
        case let .authKey(key: key, nonce: nonce, sign: sign):
            return operation(args: quoted(key), String(nonce), quoted(sign))
        }
    }
}



