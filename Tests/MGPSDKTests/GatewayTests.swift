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

enum MockError: Int, Error {
    case unknown
}

class GatewayTests: XCTestCase {
    var testSubject: Gateway!
    var mockEncoder: MockJSONEncoder!
    var mockDecoder: MockJSONDecoder!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        testSubject = Gateway(region: .mtf, merchantId: "123456789")
        mockEncoder = MockJSONEncoder()
        testSubject.encoder = mockEncoder
        mockDecoder = MockJSONDecoder()
        testSubject.decoder = mockDecoder
        mockURLSession = MockURLSession()
        testSubject.urlSession = mockURLSession
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitParameters() {
        testSubject =  Gateway(region: .mtf, merchantId: "123456789")
        
        XCTAssertEqual(testSubject.region, .mtf)
        XCTAssertEqual(testSubject.merchantId, "123456789")
    }
    
    func testUserAgentString() {
        testSubject.sdkVersion = "1.2.3456"  // Wow, lots of hotfixes
        XCTAssertEqual(testSubject.userAgent, "Gateway-iOS-SDK/1.2.3456")
    }
    
    func testUpdateSessionWithInvalidAPIVersionThrows() {
        XCTAssertNil(testSubject.updateSession("abc", apiVersion: "38.9", payload: GatewayMap()) { (result) in
            if case let .error(GatewayError.invalidAPIVersion(version)) = result {
                XCTAssertEqual(version, "38.9")
            } else {
                XCTFail("result should have ben an error")
            }
        })
    }
    
    func testUpdateSessionUrlRequestAPILessThan50() {
        let encoded = "updatePayload".data(using: .utf8)!
        mockEncoder.encodeExpectations.expect(GatewayMap(["apiOperation" : "UPDATE_PAYER_DATA", "device" : ["browser" : "TestAgent/1.0"]]), return: encoded)
        testSubject.userAgent = "TestAgent/1.0"
        let mockTask = MockURLSessionDataTask()
        mockURLSession.nextDataTask = mockTask
        
        testSubject.updateSession("abc", apiVersion: "44", payload: GatewayMap()) { (result) in }
        
        XCTAssertNotNil(mockURLSession.lastRequest)
        XCTAssertEqual(mockURLSession.lastRequest?.url, URL(string: "https://test-gateway.mastercard.com/api/rest/version/44/merchant/123456789/session/abc"))
        XCTAssertEqual(mockURLSession.lastRequest?.httpMethod, "PUT")
        XCTAssertEqual(mockURLSession.lastRequest?.httpBody, encoded)
        XCTAssertEqual(mockURLSession.lastRequest!.allHTTPHeaderFields!, ["User-Agent" : "TestAgent/1.0", "Content-Type": "application/json"])
        XCTAssertTrue(mockTask.resumeWasCalled)
    }
    func testUpdateSessionUrlRequestAPIHigherThan50() {
        let encoded = "updatePayload".data(using: .utf8)!
        mockEncoder.encodeExpectations.expect(GatewayMap(["device" : ["browser" : "TestAgent/1.0"]]), return: encoded)
        testSubject.userAgent = "TestAgent/1.0"
        let mockTask = MockURLSessionDataTask()
        mockURLSession.nextDataTask = mockTask
        
        testSubject.updateSession("abc", apiVersion: "50", payload: GatewayMap()) { (result) in }
        
        XCTAssertNotNil(mockURLSession.lastRequest)
        XCTAssertEqual(mockURLSession.lastRequest?.url, URL(string: "https://test-gateway.mastercard.com/api/rest/version/50/merchant/123456789/session/abc"))
        XCTAssertEqual(mockURLSession.lastRequest?.httpMethod, "PUT")
        XCTAssertEqual(mockURLSession.lastRequest?.httpBody, encoded)
        XCTAssertEqual(mockURLSession.lastRequest!.allHTTPHeaderFields!, ["User-Agent" : "TestAgent/1.0", "Content-Type": "application/json", "Authorization": "bWVyY2hhbnQuMTIzNDU2Nzg5OmFiYw=="])
        XCTAssertTrue(mockTask.resumeWasCalled)
    }
    
    func testUpdateSessionSuccessfulResponse() {
        let encoded = "updatePayload".data(using: .utf8)!
        mockEncoder.encodeExpectations.expect(GatewayMap(["apiOperation" : "UPDATE_PAYER_DATA", "device" : ["browser" : "TestAgent/1.0"]]), return: encoded)
        testSubject.userAgent = "TestAgent/1.0"
        let mockResponseData = "ResponseData".data(using: .utf8)!
        let mockResponseMap: GatewayMap = ["response" : "All is good"]
        mockDecoder.decodeExpectations.expect(mockResponseData, return: mockResponseMap)
        let mockResponse = HTTPURLResponse(url: URL(string: "https://test-gateway.mastercard.com/api/rest/version/44/merchant/123456789/session/abc")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        var requestResult: GatewayResult<GatewayMap>? = nil
        
        testSubject.updateSession("123456", apiVersion: "44", payload: GatewayMap()) { (result) in
            requestResult = result
        }
        
        mockURLSession.lastCompletion?(mockResponseData, mockResponse, nil)
        
        if case let .some(.success(map)) = requestResult {
            XCTAssertEqual(map, mockResponseMap)
        } else {
            XCTFail("Expected Request Success")
        }
    }
    
    func testUpdateSessionErrorSendingRequest() {
        let encoded = "updatePayload".data(using: .utf8)!
        mockEncoder.encodeExpectations.expect(GatewayMap(["apiOperation" : "UPDATE_PAYER_DATA", "device" : ["browser" : "TestAgent/1.0"]]), return: encoded)
        testSubject.userAgent = "TestAgent/1.0"
        let mockResponseData = "ResponseData".data(using: .utf8)!
        let mockResponseMap: GatewayMap = ["response" : "All is good"]
        mockDecoder.decodeExpectations.expect(mockResponseData, return: mockResponseMap)
        let mockResponse = HTTPURLResponse(url: URL(string: "https://test-gateway.mastercard.com/api/rest/version/44/merchant/123456789/session/abc")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        var requestResult: GatewayResult<GatewayMap>? = nil
        
        testSubject.updateSession("123456", apiVersion: "44", payload: GatewayMap()) { (result) in
            requestResult = result
        }
        
        mockURLSession.lastCompletion?(mockResponseData, mockResponse, MockError.unknown)
        
        switch requestResult {
        case .some(.error(MockError.unknown)):
            print("Test Passed")
        default:
            XCTFail("Expected Request Error")
        }
    }
    
    func testUpdateSessionWithNilResponse() {
        let encoded = "updatePayload".data(using: .utf8)!
        mockEncoder.encodeExpectations.expect(GatewayMap(["apiOperation" : "UPDATE_PAYER_DATA", "device" : ["browser" : "TestAgent/1.0"]]), return: encoded)
        testSubject.userAgent = "TestAgent/1.0"
        let mockResponse = HTTPURLResponse(url: URL(string: "https://test-gateway.mastercard.com/api/rest/version/44/merchant/123456789/session/abc")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        var requestResult: GatewayResult<GatewayMap>? = nil
        
        testSubject.updateSession("123456", apiVersion: "44", payload: GatewayMap()) { (result) in
            requestResult = result
        }
        
        mockURLSession.lastCompletion?(nil, mockResponse, nil)
        
        switch requestResult {
        case .some(.error(GatewayError.missingResponse)):
            print("Test Passed")
        default:
            XCTFail("Expected Request Error")
        }
    }
    
    func testUpdateSessionWithBadResponseCodeNoExplination() {
        let encoded = "updatePayload".data(using: .utf8)!
        mockEncoder.encodeExpectations.expect(GatewayMap(["apiOperation" : "UPDATE_PAYER_DATA", "device" : ["browser" : "TestAgent/1.0"]]), return: encoded)
        testSubject.userAgent = "TestAgent/1.0"
        let mockResponse = HTTPURLResponse(url: URL(string: "https://test-gateway.mastercard.com/api/rest/version/44/merchant/123456789/session/abc")!, statusCode: 301, httpVersion: nil, headerFields: nil)
        
        var requestResult: GatewayResult<GatewayMap>? = nil
        
        testSubject.updateSession("123456", apiVersion: "44", payload: GatewayMap()) { (result) in
            requestResult = result
        }
        
        mockURLSession.lastCompletion?(nil, mockResponse, nil)
        
        switch requestResult {
        case .some(.error(GatewayError.failedRequest(301, "An error occurred"))):
            print("Test Passed")
        default:
            XCTFail("Expected GatewayError.failedRequest(301, \"An error occurred\")")
        }
    }
    
    func testUpdateSessionWithBadResponseCodeNonStringExplination() {
        let encoded = "updatePayload".data(using: .utf8)!
        mockEncoder.encodeExpectations.expect(GatewayMap(["apiOperation" : "UPDATE_PAYER_DATA", "device" : ["browser" : "TestAgent/1.0"]]), return: encoded)
        testSubject.userAgent = "TestAgent/1.0"
        let mockResponseData = "ResponseData".data(using: .utf8)!
        let mockResponseMap: GatewayMap = ["error" : ["explination" : 5]]
        mockDecoder.decodeExpectations.expect(mockResponseData, return: mockResponseMap)
        let mockResponse = HTTPURLResponse(url: URL(string: "https://test-gateway.mastercard.com/api/rest/version/44/merchant/123456789/session/abc")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        
        var requestResult: GatewayResult<GatewayMap>? = nil
        
        testSubject.updateSession("123456", apiVersion: "44", payload: GatewayMap()) { (result) in
            requestResult = result
        }
        
        mockURLSession.lastCompletion?(mockResponseData, mockResponse, nil)
        
        switch requestResult {
        case .some(.error(GatewayError.failedRequest(404, "An error occurred"))):
            print("Test Passed")
        default:
            XCTFail("Expected GatewayError.failedRequest(404, \"An error occurred\")")
        }
    }
    
    func testUpdateSessionWithBadResponseCodeWithExplination() {
        let encoded = "updatePayload".data(using: .utf8)!
        mockEncoder.encodeExpectations.expect(GatewayMap(["apiOperation" : "UPDATE_PAYER_DATA", "device" : ["browser" : "TestAgent/1.0"]]), return: encoded)
        testSubject.userAgent = "TestAgent/1.0"
        let mockResponseData = "ResponseData".data(using: .utf8)!
        let mockResponseMap: GatewayMap = ["error" : ["explanation" : "Something went wrong"]]
        mockDecoder.decodeExpectations.expect(mockResponseData, return: mockResponseMap)
        let mockResponse = HTTPURLResponse(url: URL(string: "https://test-gateway.mastercard.com/api/rest/version/44/merchant/123456789/session/abc")!, statusCode: 99, httpVersion: nil, headerFields: nil)
        
        var requestResult: GatewayResult<GatewayMap>? = nil
        
        testSubject.updateSession("123456", apiVersion: "44", payload: GatewayMap()) { (result) in
            requestResult = result
        }
        
        mockURLSession.lastCompletion?(mockResponseData, mockResponse, nil)
        
        switch requestResult {
        case .some(.error(GatewayError.failedRequest(99, "Something went wrong"))):
            print("Test Passed")
        default:
            XCTFail("Expected GatewayError.failedRequest(99, \"Something went wrong\")")
        }
    }
    
}
