import Foundation

public enum GatewayError: Error, CustomStringConvertible {
    case invalidApiUrl(String)
    
    case message(String)
    case generic(Error)
    
    public var description: String {
        switch self {
        case .invalidApiUrl(let url):
            return "Invalid API URL - \(url)"
        case .message(let message):
            return message
        case .generic(let error):
            return (error as CustomStringConvertible).description
        }
    }
}
