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

enum UpdateStatus: String, Codable {
    case noUpdate = "NO_UPDATE"
    case failure = "FAILURE"
    case success = "SUCCESS"
}

struct Session: Codable {
    let id: String
    let updateStatus: UpdateStatus
    let version: String
}

struct CreateSessionResponse: Codable {
    let merchant: String
    let result: APIResult
    let session: Session
}

struct CompleteSessionRequest: Codable {
    struct Order: Codable {
        var amount: String
        var currency: String
    }
    
    struct Session: Codable {
        var id: String
    }
    
    struct SourceOfFunds: Codable {
        let type = "CARD"
    }
    
    struct Transaction: Codable {
        let frequency = "SINGLE"
    }
    
    let apiOperation = "PAY"
    var order: Order
    var session: Session
    var sourceOfFunds: SourceOfFunds = SourceOfFunds()
    var transaction: Transaction = Transaction()
    
    init(amount: String, currency: String, sessionId: String) {
        order = Order(amount: amount, currency: currency)
        session = Session(id: sessionId)
    }
}

struct CompleteSessionResponse: Codable {
    let merchant: String
    let result: APIResult
}

