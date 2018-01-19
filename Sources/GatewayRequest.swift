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

/// A request to be issued against the gateway
public protocol GatewayRequest {
    /// The underlying HTTP Request Data
    var httpRequest: HTTPRequest { get }
    /// The type of the expected gateway response
    associatedtype responseType: GatewayResponse
    /// the version of the api for the request
    var apiVersion: Int { get }
}


/// Any response object that can be decoded
public protocol GatewayResponse: Decodable {
    
}
