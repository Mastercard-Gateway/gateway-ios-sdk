import Foundation

public protocol GatewayRequest {
    var httpRequest: HTTPRequest { get }
    associatedtype responseType: GatewayResponse
}

public protocol GatewayResponse: Decodable {
    
}
