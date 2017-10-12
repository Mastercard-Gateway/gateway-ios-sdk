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

public struct GatewayResponseError: Codable {
    public enum Cause: String, Codable {
        case requestRejected = "REQUEST_REJECTED"
        case invalidRequest = "INVALID_REQUEST"
        case serverFailed = "SERVER_FAILED"
        case serverBusy = "SERVER_BUSY"
    }
    
    public enum ValidationType: String, Codable {
        case invalid = "INVALID"
        case missing = "MISSING"
        case unsupported = "UNSUPPORTED"
    }
    
    public let cause: Cause?
    public let explination: String?
    public let field: String?
    public let supportCode: String?
    public let validationType: ValidationType?
    
    public init(cause: Cause? = nil, explination: String? = nil, field: String? = nil, supportCode: String? = nil, validationType: ValidationType? = nil) {
        self.cause = cause
        self.explination = explination
        self.field = field
        self.supportCode = supportCode
        self.validationType = validationType
    }
}
