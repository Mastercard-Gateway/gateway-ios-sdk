import Foundation

public struct UpdateSessionRequest: GatewayRequest, Encodable {
    public typealias responseType = UpdateSessionResponse
    
    public var apiOperation: String?
    public var correlationId: String?
    public var shipping: Shipping?
    public var billing: Billing?
    public var customer: Customer?
    public var device: Device?
    public var session: Session?
    public var sourceOfFunds: SourceOfFunds?
    
    public var httpRequest: HTTPRequest {
        return HTTPRequest(path: <#T##String#>, method: .put, payload: <#T##Data?#>, contentType: "application/json")
    }
}
