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
@testable import MPGSDK
import XCTest

class GatewayErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDescriptions() {
        XCTAssertEqual(GatewayError.failedRequest(404, "Failed To Load").description, "Gateway Request Error - 404 not found\nFailed To Load")
        XCTAssertEqual(GatewayError.invalidAPIVersion("5").description, "API version 5 is not compatible")
        XCTAssertEqual(GatewayError.missingResponse.description, "Unexpected empty response")
        
    }
    
}
