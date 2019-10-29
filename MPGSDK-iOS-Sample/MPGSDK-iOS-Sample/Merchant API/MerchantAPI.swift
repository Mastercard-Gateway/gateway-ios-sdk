/*
 Copyright (c) 2017 Mastercard
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import MPGSDK

enum Result<T> {
    case success(T)
    case error(Error)
}

enum MerchantAPIError: Error {
    case failedRequest
    case other(Error)
}

class MerchantAPI {
    static var shared: MerchantAPI?
    
    let merchantServerURL: URL
    let urlSession: URLSession
    lazy var decoder: JSONDecoder = JSONDecoder()
    
    init(url: URL, urlSession: URLSession = .shared) {
        self.merchantServerURL = url
        self.urlSession = urlSession
    }
    
    func createSession(completion: @escaping (Result<GatewayMap>) -> Void) {
        issueRequest(path: "session.php", method: "POST", completion: completion)
    }
    
    func check3DSEnrollment(transaction: Transaction, redirectURL: String, completion: @escaping (Result<GatewayMap>) -> Void) {
        var payload = GatewayMap(["apiOperation": "CHECK_3DS_ENROLLMENT"])
        payload[at: "order.amount"] = transaction.amountString
        payload[at: "order.currency"] = transaction.currency
        payload[at: "session.id"] = transaction.session?.id
        payload[at: "3DSecure.authenticationRedirect.responseUrl"] = redirectURL
        
        let query = [URLQueryItem(name: "3DSecureId", value: transaction.threeDSecureId)]
        
        issueRequest(path: "3DSecure.php", method: "PUT", query: query, body: payload, completion: completion)
    }
    
    func completeSession(transaction: Transaction, completion: @escaping (Result<GatewayMap>) -> Void) {
        var payload = GatewayMap(["apiOperation": "PAY"])
        payload[at: "sourceOfFunds.type"] =  "CARD"
        payload[at: "transaction.frequency"] = "SINGLE"
        payload[at: "transaction.source"] = "INTERNET"
        payload[at: "order.amount"] = transaction.amountString
        payload[at: "order.currency"] = transaction.currency
        payload[at: "session.id"] = transaction.session!.id
        if let threeDSecureId = transaction.threeDSecureId {
            payload[at: "3DSecureId"] = threeDSecureId
        }
        if transaction.isApplePay {
            payload[at: "order.walletProvider"] = "APPLE_PAY"
        }
        
        let query = [URLQueryItem(name: "order", value: transaction.orderId), URLQueryItem(name: "transaction", value: transaction.id)]
        issueRequest(path: "transaction.php", method: "PUT", query: query, body: payload, completion: completion)
        
    }
    
    fileprivate func issueRequest(path: String, method: String, query: [URLQueryItem]? = nil, body: GatewayMap? = nil, completion: @escaping (Result<GatewayMap>) -> Void) {
        var completeURLComp = URLComponents(url: merchantServerURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        completeURLComp.queryItems = query
        var request = URLRequest(url: completeURLComp.url!)
        
        request.httpMethod = method
        
        if let body = body {
            let encoder = JSONEncoder()
            request.httpBody = try? encoder.encode(body)
        }
        
        let task = urlSession.dataTask(with: request, completionHandler: responseHandler(completion))
        task.resume()
    }
    
    fileprivate func responseHandler<T: Decodable>(_ completion: @escaping (Result<T>) -> Void) -> (Data?, URLResponse?, Error?) -> Void {
        return { (data, response, error) in
            if let error = error {
                completion(Result.error(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode), let data = data else {
                completion(Result.error(MerchantAPIError.failedRequest))
                return
            }
            
            
            print(String(data: data, encoding: .utf8) ?? "Invalid Data")
            
            do {
                let response = try self.decoder.decode(T.self, from: data)
                completion(.success(response))
            } catch {
                completion(Result.error(error))
            }
        }
    }
}
