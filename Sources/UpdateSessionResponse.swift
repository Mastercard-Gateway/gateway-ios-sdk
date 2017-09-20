import Foundation

public struct UpdateSessionResponse: GatewayResponse {
    public var correlationId: String?
    public var sessionId: String
    public var version: String
    
    private enum CodingKeys : String, CodingKey {
        case correlationId
        case sessionId = "session"
        case version
    }
}
