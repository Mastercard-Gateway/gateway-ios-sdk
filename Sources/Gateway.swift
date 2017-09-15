import Foundation

public class Gateway {
    public var apiHost: String
    public var apiVersion: Int
    public var merchantId: String
    
    public init(url: String, merchantId: String, apiVersion: Int = BuildConfig.defaultAPIVersion) throws {
        self.apiVersion = apiVersion
        self.merchantId = merchantId
        
        guard let urlComponents = URLComponents(string: url), let host = urlComponents.host else {
            throw GatewayError.invalidApiUrl(url)
        }
        
        self.apiHost = host
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
}
