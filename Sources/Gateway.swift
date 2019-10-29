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

/** The public interface to the Gateway SDK.
 ```
 let gateway = try Gateway(url: "https://your-gateway-url.com", merchantId: "your-merchant-id")
 ```
 */
public class Gateway: NSObject {
    /// The region the merchant is located in
    public let region: GatewayRegion
    
    /// The merchant's id on the Gateway
    public let merchantId: String
    
    /// Construct a new instance of the gateway.
    ///
    /// - Parameters:
    ///   - region: the region in which the merchant is registered with the gateway.  This must be one of the values provided by the GatewayRegion enum (.northAmerica, .europe, .asiaPacific).
    ///   - merchantId: a valid merchant ID
    public init(region: GatewayRegion, merchantId: String) {
        self.region = region
        self.merchantId = merchantId
    }
    
    
    /// Update a gateway session with payment payer data.
    ///
    /// - Parameters:
    ///   - session: A session ID from the gateway
    ///   - apiVersion: the api version which was used to create the session
    ///   - payload: A GatewayMap containting the payload to send
    ///   - completion: A completion handler for when the request completes or fails
    /// - Returns: The URLSessionTask being used to perform the network request for the purposes of canceling or monitoring the progress.
    @discardableResult
    public func updateSession(_ session: String, apiVersion: String, payload: GatewayMap, completion: @escaping (GatewayResult<GatewayMap>) -> Void) -> URLSessionTask? {
        var task: URLSessionTask? = nil
        do {
            var fullPayload = payload
            var headers: [String : String] = [:]
            
            // If the API version is less than 50, we must set the apiOperation
            // If the API version is 50 or higer, we must set the authentication header
            if let version = Int(apiVersion) {
                switch version {
                case (..<50):
                    fullPayload["apiOperation"] = "UPDATE_PAYER_DATA"
                case (50...):
                    headers["Authorization"] = createSessionAuthHeader(session: session)
                default: break
                }
            }
            
            fullPayload[at: "device.browser"] = userAgent
            
            
            task = try execute(.put, path: "session/\(session)", payload: fullPayload, apiVersion: apiVersion, headers: headers, completion: completion)
        } catch {
            completion(GatewayResult(error))
        }
        return task
    }
    
    // MARK: - INTERNAL & PRIVATE
    
    /// Execute a network request against the gateway
    ///
    /// - Parameters:
    ///   - method: The HTTPMethod for the request
    ///   - path: The path to be appended to the merchant's base api url
    ///   - payload: A GatewayMap of the payload to be serialized and sent to the API
    ///   - apiVersion: The API version used for the request
    ///   - completion: A completion handler for when the request completes or fails
    /// - Returns: The URLSessionTask being used to perform the network request for the purposes of canceling or monitoring the progress.
    /// - Throws: If the APIVersion is not supported or the payload could not be encoded
    @discardableResult
    func execute(_ method: HTTPMethod, path: String, payload: GatewayMap, apiVersion: String, headers: [String : String] = [:], completion: @escaping (GatewayResult<GatewayMap>) -> Void) throws -> URLSessionTask? {
        
        let requestURL = try apiURL(for: apiVersion).appendingPathComponent(path)
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        // set the custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(payload)
        
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            do {
                guard error == nil else { throw error! }
                
                if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
                    let explination = self.getErrorExplination(data)
                    throw GatewayError.failedRequest(httpResponse.statusCode, explination)
                } else {
                    guard let data = data else { throw GatewayError.missingResponse }
                    let responseMap = try self.decoder.decode(GatewayMap.self, from: data)
                    completion(GatewayResult(responseMap))
                }
            } catch {
                completion(GatewayResult(error))
            }
        }
        
        task.resume()
        return task
    }
    
    /// The url session used to send any requests made by the api
    lazy var urlSession: URLSession = {
        URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
    }()
    
    lazy var sdkVersion: String = {
        let bundle = Bundle.init(for: Gateway.self)
        return bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "0.0"
    }()
    
    /// The User-Agent string that is sent when connecting to the gateway.  This string will include appear as Gateway-iOS-SDK/1.0
    lazy var userAgent: String  = {
        return "Gateway-iOS-SDK/\(sdkVersion)"
    }()
    
    /// The json deocder that will be used to parse all responses into model objects
    lazy var decoder: JSONDecoderProtocol = JSONDecoder()
    /// The json deocder that will be used to parse all serialize request parameters
    lazy var encoder: JSONEncoderProtocol = JSONEncoder()

    private func apiURL(for apiVersion: String) throws -> URL {
        guard BuildConfig.minimumAPIVersion.compare(apiVersion, options: .numeric) != .orderedDescending else { throw GatewayError.invalidAPIVersion(apiVersion) }
        return URL(string: "https://\(region.urlPrefix)-gateway.mastercard.com/api/rest/version/\(String(apiVersion))/merchant/\(merchantId)")!
    }
    
    private func getErrorExplination(_ data: Data?) -> String {
        let defaultExplination = "An error occurred"
        guard let data = data, let map = try? self.decoder.decode(GatewayMap.self, from: data) else { return defaultExplination }
        return (map[at: "error.explanation"] as? String) ?? defaultExplination
    }
    
    private func createSessionAuthHeader(session: String) -> String {
        let credsString = "merchant.\(merchantId):\(session)"
        let credsData = Data(credsString.utf8)
        return credsData.base64EncodedString()
    }
}
