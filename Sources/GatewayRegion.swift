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

/// An object to identify a region in which the Gateway APIs operate and the connection details.
public struct GatewayRegion: Equatable {
    public let id: String
    public let name: String
    public let baseURL: String
}

extension GatewayRegion {
    public static let asiaPacific: GatewayRegion = GatewayRegion(id: "ap", name: "Asia Pacific", baseURL: "ap.gateway.mastercard.com")
    public static let europe: GatewayRegion = GatewayRegion(id: "eu", name: "Europe", baseURL: "eu.gateway.mastercard.com")
    public static let northAmerica: GatewayRegion = GatewayRegion(id: "na", name: "North America", baseURL: "na.gateway.mastercard.com")
    public static let mtf: GatewayRegion = GatewayRegion(id: "mtf", name: "Test (MTF)", baseURL: "mtf.gateway.mastercard.com")
    public static let india: GatewayRegion = GatewayRegion(id: "in", name: "India", baseURL: "in.gateway.mastercard.com")
    public static let china: GatewayRegion = GatewayRegion(id: "cn", name: "China", baseURL: "cn.gateway.mastercard.com")
    
    
    /// Create a region not already defined by the SDK
    /// - Parameters:
    ///   - id: A String to identify the region
    ///   - name: A friendly description of the region
    ///   - baseURL: The base URL for all requests.  For example "mtf.gateway.mastercard.com"
    public static func other(id: String, name: String, baseURL: String) -> GatewayRegion {
        return GatewayRegion(id: id, name: name, baseURL: baseURL)
    }
}
