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

public enum GatewayError: Error, CustomStringConvertible {
    case failedRequest(Int, String)
    case invalidAPIVersion(String)
    case missingResponse
    
    public var description: String {
        switch self {
        case .failedRequest(let status, let message):
            return """
                    Gateway Request Error - \(status) \(HTTPURLResponse.localizedString(forStatusCode: status))
                    \(message)
                    """
        case .invalidAPIVersion(let version):
            return "API version \(version) is not compatible"
        case .missingResponse:
            return "Unexpected empty response"
        }
    }
}
