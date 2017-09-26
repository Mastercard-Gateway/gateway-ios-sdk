import Foundation

public class Gateway: NSObject {
    var trustedCertificates: [String: Data] = ["default" : BuildConfig.intermediateCa]
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
    
    public init(url: String, merchantId: String, apiVersion: Int) throws {
        self.apiURL = try Gateway.ApiPathFor(url: url, merchantId: merchantId, apiVersion: apiVersion)
    }
    
    public convenience init(url: String, merchantId: String) throws {
        try self.init(url: url, merchantId: merchantId, apiVersion: BuildConfig.defaultAPIVersion)
    }
    
    public func clearTrustedCertificates() {
        trustedCertificates = [:]
    }
    
    public func addTrustedCertificate(_ certificate: Data, alias: String) {
        trustedCertificates[alias] = certificate
    }
    
    public func removeTrustedCertificate(alias: String) {
        trustedCertificates[alias] = nil
    }
    
    public func updateSession(_ session: String, nameOnCard: String, cardNumber: String, securityCode: String, expiryMM: String, expiryYY: String, completion: @escaping (GatewayResult<UpdateSessionRequest.responseType>) -> Void) -> URLSessionDataTask {
        let card = Card(nameOnCard: nameOnCard, number: cardNumber, securityCode: securityCode, expiry: Expiry(month: expiryMM, year: expiryYY))
        var request = UpdateSessionRequest(sessionId: session)
        request.sourceOfFunds = SourceOfFunds(provided: Provided(card: card))
        return execute(request: request, completion: completion)
    }
    
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
