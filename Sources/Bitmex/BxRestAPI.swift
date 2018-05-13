//
//  BxRestAPI.swift
//  CremonaBot
//
//  Created by Gustaf Kugelberg on 2018-01-22.
//  Copyright © 2018 Cremona. All rights reserved.
//

import Foundation
import Alamofire

public enum BxSecurity {
    case none
    case signature
}

public enum BxTimeFormat: String {
    case s = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    case ms = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
}

public struct BxRestAPI {
    private struct ErrorBox: Decodable {
        let error: BxResponse.Error
    }

    private let baseUrl: URL
    private let apiId: String
    private let apiSecret: String

    private let decoder = JSONDecoder()
    private let formatter = DateFormatter()

    public init(baseUrl: String, apiId: String, apiSecret: String) {
        self.baseUrl = URL(string: baseUrl)!
        self.apiId = apiId
        self.apiSecret = apiSecret
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
    }

    public func customRequest<T: Decodable>(at endpoint: String, with method: RestMethod = .get, params: BxParams = [:], security: BxSecurity = .none, timeFormat: BxTimeFormat = .ms, handle: @escaping (Result<T>) -> Void) {

        let url = baseUrl.appendingPathComponent(endpoint)
        let parameters = params.compacted

        print("Bx SENDING REQ: \(method) \(endpoint), PARAMS: \(parameters), TIME: \(timeFormat), PATH: \(url.path)")

        let headers: HTTPHeaders
        switch security {
        case .none:
            headers = [:]
        case .signature:
            let nonce = Bitmex.nonce
            do {
                let (path, data) = try pathAndData(url: url, method: method, nonce: nonce, parameters: parameters)
                print("PATH: \(path), DATA: \(data), NONCE: \(nonce)")
                let signature = Bitmex.signature(secret: apiSecret, verb: method, path: path, nonce: nonce, data: data)
                headers = httpHeaders(nonce: nonce, signature: signature)
            }
            catch {
                handle(.failure(error))
                return
            }
        }

        switch timeFormat {
        case .s: decoder.dateDecodingStrategy = .iso8601
        case .ms: decoder.dateDecodingStrategy = .formatted(formatter)
        }

        Alamofire
            .request(url, method: method.http, parameters: parameters, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let json):
                    do {
                        let value = try self.decoder.decode(T.self, from: json)
                        print("\nReply OK \(T.self)\n")
                        handle(.success(value))
                    }
                    catch {
                        let parsingError = error
                        do {
                            let bitmexError = try self.decoder.decode(ErrorBox.self, from: json).error
                            print("\nError reply for \(url)\n\(bitmexError)")
                            handle(.failure(bitmexError))
                        }
                        catch {
                            print("BxRest: Can't parse as \(T.self)\n\(parsingError)")
                            print("BxRest: Can't parse as Error either: \(error)")
                            print("\nReply:\n\(String(data: json, encoding: .utf8) ?? "---")\n\n\n\n")
                            handle(.failure(parsingError))
                        }
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    handle(.failure(error))
                }
        }
    }

    private func pathAndData(url: URL, method: RestMethod, nonce: Int64, parameters: [String : String]) throws -> (path: String, data: String) {
        let urlRequest = try URLRequest(url: url, method: method.http)
        let urlRequestWithParameters = try URLEncoding.default.encode(urlRequest, with: parameters)
        let body = urlRequestWithParameters.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        let query = urlRequestWithParameters.url?.query.flatMap { "?" + $0 } ?? ""
        return (url.path + query, body)
    }

    private func httpHeaders(nonce: Int64, signature: String) -> HTTPHeaders {
        return ["api-nonce" : String(nonce), "api-key" : apiId, "api-signature" : signature]
    }
}

public struct BxResponse {
    public struct Error: Swift.Error, Decodable, CustomStringConvertible {
        let name: String
        let message: String

        public var description: String {
            return "\(name): \(message)"
        }
    }
}

extension Dictionary where Value == StringConvertible? {
    var compacted: [Key : String] {
        var result: [Key : String] = [:]
        for (key, value) in self {
            result[key] = value?.stringValue.count == 0 ? nil : value?.stringValue
        }

        return result
    }
}

extension Dictionary: StringConvertible where Key == String, Value == String {
    public var stringValue: String {
        return map { key, value in "{\(key):\(value)}" }.joined(separator: ",")
    }
}

//struct GKRequest<F: FilterType> {
//    let x: Int
////    private let dummy: F? = nil
//}
//
//struct Other {
//    static var noneFilter: GKRequest<NoFilter> {
//        return GKRequest(x: 5)
//    }
//
//    static var someFilter: GKRequest<SomeFilter> {
//        return GKRequest(x: 2)
//    }
//}
//
//extension GKRequest where F: SomeFilter {
//    func applyFilter() {
//        print(x)
//    }
//}

