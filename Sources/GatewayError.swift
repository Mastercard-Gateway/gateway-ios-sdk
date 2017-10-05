import Foundation

public enum GatewayError: Error, CustomStringConvertible {
    case invalidApiUrl(String)
    case failedRequest(Int, ErrorResponse?)
    case generic(Error)
    case unknown
    
    public var description: String {
        switch self {
        case .invalidApiUrl(let url):
            return "Invalid API URL - \(url)"
        case .failedRequest(let status, let error):
            return """
                    Gateway Request Error - \(status) - \(HTTPURLResponse.localizedString(forStatusCode: status))
                    \(String(describing: error))response
                    """
        case .generic(let error):
            return (error as CustomStringConvertible).description
        case .unknown:
            return "Unknown Error"
        }
    }
}
