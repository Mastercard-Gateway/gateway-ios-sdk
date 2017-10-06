import Foundation

public struct UpdateSessionRequest: GatewayRequest, Encodable {
    public typealias responseType = UpdateSessionResponse
    
    public var apiOperation: String? = "UPDATE_PAYER_DATA"
    public var correlationId: String?
    public var shipping: Shipping?
    public var billing: Billing?
    public var customer: Customer?
    public var device: Device?
    public var session: Session?
    public var sourceOfFunds: SourceOfFunds?
    
    public let sessionId: String
    
    // providing the coding keys to keep the sessionId from being serialized into the json payload.
    private enum CodingKeys : String, CodingKey {
        case apiOperation
        case correlationId
        case shipping
        case billing
        case customer
        case device
        case session
        case sourceOfFunds
    }
    
    public init (sessionId: String) {
        self.sessionId = sessionId
    }
    
    public var httpRequest: HTTPRequest {
        let jsonCoder = JSONEncoder()
        let payload = try? jsonCoder.encode(self)
        return HTTPRequest(path: "session/\(sessionId)", method: .put, payload: payload, contentType: "application/json")
    }
}
