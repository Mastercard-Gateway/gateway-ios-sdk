import Foundation

public struct UpdateSessionResponse: GatewayResponse {
    public let correlationId: String?
    public let sessionId: String
    public let version: String
    
    private enum CodingKeys : String, CodingKey {
        case correlationId
        case sessionId = "session"
        case version
    }
}
