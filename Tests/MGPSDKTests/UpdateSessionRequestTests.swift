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

import XCTest
@testable import MPGSDK


class UpdateSessionRequestTests: XCTestCase {
    
    func testInitWithValidAPIVersion() {
        XCTAssertNoThrow(try UpdateSessionRequest(sessionId: "", apiVersion: 39))
        XCTAssertNoThrow(try UpdateSessionRequest(sessionId: "", apiVersion: 40))
        XCTAssertNoThrow(try UpdateSessionRequest(sessionId: "", apiVersion: 41))
    }
    
    func testInitWithInvalidAPIVersionThrows() {
        do {
            _ = try UpdateSessionRequest(sessionId: "", apiVersion: 38)
            XCTFail("Should have failed")
        } catch GatewayError.invalidAPIVersion(let version) {
            XCTAssertEqual(version, 38)
        } catch {
            XCTFail("Should have thrown GatewayError.invalidAPIVersion(38)")
        }
    }
}

