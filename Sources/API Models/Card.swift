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

public struct Card: Codable {
    public let nameOnCard: String?
    public let number: String?
    public let securityCode: String?
    public let expiry: Expiry?
    
    public init(nameOnCard: String? = nil, number: String? = nil, securityCode: String? = nil, expiry: Expiry? = nil) {
        self.nameOnCard = nameOnCard
        self.number = number
        self.securityCode = securityCode
        self.expiry = expiry
    }
}
