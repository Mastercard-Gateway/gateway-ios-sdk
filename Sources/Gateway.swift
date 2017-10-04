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
    ///   - url: The URL of the gateway services.  For instance, "https://test-gateway.mastercard.com"
    ///   - merchantId: a valid merchant ID
    ///   - apiVersion: the current api version.  See [Gateway API Versions](https://test-gateway.mastercard.com/api/documentation/apiDocumentation/rest-json/index.html) for a list of available version numbers
    /// - Throws: GatewayError.invalidApiUrl if the host can not be parsed from the supplied url
    public init(url: String, merchantId: String, apiVersion: Int) throws {
        self.apiURL = try Gateway.ApiPathFor(url: url, merchantId: merchantId, apiVersion: apiVersion)
    }
    
    /// Construct a new instance of the gateway.
    ///
    /// - Parameters:
    ///   - url: The URL of the gateway services.  For instance, "https://test-gateway.mastercard.com"
    ///   - merchantId: a valid merchant ID
    /// - Throws: GatewayError.invalidApiUrl if the host can not be parsed from the supplied url
    public convenience init(url: String, merchantId: String) throws {
        try self.init(url: url, merchantId: merchantId, apiVersion: BuildConfig.defaultAPIVersion)
    }
    
    
    /// remove all custom trusted TLS certificates.
    public func clearTrustedCertificates() {
        trustedCertificates = [:]
    }
    
    /// Add a certificate to trust when connecting to the gateway via TLS
    ///
    /// - Parameters:
    ///   - certificate: A PEM encoded x509 certificate
    ///   - alias: A string to identify the certificate
    public func addTrustedCertificate(_ certificate: Data, alias: String) {
        trustedCertificates[alias] = certificate
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
    public func updateSession(_ session: String, nameOnCard: String, cardNumber: String, securityCode: String, expiryMM: String, expiryYY: String, completion: @escaping (GatewayResult<UpdateSessionRequest.responseType>) -> Void) -> URLSessionDataTask {
        let card = Card(nameOnCard: nameOnCard, number: cardNumber, securityCode: securityCode, expiry: Expiry(month: expiryMM, year: expiryYY))
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
    var trustedCertificates: [String: Data] = [:]
    lazy var urlSession: URLSession = {
        URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
    }()
    lazy var decoder: JSONDecoder = JSONDecoder()
    
    let apiURL: URL
    
    private static func ApiPathFor(url: String, merchantId: String, apiVersion: Int) throws -> URL {
        guard let urlComponents = URLComponents(string: url), let apiHost = urlComponents.host else {
            throw GatewayError.invalidApiUrl(url)
        }
        
        guard let apiURL = URL(string: "https://\(apiHost)/api/rest/version/\(String(apiVersion))/merchant/\(merchantId)") else {
            throw GatewayError.invalidApiUrl(url)
        }
        
        return apiURL
    }
    
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
    
    var userAgent: String {
        let bundle = Bundle.init(for: Gateway.self)
        let version = bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "0.0"
        return "Gateway-iOS-SDK/\(version)"
    }
}
