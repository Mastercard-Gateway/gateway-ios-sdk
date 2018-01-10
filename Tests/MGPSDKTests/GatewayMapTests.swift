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

class GatewayMapTests: XCTestCase {
    var testSubject: GatewayMap!

    var allSimpleValues:[String : Any]!
    var complexValues:[String : Any]!
    
    
    override func setUp() {
        testSubject = GatewayMap()
        allSimpleValues =  ["string" : "A", "int" : 1, "double" : 1.25, "true": true, "false" : false]
        complexValues =  ["map" : allSimpleValues, "array" : [allSimpleValues, allSimpleValues]]
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSimpleValuesAndKeys() {
        testSetGet("s")
        testSetGet(123)
        testSetGet(1.23)
        testSetGet(false)
        testSetGet(true)
    }
    
    func testArrays() {
        testSubject["Strings"] = ["1", "2"]
        XCTAssertEqual(["1", "2"], testSubject["Strings"] as! [String])
    }
    
    func testDictionary() {
        testSubject["map"] = ["1" : 1, "2" : 2]
        XCTAssertEqual(["1" : 1, "2": 2], testSubject["map"] as! [String: Int])
    }
    
    func testEquatable() {
        testSubject = GatewayMap(complexValues)
        let equal = GatewayMap(complexValues)
        XCTAssertEqual(testSubject, equal)
        XCTAssertEqual(GatewayMap(), GatewayMap())
        XCTAssertNotEqual(GatewayMap(["a" : "A"]), GatewayMap(["a" : "B"])) // string values unequal
        XCTAssertNotEqual(GatewayMap(["a" : 1]), GatewayMap(["a" : 2])) // int values unequal
        XCTAssertNotEqual(GatewayMap(["a" : 1.25]), GatewayMap(["a" : 2.50])) // double values unequal
        XCTAssertNotEqual(GatewayMap(["a" : true]), GatewayMap(["a" : false])) // bool values unequal
        XCTAssertNotEqual(GatewayMap(["a" : [1, 2]]), GatewayMap(["a" : [2, 3]])) // array values unequal
        XCTAssertNotEqual(GatewayMap(["a" : ["b": 1]]), GatewayMap(["a" : ["b" : 2]])) // dictionary values unequal
        XCTAssertNotEqual(GatewayMap(["a" : 1]), GatewayMap(["b" : 1])) // keys not identical
        XCTAssertNotEqual(GatewayMap(["a" : "A"]), GatewayMap(["a" : 1])) // types unequal
    }
    
    func testGetValuesAtPath() {
        testSubject = GatewayMap(complexValues)
        XCTAssertEqual(testSubject[path: "map.string"] as! String, "A")
        XCTAssertEqual(testSubject[path: "map.int"] as! Int, 1)
        XCTAssertEqual(testSubject[path: "map.double"] as! Double, 1.25)
        XCTAssertEqual(testSubject[path: "map.true"] as! Bool, true)
        XCTAssertEqual(testSubject[path: "map.false"] as! Bool, false)
        XCTAssertNil(testSubject[path: "map.empty"])
        XCTAssertNil(testSubject[path: ""])
        XCTAssertNil(testSubject[path: "map.string.char"])
    }
    
    func testSetValuesAtPath() {
        testSubject = GatewayMap()
        testSubject[path: "map.string"] = "A"
        testSubject[path: "map.int"] = 1
        testSubject[path: "map.double"] = 1.25
        testSubject[path: "map.true"] = true
        testSubject[path: "map.false"] = false
        XCTAssertEqual(testSubject, GatewayMap(["map" : allSimpleValues]))
    }
    
    func testValuesAtEmptyPath() {
        testSubject = GatewayMap(allSimpleValues)
        testSubject[[]] = "Should not be set"
        XCTAssertNil(testSubject[[]])
    }
    
    func testClearingValues() {
        testSubject = GatewayMap(complexValues)
        testSubject["string"] = nil
        XCTAssertNil(testSubject["string"])
        testSubject[path: "map.int"] = nil
        XCTAssertNil(testSubject[path: "map.int"])
    }
    
    func testDictionaryValue() {
        testSubject = GatewayMap(allSimpleValues)
        XCTAssertEqual(testSubject.dictionary["string"] as! String, "A")
        XCTAssertEqual(testSubject.dictionary["int"] as! Int, 1)
        XCTAssertEqual(testSubject.dictionary["double"] as! Double, 1.25)
        XCTAssertEqual(testSubject.dictionary["true"] as! Bool, true)
        XCTAssertEqual(testSubject.dictionary["false"] as! Bool, false)
    }
    
    func testSetInvalidValue() {
        testSubject = GatewayMap()
        testSubject["object"] = Data()
        XCTAssertNil(testSubject["object"])
    }
    
    func testSettingGatewayValues() {
        testSubject = GatewayMap()
        testSubject["value"] = GatewayValue.int(5)
        XCTAssertEqual(testSubject["value"] as! Int, 5)
        testSubject["array"] = [GatewayValue.int(5), GatewayValue.int(6)]
        XCTAssertEqual(testSubject["array"] as! [Int], [5, 6])
        testSubject["dictionary"] = ["a" : GatewayValue.int(5), "b" : GatewayValue.int(6)]
        XCTAssertEqual(testSubject["dictionary"] as! [String: Int], ["a" : 5, "b" : 6])
    }
    
    func testDescription() {
        let expectedDescription = "[\"map\": [\"true\": true, \"int\": 1, \"double\": 1.25, \"false\": false, \"string\": \"A\"], \"array\": [[\"true\": true, \"int\": 1, \"double\": 1.25, \"false\": false, \"string\": \"A\"], [\"true\": true, \"int\": 1, \"double\": 1.25, \"false\": false, \"string\": \"A\"]]]"
        testSubject = GatewayMap(complexValues)
        XCTAssertEqual(expectedDescription, testSubject.description)
    }
    
    func testEncoding() {
        
    }
    
    private func testSetGet<T>(_ value: T, key: String = "object", file: StaticString = #file, line: UInt = #line) where T: Equatable {
        testSubject[key] = value
        XCTAssertEqual(value, testSubject[key] as! T, file: file, line: line)
    }
    
}
