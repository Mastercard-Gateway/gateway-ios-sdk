/*
 Copyright (c) 2017 Mastercard
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
    
    /// The json deocder that will be used to parse all responses into model objects
    var encoder: JSONEncoder = JSONEncoder()
    
    public var httpRequest: HTTPRequest {
        let payload = try? encoder.encode(self)
        return HTTPRequest(path: "session/\(sessionId)", method: .put, payload: payload, contentType: "application/json")
    }
}
