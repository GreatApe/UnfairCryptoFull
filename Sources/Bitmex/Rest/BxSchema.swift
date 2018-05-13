//
//  BxSchema.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-03-08.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public extension BxRestAPI {
    /** Schema : Dynamic Schemata for Developers */
    public var schema: Schema {
        return Schema(api: self)
    }

    public struct Schema {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get model schemata for data objects returned by this API */
        public var get: BxRequest<BxResponse.Schemata, BxParameters.Schema, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "schema")
        }

        /** Returns help text & subject list for websocket usage */
        public var websocketHelp: BxRequest<BxResponse.Schema.WebsocketHelp, BxParameters.None, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "schema/websocketHelp")
        }
    }
}

// MARK - Response

public extension BxResponse {
    public typealias Schemata = [String : Schema]

    public struct Schema: Decodable {
        public let keys: [String]
        public let types: [String : String]

        public struct WebsocketHelp: Decodable {
            public let info: String
            public let usage: String
            public let ops: [String]
            public let subscribe: String
            public let subscriptionSubjects: SubscriptionSubjects

            public struct SubscriptionSubjects: Decodable {
                public let authenticationRequired: [String]
                public let `public`: [String]
            }
        }
    }
}

// MARK - Decodable

public extension BxResponse.Schema {
    private enum CodingKeys: String, CodingKey {
        case keys, types
    }

    private enum SingleStringOrArray: Decodable {
        case single(String)
        case array([String])
        case dictionary([String : String])

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let string = try? container.decode(String.self) {
                self = .single(string)
            }
            else if let strings = try? container.decode([String].self) {
                self = .array(strings)
            }
            else {
                self = .dictionary(try container.decode([String : String].self))
            }
        }

        public var stringValue: String {
            switch self {
            case .single(let string): return string
            case .array(let strings): return "[\(strings.joined(separator: ", "))]"
            case .dictionary(let dict): return "{\(dict.map { "\($0): \($1)" }.joined(separator: ", "))}"
            }
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        keys = try container.decode([String].self, forKey: .keys)
        types = try container.decode([String : SingleStringOrArray].self, forKey: .types).mapValues { $0.stringValue }
    }
}



