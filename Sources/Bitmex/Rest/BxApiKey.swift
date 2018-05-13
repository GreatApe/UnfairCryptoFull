//
//  BxApiKey.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-03-07.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public enum BxApiPermission: String, Decodable, StringConvertible {
    case order
    case orderCancel
    case withdraw
}

public extension BxRestAPI {
    /** APIKey : Persistent API Keys for Developers */
    public var apiKey: ApiKey {
        return ApiKey(api: self)
    }

    public struct ApiKey {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get your API Keys */
        public var get: BxRequest<[BxResponse.ApiKey], BxParameters.None, BxNo, BxYes, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "apiKey", security: .signature)
        }

        /** Create a new API Key */
        public var create: BxRequest<BxResponse.ApiKey, BxParameters.ApiKey, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "apiKey", method: .post, security: .signature)
        }

        /** Remove an API Key */
        public func delete(apiKeyID: String) -> BxRequest<BxResponse.Success, BxParameters.None, BxNo, BxNo, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "apiKey", method: .delete, security: .signature, params: ["apiKeyID" : apiKeyID])
        }

        /** Disable an API Key */
        public func disable(apiKeyID: String) -> BxRequest<BxResponse.ApiKey, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "apiKey/disable", method: .post, security: .signature, params: ["apiKeyID" : apiKeyID])
        }

        /** Enable an API Key */
        public func enable(apiKeyID: String) -> BxRequest<BxResponse.ApiKey, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "apiKey/enable", method: .post, security: .signature, params: ["apiKeyID" : apiKeyID])
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct ApiKey: Decodable {
        public let id: String
        public let secret: String?
        public let name: String
        public let nonce: Int
        public let cidr: String
        public let permissions: [BxApiPermission]
        public let enabled: Bool
        public let userId: Int
        public let created: Date
    }

    struct Success: Decodable {
        public let success: Bool
    }
}





