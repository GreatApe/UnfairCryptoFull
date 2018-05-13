//
//  BxUser.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-03-09.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation

public enum BxTransactionType: String, Codable {
    case deposit = "Deposit"
    case realisedPNL = "RealisedPNL"
    case withdrawal = "Withdrawal"
    case total = "Total"
}

// MARK - Request

public extension BxRestAPI {
    /** User : Account Operations */
    public var user: User {
        return User(api: self)
    }

    public struct User {
        private let api: BxRestAPI

        public init(api: BxRestAPI) {
            self.api = api
        }

        /** Get your user model */
        public var get: BxRequest<BxResponse.User, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "user", security: .signature)
        }

        /** Update your password, name, and other attributes */
        public func update(firstname: String? = nil, lastname: String? = nil, password: BxPassword? = nil, username: String? = nil, country: String? = nil, pgpPubKey: String? = nil) -> BxRequest<BxResponse.User, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            let miscParams = ["firstname" : firstname, "lastname": lastname, "username" : username, "country" : country, "pgpPubKey" : pgpPubKey]
            let passwordParams = ["password" : password?.old, "passwordNew" : password?.new, "passwordNewConfirm" : password?.confirmNew]
            return BxRequest(api: api, endpoint: "user", method: .put, security: .signature, params: miscParams.merging(passwordParams) { $1 })
        }

        /** Get your current affiliate/referral status */
        public var affiliateStatus: BxRequest<BxResponse.User.AffiliateStatus, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "user/affiliateStatus", security: .signature)
        }

        /** Cancel a withdrawal */
        public func cancelWithdrawal(token: String) -> BxRequest<BxResponse.User.CancelWithdrawal, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "user/cancelWithdrawals", method: .post, security: .signature, params: ["token" : token])
        }

        /** Check if a referral code is valid */
        public func checkReferralCode(_ referralCode: String) -> BxRequest<BxResponse.User.CheckReferralCode, BxParameters.None, BxNo, BxNo, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "user/checkReferralCode", params: ["referralCode" : referralCode])
        }

        /** Get your account's commission status */
        public var commission: BxRequest<[BxResponse.User.Commission], BxParameters.None, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "user/commission", security: .signature)
        }

        /** Confirm your email address with a token */
        public func confirmEmail(token: String) -> BxRequest<BxResponse.User.ConfirmEmail, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "user/confirmEmail", method: .post, security: .signature, params: ["token" : token])
        }

        /** Confirm two-factor auth for this account. If using a Yubikey, simply send a token to this endpoint */
        public func confirmEnableTFA(type: BxTFAType, token: String) -> BxRequest<BxResponse.User.ConfirmEnableTFA, BxParameters.None, BxNo, BxNo, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "user/confirmEnableTFA", method: .post, security: .signature, params: ["type" : type, "token" : token])
        }

        /** Confirm a withdrawal */
        public func confirmWithdrawal(token: String) -> BxRequest<BxResponse.User.ConfirmWithdrawal, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "user/confirmWithdrawal", method: .post, params: ["token" : token])
        }

        // FIXME: what happens without currency?
        /** Get a deposit address */
        public func depositAddress(currency: BxCurrency) -> BxRequest<BxResponse.User.DepositAddress, BxParameters.None, BxNo, BxNo, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "user/depositAddress", method: .post, security: .signature, params: ["currency" : currency])
        }

        /** Disable two-factor auth for this account */
        public func disableTFA(type: BxTFAType, token: String) -> BxRequest<BxResponse.User.DisableTFA, BxParameters.None, BxNo, BxNo, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "user/disableTFA", method: .post, security: .signature, params: ["type" : type, "token" : token])
        }

        /** Log out of BitMEX */
        public var logout: BxRequest<BxResponse.User.Logout, BxParameters.None, BxNo, BxNo, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "user/logout", method: .post)
        }

        /** Log all systems out of BitMEX. This will revoke all of your account's access tokens, logging you out on all devices */
        public var logoutAll: BxRequest<BxResponse.User.LogoutAll, BxParameters.None, BxNo, BxNo, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "user/logoutAll", method: .post, security: .signature)
        }

        /** Get your account's margin status. Sends an array of all supported currencies */
        public var margin: BxRequest<[BxResponse.User.Margin], BxParameters.None, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "user/margin", security: .signature, params: ["currency" : "all"])
        }

        /** Get your account's margin status for a specific currency */
        public func margin(currency: BxCurrency) -> BxRequest<BxResponse.User.Margin, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "user/margin", security: .signature, params: ["currency" : currency])
        }

        /** Get the minimum withdrawal fee for a currency */
        public func minWithdrawalFee(currency: BxCurrency) -> BxRequest<BxResponse.User.WithdrawalFee, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "user/minWithdrawalFee", params: ["currency" : currency])
        }

        // FIXME: How to send prefs?
        /** Save user preferences */
        public func savePreferences(_ prefs: BxPreferences) -> BxRequest<BxResponse.User, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "user/preferences", method: .post, security: .signature, params: ["prefs" : prefs])
        }

        /** Get secret key for setting up two-factor auth */
        public func requestEnableTFA(_ type: BxTFAType) -> BxRequest<BxResponse.User.RequestEnableTFA, BxParameters.None, BxNo, BxNo, BxColumns.Default> {
            return BxRequest(api: api, endpoint: "user/requestEnableTFA", method: .post, security: .signature, params: ["type" : type])
        }

        /** Request a withdrawal to an external wallet */
        public func requestWithdrawal(otpToken: String? = nil, currency: BxCurrency, amount: Int, address: String, fee: Double? = nil) -> BxRequest<BxResponse.User.RequestWithdrawal, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            let params: BxParams = ["otpToken" : otpToken, "currency" : currency, "amount" : amount, "address" : address, "fee" : fee]
            return BxRequest(api: api, endpoint: "user/requestWithdrawal", method: .post, security: .signature, params: params)
        }

        /** Get your current wallet information */
        public var wallet: BxRequest<BxResponse.User.Wallet, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "user/wallet", security: .signature)
        }

        /** Get your current wallet information for a spcific currency */
        public func wallet(currency: BxCurrency) -> BxRequest<BxResponse.User.Wallet, BxParameters.None, BxNo, BxNo, BxColumns.Custom> {
            return BxRequest(api: api, endpoint: "user/wallet", security: .signature, params: ["currency" : currency])
        }

        /** Get a history of all of your wallet transactions (deposits, withdrawals, PNL) */
        public var walletHistory: BxRequest<[BxResponse.User.WalletHistory], BxParameters.None, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "user/walletHistory", security: .signature)
        }

        /** Get a history of all of your wallet transactions for a specific currency (deposits, withdrawals, PNL) */
        public func walletHistory(currency: BxCurrency) -> BxRequest<[BxResponse.User.WalletHistory], BxParameters.None, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "user/walletHistory", security: .signature, params: ["currency" : currency])
        }

        /** Get a summary of all of your wallet transactions (deposits, withdrawals, PNL) */
        public var walletSummary: BxRequest<[BxResponse.User.WalletSummary], BxParameters.None, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "user/walletSummary", security: .signature)
        }

        /** Get a summary of all of your wallet transactions for a specific currency (deposits, withdrawals, PNL) */
        public func walletSummary(currency: BxCurrency) -> BxRequest<[BxResponse.User.WalletSummary], BxParameters.None, BxNo, BxNo, BxColumns.Customs> {
            return BxRequest(api: api, endpoint: "user/walletSummary", security: .signature, params: ["currency" : currency])
        }
    }
}

// MARK - Response

public extension BxResponse {
    public struct User: Decodable {
        public let id: Double
        public let ownerId: Double?
        public let firstname: String
        public let lastname: String
        public let username: String
        public let email: String
        public let phone: String?
        public let created: Date
        public let lastUpdated: Date
        public let preferences: BxPreferences
        public let TFAEnabled: String
        public let affiliateID: String
        public let pgpPubKey: String?
        public let country: String

        public struct AffiliateStatus: Decodable {
            public let account: Double
            public let currency: String
            public let prevPayout: Double
            public let prevTurnover: Double
            public let prevComm: Double
            public let prevTimestamp: Date
            public let execTurnover: Double
            public let execComm: Double
            public let totalReferrals: Double
            public let totalTurnover: Double
            public let totalComm: Double
            public let payoutPcnt: Double
            public let pendingPayout: Double
            public let timestamp: Date
            public let referrerAccount: Int
        }

        public struct CancelWithdrawal: Decodable {
            public let transactID: String
            public let account: Double
            public let currency: String
            public let transactType: String
            public let amount: Double
            public let fee: Double
            public let transactStatus: String
            public let address: String
            public let tx: String
            public let text: String
            public let transactTime: Date
            public let timestamp: Date
        }

        public typealias CheckReferralCode = Double

        public struct Commission: Decodable {
            public let makerFee: Double
            public let takerFee: Double
            public let settlementFee: Double
            public let maxFee: Int
        }

        public struct ConfirmEmail: Decodable {
            public let id: String
            public let ttl: Int
            public let created: Date
            public let userId: Int
        }

        public typealias ConfirmEnableTFA = Bool

        public struct ConfirmWithdrawal: Decodable {
            public let transactID: String
            public let account: Double
            public let currency: String
            public let transactType: String
            public let amount: Double
            public let fee: Double
            public let transactStatus: String
            public let address: String
            public let tx: String
            public let text: String
            public let transactTime: Date
            public let timestamp: Date
        }

        public typealias DepositAddress = String

        public typealias DisableTFA = Bool

        public struct Logout: Decodable { }

        public typealias LogoutAll = Double

        public struct Margin: Decodable {
            public let account: Double
            public let currency: String
            public let riskLimit: Double
            public let prevState: String
            public let state: String
            public let action: String
            public let amount: Double
            public let pendingCredit: Double
            public let pendingDebit: Double
            public let confirmedDebit: Double
            public let prevRealisedPnl: Double
            public let prevUnrealisedPnl: Double
            public let grossComm: Double
            public let grossOpenCost: Double
            public let grossOpenPremium: Double
            public let grossExecCost: Double
            public let grossMarkValue: Double
            public let riskValue: Double
            public let taxableMargin: Double
            public let initMargin: Double
            public let maintMargin: Double
            public let sessionMargin: Double
            public let targetExcessMargin: Double
            public let varMargin: Double
            public let realisedPnl: Double
            public let unrealisedPnl: Double
            public let indicativeTax: Double
            public let unrealisedProfit: Double
            public let syntheticMargin: Double
            public let walletBalance: Double
            public let marginBalance: Double
            public let marginBalancePcnt: Double
            public let marginLeverage: Double
            public let marginUsedPcnt: Double
            public let excessMargin: Double
            public let excessMarginPcnt: Double
            public let availableMargin: Double
            public let withdrawableMargin: Double
            public let timestamp: Date
            public let grossLastValue: Double
            public let commission: Double
        }

        public struct WithdrawalFee: Decodable {
            public let currency: BxCurrency
            public let fee: Int
            public let minFee: Int
        }

        public typealias RequestEnableTFA = Bool

        public struct RequestWithdrawal: Decodable {
            public let transactID: String
            public let account: Double
            public let currency: String
            public let transactType: String
            public let amount: Double
            public let fee: Double
            public let transactStatus: String
            public let address: String
            public let tx: String
            public let text: String
            public let transactTime: Date
            public let timestamp: Date
        }

        public struct Wallet: Decodable {
            public let account: Double
            public let currency: String
            public let prevDeposited: Double
            public let prevWithdrawn: Double
            public let prevTransferIn: Double
            public let prevTransferOut: Double
            public let prevAmount: Double
            public let prevTimestamp: Date
            public let deltaDeposited: Double
            public let deltaWithdrawn: Double
            public let deltaTransferIn: Double
            public let deltaTransferOut: Double
            public let deltaAmount: Double
            public let deposited: Double
            public let withdrawn: Double
            public let transferIn: Double
            public let transferOut: Double
            public let amount: Double
            public let pendingCredit: Double
            public let pendingDebit: Double
            public let confirmedDebit: Double
            public let timestamp: Date
            public let addr: String
            public let script: String
            public let withdrawalLock: [String]
        }

        public struct WalletHistory: Decodable {
            public let transactID: String
            public let account: Double
            public let currency: String
            public let transactType: String
            public let amount: Double
            public let fee: Double?
            public let transactStatus: String
            public let address: String
            public let tx: String?
            public let text: String?
            public let transactTime: Date?
            public let timestamp: Date?
        }

        public struct WalletSummary: Decodable {
            public let account: Int
            public let currency: BxCurrency
            public let transactType: BxTransactionType
            public let symbol: BxSymbol
            public let amount: Int
            public let pendingDebit: Int
            public let realisedPnl: Int
            public let walletBalance: Int
            public let unrealisedPnl: Int
            public let marginBalance: Int
        }
    }
}

public typealias BxLocale = String

