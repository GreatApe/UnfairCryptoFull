//
//  BxInsurance.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-02-25.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

// MARK - Request

public extension BxRestAPI {
    /** Insurance : Insurance Fund Data */
    public var insurance: Insurance {
        return Insurance(api: self)
    }

    public struct Insurance {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get insurance fund history */
        public var get: BxRequest<[BxResponse.Insurance], BxParameters.Main, BxNo, BxYes, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "insurance")
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct Insurance: Decodable {
        public let currency: String // FIXME: enum, rootsymbol?
        public let timestamp: Date
        public let walletBalance: Int
    }
}

