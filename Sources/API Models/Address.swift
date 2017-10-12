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

public struct Address: Codable {
    public let city: String?
    public let company: String?
    public let country: String?
    public let posCodeZip: String?
    public let stateProvince: String?
    public let street: String?
    public let street2: String?
    
    public init(city: String? = nil, company: String? = nil, country: String? = nil, posCodeZip: String? = nil, stateProvince: String? = nil, street: String? = nil, street2: String? = nil) {
        self.city = city
        self.company = company
        self.country = country
        self.posCodeZip = posCodeZip
        self.stateProvince = stateProvince
        self.street = street
        self.street2 = street2
    }
}
