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
        complexValues =  ["map" : allSimpleValues!, "array" : [allSimpleValues, allSimpleValues]]
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
        XCTAssertEqual(testSubject[at: "map.string"] as! String, "A")
        XCTAssertEqual(testSubject[at: "map.int"] as! Int, 1)
        XCTAssertEqual(testSubject[at: "map.double"] as! Double, 1.25)
        XCTAssertEqual(testSubject[at: "map.true"] as! Bool, true)
        XCTAssertEqual(testSubject[at: "map.false"] as! Bool, false)
        XCTAssertNil(testSubject[at: "map.empty"])
        XCTAssertNil(testSubject[at: ""])
        XCTAssertNil(testSubject[at: "map.string.char"])
    }
    
    func testSetValuesAtPath() {
        testSubject = GatewayMap()
        testSubject[at: "map.string"] = "A"
        testSubject[at: "map.int"] = 1
        testSubject[at: "map.double"] = 1.25
        testSubject[at: "map.true"] = true
        testSubject[at: "map.false"] = false
        XCTAssertEqual(testSubject, GatewayMap(["map" : allSimpleValues!]))
    }
    
    func testOverrideNonMapWithMap() {
        testSubject = ["k1" : 5]
        XCTAssertEqual(testSubject, GatewayMap(["k1" : 5 ]))
        testSubject[at: "k1.k2.k3"] = 5
        XCTAssertEqual(testSubject, GatewayMap(["k1" : [ "k2" : [ "k3" : 5 ] ] ]))
    }
    
    func testGetValuesArrayPath() {
        testSubject = ["A" : ["a", "b", "c"]]
        XCTAssertEqual(testSubject[at: "A[1]"] as? String, "b")
        XCTAssertEqual(testSubject[at: "A[]"] as? String, "c")
        
        testSubject = ["Map" : [["value" : "A"], ["value" : "B"], ["value" : "C"]]]
        XCTAssertEqual(testSubject[at: "Map[1].value"] as? String, "B")
        XCTAssertEqual(testSubject[at: "Map[].value"] as? String, "C")
    }
    
    func testSetValuesArrayPathLastKey() {
        testSubject = [:]
        
        testSubject[at: "A[0]"] = "z" // make sure that the incorrect value is overridden
        testSubject[at: "A[0]"] = "a"
        testSubject[at: "A[1]"] = "b"
        testSubject[at: "A[2]"] = "c"
        
        XCTAssertEqual(testSubject, GatewayMap(["A" : ["a", "b", "c"]]))
    }
    
    func testSetValuesArrayPathInMiddle() {
        testSubject = [:]
        
        testSubject[at: "letters[0].lower"] = "a"
        testSubject[at: "letters[0].upper"] = "A"
        testSubject[at: "letters[1].lower"] = "b"
        testSubject[at: "letters[1].upper"] = "B"
        testSubject[at: "letters[].upper"] = "C"
        testSubject[at: "letters[].lower"] = "c"
        
        XCTAssertEqual(testSubject, GatewayMap(["letters" : [["lower" : "a", "upper" : "A"], ["lower" : "b", "upper" : "B"], ["upper" : "C"], ["lower" : "c"]]]))
    }
    
    func testNillingValuesInAnArray() {
        testSubject = ["numbers" : [0,1,2,3,4,5,6,7,8,9]]
        
        testSubject[at: "numbers[0]"] = nil
        XCTAssertEqual(testSubject, ["numbers" : [1,2,3,4,5,6,7,8,9]])
        
        testSubject[at: "numbers[]"] = nil
        XCTAssertEqual(testSubject, ["numbers" : [1,2,3,4,5,6,7,8]])
    }
    
    func testOverridingArrayValues() {
        testSubject = ["numbers" : [0,1,2,3,4,5,6,7,8,9]]
        
        testSubject[at: "numbers[0]"] = 1
        XCTAssertEqual(testSubject, ["numbers" : [1,1,2,3,4,5,6,7,8,9]])
    }
    
    func testOverridingArrayValuesInMiddleOfPath() {
        testSubject = ["letters" : [["lower" : "a", "upper" : "A"], ["lower" : "d", "upper" : "D"], ["lower" : "c", "upper" : "C"]]]
        
        testSubject[at: "letters[1].lower"] = "b"
        testSubject[at: "letters[1].upper"] = "B"
        
        XCTAssertEqual(testSubject, GatewayMap(["letters" : [["lower" : "a", "upper" : "A"], ["lower" : "b", "upper" : "B"], ["lower" : "c", "upper" : "C"]]]))
    }
    
    func testGetValuesUsingArrayPathWhereNoArrayIsPresent() {
        testSubject = ["letters" : "abcdefg"]
        XCTAssertNil(testSubject[at: "letters[0]"])
    }
    
    func testRemoveValuesInArray() {
        testSubject = ["letters" : [["lower" : "a", "upper" : "A"], ["lower" : "b", "upper" : "B"], ["lower" : "c", "upper" : "C"]]]
        
        testSubject[at: "letters[1]"] = nil
        
        XCTAssertEqual(testSubject, GatewayMap(["letters" : [["lower" : "a", "upper" : "A"], ["lower" : "c", "upper" : "C"]]]))
    }
    
    func testBadKeyPaths() {
        testSubject = [:]
        testSubject[at: "a[james]"] = 1 // if the index is a non-integer, we expect it to append
        XCTAssertEqual(testSubject, GatewayMap(["a" : [1]]))
        
        testSubject = [:]
        testSubject[at: "[a]"] = 1
        XCTAssertEqual(testSubject, GatewayMap(["[a]" : 1]))
        
        testSubject = [:]
        testSubject[at: "]["] = 1
        XCTAssertEqual(testSubject, GatewayMap(["][" : 1]))
    }
    
    func testIncompleteArrayNotationJustAddsKey() {
        testSubject = [:]
        testSubject[at: "a[1"] = 1
        XCTAssertEqual(testSubject, GatewayMap(["a[1" : 1]))
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
        testSubject[at: "map.int"] = nil
        XCTAssertNil(testSubject[at: "map.int"])
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
        testSubject = GatewayMap(complexValues)
        XCTAssertEqual(testSubject.value.description, testSubject.description)
        XCTAssertEqual(Optional(testSubject.value).debugDescription, testSubject.debugDescription)
    }
    
    func testCodableSupport() {
        testSubject = GatewayMap(complexValues)
        // mocking Encoder and Decoder is very time consuming so we are simply going to encode and then decode a payload and test the result for equality with the initial map
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let encoded = try encoder.encode(testSubject)
            let decoded = try decoder.decode(GatewayMap.self, from: encoded)
            XCTAssertEqual(decoded, testSubject)
        } catch {
            XCTFail("Unexpected exception thrown - \(error.localizedDescription)")
        }
    }
    
    private func testSetGet<T>(_ value: T, key: String = "object", file: StaticString = #file, line: UInt = #line) where T: Equatable {
        testSubject[key] = value
        XCTAssertEqual(value, testSubject[key] as! T, file: file, line: line)
    }
    
}
