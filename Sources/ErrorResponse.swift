import Foundation

public struct ErrorResponse: Codable {
    public enum Result: String, Codable {
        case error = "ERROR"
    }
    
    public let result: Result?
    public let error: GatewayResponseError?
    
    public init(result: Result? = nil, error: GatewayResponseError? = nil) {
        self.result = result
        self.error = error
    }
}
