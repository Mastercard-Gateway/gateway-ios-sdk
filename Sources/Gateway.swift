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
    /// Construct a new instance of the gateway.
    ///
    /// - Parameters:
    ///   - url: The URL of the gateway services.  For instance, "https://test-gateway.mastercard.com".
    ///   - merchantId: a valid merchant ID
    /// - Throws: GatewayError.invalidApiUrl if the host can not be parsed from the supplied url
    public convenience init(url: String, merchantId: String) throws {
        try self.init(url: url, merchantId: merchantId, apiVersion: BuildConfig.defaultAPIVersion)
    }
    
    /// Construct a new instance of the gateway.
    ///
    /// - Parameters:
    ///   - url: The URL of the gateway services.  For instance, "https://test-gateway.mastercard.com"
    ///   - merchantId: a valid merchant ID
    ///   - apiVersion: the current api version.  See [Gateway API Versions](https://test-gateway.mastercard.com/api/documentation/apiDocumentation/rest-json/index.html) for a list of available version numbers
    /// - Throws: GatewayError.invalidApiUrl if the host can not be parsed from the supplied url
    private init(url: String, merchantId: String, apiVersion: Int) throws {
        self.apiURL = try Gateway.ApiPathFor(url: url, merchantId: merchantId, apiVersion: apiVersion)
    }
    
    
    /// remove all custom trusted TLS certificates.
    public func clearTrustedCertificates() {
        trustedCertificates = [:]
    }
    
    /// Add a certificate to trust when connecting to the gateway via TLS
    ///
    /// - Parameters:
    ///   - certificate: data representing an X.509 certificate
    ///   - alias: A string to identify the certificate
    /// - Throws: 'CertificateError.invalidFormat' if a certificate could not be parsed from the provided data.
    public func addTrustedCertificate(_ der: Data, alias: String) throws {
        trustedCertificates[alias] = try X509Cert(der: der)
    }
    
    /// Add a certificate to trust when connecting to the gateway via TLS
    ///
    /// - Parameters:
    ///   - certificate: PEM or Base64 string representing an X.509 certificate
    ///   - alias: A string to identify the certificate
    /// - Throws: 'CertificateError.invalidFormat' if a certificate could not be parsed from the provided string.
    public func addTrustedCertificate(_ pem: String, alias: String) throws {
        trustedCertificates[alias] = try X509Cert(pem: pem)
    }
    
    /// Remove a specific trusted certificate
    ///
    /// - Parameter alias: The string identifying the certificate to remove
    public func removeTrustedCertificate(alias: String) {
        trustedCertificates[alias] = nil
    }
    
    /// Update a gateway session with a payment card.
    ///
    /// - Parameters:
    ///   - session: A session ID from the gateway
    ///   - nameOnCard: The cardholder's name
    ///   - cardNumber: The card number
    ///   - securityCode: The security code
    ///   - expiryMM: The card expiration month (format: MM)
    ///   - expiryYY: The card expiration year (format: YY)
    ///   - completion: A callback to handle the success or error of the network operation
    /// - Returns: The URLSessionDataTask being used to perform the network request for the purposes of canceling or monitoring the progress.
    @discardableResult
    public func updateSession(_ session: String, nameOnCard: String, cardNumber: String, securityCode: String, expiryMM: String, expiryYY: String, completion: @escaping (GatewayResult<UpdateSessionRequest.responseType>) -> Void) -> URLSessionDataTask {
        let card = Card(nameOnCard: nameOnCard, number: cardNumber, securityCode: securityCode, expiry: Expiry(month: expiryMM, year: expiryYY))
        return updateSession(session, card: card, completion: completion)
    }
    
    /// Update a gateway session with a payment card.
    ///
    /// - Parameters:
    ///   - session: A session ID from the gateway
    ///   - card: The card to use as the payment method
    /// - Returns: The URLSessionDataTask being used to perform the network request for the purposes of canceling or monitoring the progress.
    @discardableResult
    public func updateSession(_ session: String, card: Card, completion: @escaping (GatewayResult<UpdateSessionRequest.responseType>) -> Void) -> URLSessionDataTask {
        var request = UpdateSessionRequest(sessionId: session)
        request.sourceOfFunds = SourceOfFunds(provided: Provided(card: card))
        return execute(request: request, completion: completion)
    }
    
    /// Execute a request against the gateway.
    ///
    /// - Parameters:
    ///   - request: The request to be executed
    ///   - completion: The result of the operation.  This will be either .success containing the response or .error containing either a network error or gateway error response.
    /// - Returns: The URLSessionDataTask being used to perform the network request for the purposes of canceling or monitoring the progress.
    @discardableResult
    public func execute<T: GatewayRequest>(request: T, completion: @escaping (GatewayResult<T.responseType>) -> Void) -> URLSessionDataTask {
        let task = urlSession.dataTask(with: build(request: request)) { (data, response, error) in
            if let error = error {
                completion(GatewayResult.error(error))
            } else if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
                var errorResponse: ErrorResponse? = nil
                if let data = data {
                    errorResponse = try? self.decoder.decode(ErrorResponse.self, from: data)
                }
                completion(GatewayResult(GatewayError.failedRequest(httpResponse.statusCode, errorResponse)))
            } else if let data = data {
                do {
                    let response = try self.decoder.decode(T.responseType.self, from: data)
                    completion(GatewayResult(response))
                } catch {
                    completion(GatewayResult(error))
                }
            } else {
                completion(GatewayResult(GatewayError.unknown))
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - INTERNAL & PRIVATE
    
    /// A dictionary containing any additional tls certificates that the sdk should trust
    var trustedCertificates: [String: X509Cert] = [:]
    
    /// The url session used to send any requests made by the api
    lazy var urlSession: URLSession = {
        URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
    }()
    
    /// The json deocder that will be used to parse all responses into model objects
    lazy var decoder: JSONDecoder = JSONDecoder()
    
    /// The url for the api including the version ad merchant id
    let apiURL: URL
    
    // parse and construct a url string with path using the host from the provided url, apiVersion and merchantId.
    fileprivate static func ApiPathFor(url: String, merchantId: String, apiVersion: Int) throws -> URL {
        // check to make sure the provided api contains a host since that is all that the service uses.
        guard let urlComponents = URLComponents(string: url), let apiHost = urlComponents.host else {
            throw GatewayError.invalidApiUrl(url)
        }
        
        guard let apiURL = URL(string: "https://\(apiHost)/api/rest/version/\(String(apiVersion))/merchant/\(merchantId)") else {
            throw GatewayError.invalidApiUrl(url)
        }
        
        return apiURL
    }
    
    // Build a url request from the GatewayRequest.  This method also adds the User-Agent and Content-Type
    private func build<T: GatewayRequest>(request: T) -> URLRequest {
        let httpRequest = request.httpRequest
        let requestURL = apiURL.appendingPathComponent(httpRequest.path)
        var request = URLRequest(url: requestURL)
        request.httpMethod = httpRequest.method.rawValue
        request.allHTTPHeaderFields = httpRequest.headers
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(httpRequest.contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = httpRequest.payload
        return request
    }

    /// The User-Agent string that is sent when connecting to the gateway.  This string will include appear as Gateway-iOS-SDK/1.0
    var userAgent: String {
        let bundle = Bundle.init(for: Gateway.self)
        let version = bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "0.0"
        return "Gateway-iOS-SDK/\(version)"
    }
}
