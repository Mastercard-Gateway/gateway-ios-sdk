import Foundation

public class Gateway: NSObject {
    public var apiHost: String
    public var apiVersion: Int
    public var merchantId: String
    var trustedCertificates: [String: Data]
    
    public init(url: String, merchantId: String, apiVersion: Int = BuildConfig.defaultAPIVersion) throws {
        self.apiVersion = apiVersion
        self.merchantId = merchantId
        
        guard let urlComponents = URLComponents(string: url), let host = urlComponents.host else {
            throw GatewayError.invalidApiUrl(url)
        }
        
        self.apiHost = host
        self.trustedCertificates = ["default" : BuildConfig.intermediateCa]
    }
    
    public var apiPath: String {
        return "api/rest/version/\(String(apiVersion))"
    }
    
    var apiURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = apiHost
        components.path = apiPath
        return components
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
}
