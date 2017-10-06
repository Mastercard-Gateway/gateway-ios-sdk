import XCTest
@testable import MPGSDK

struct MockRequest: GatewayRequest {
    public typealias responseType = MockResponse
    public var httpRequest: HTTPRequest = HTTPRequest()
}

struct MockResponse: GatewayResponse, Decodable {
    let value: String
}

class GatewayTests: XCTestCase {
 
    var mockResponseJSON = Data("{\"value\" : \"Test Data\"}".utf8)
    var mockErrorResponseJSON = Data("{\"result\":\"ERROR\",\"error\":{\"cause\":\"SERVER_FAILED\"}}".utf8)
    var mockSuccsessResponseJSON = Data("""
    {
        \"sessionId\": \"123456\",
        \"version\": \"2\"
    }
    """.utf8)
    
    var testSubject: Gateway! = {
        return try? Gateway(url: "https://test-gateway.matercard.com", merchantId: "123456789", apiVersion: 9)
    }()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitWithDefaultAPIVersion() {
        do {
            testSubject = try Gateway(url: "https://test-gateway.matercard.com", merchantId: "123456789")
        } catch {
            XCTFail("Init with valid parameters failed")
        }
        XCTAssertEqual(testSubject.apiURL.absoluteString, "https://test-gateway.matercard.com/api/rest/version/\(BuildConfig.defaultAPIVersion)/merchant/123456789")
    }
    
    func testInitWithCustomAPIVersion() {
        do {
            testSubject = try Gateway(url: "https://test-gateway.matercard.com", merchantId: "123456789", apiVersion: 9)
        } catch {
            XCTFail("Init with valid parameters failed")
        }
        XCTAssertEqual(testSubject.apiURL.absoluteString, "https://test-gateway.matercard.com/api/rest/version/9/merchant/123456789")
    }
    
    func testInitWithBadUrlParameterFails() {
        do {
            testSubject = try Gateway(url: "server", merchantId: "123456789", apiVersion: 9)
            XCTFail("Init with bad server name was succesfull")
        } catch {
            switch error {
            case GatewayError.invalidApiUrl(let url):
                XCTAssertEqual(url, "server")
            default:
                XCTFail("Init threw unexpected exception")
            }
        }
    }
    
    func testVerifyTrustedCertificatesDefaults() {
        XCTAssertEqual(testSubject.trustedCertificates, [:])
    }
    
    func testClearAllTrustedCertifictes() {
        testSubject.clearTrustedCertificates()
        XCTAssertEqual(testSubject.trustedCertificates, [:])
    }
    
    func testAddTrustedCertificate() {
        let mockCertificate = Data(base64Encoded: "AQIDBAUGBwgJ")!
        testSubject.clearTrustedCertificates()
        testSubject.addTrustedCertificate(mockCertificate, alias: "mock")
        
        XCTAssertEqual(testSubject.trustedCertificates, ["mock": mockCertificate])
    }

    func testRemoveTrustedCertificate() {
        testSubject.addTrustedCertificate(Data(), alias: "mock")
        testSubject.removeTrustedCertificate(alias: "mock")
        XCTAssertEqual(testSubject.trustedCertificates, [:])
    }
    
    func testExecuteRequestSendsCorrectRequest() {
        let mockURLSession = MockURLSession()
        let mockDataTask = MockURLSessionDataTask()
        mockURLSession.nextDataTask = mockDataTask
        testSubject.urlSession = mockURLSession
        
        let mockRequest = MockRequest()

        let task = testSubject.execute(request: mockRequest) { (response) in }
        
        XCTAssert(task == mockDataTask)
        XCTAssert(mockDataTask.resumeWasCalled)
    }
    
    func testExecuteRequestParsesSuccesfullResponse() {
        let mockURLSession = MockURLSession()
        let mockDataTask = MockURLSessionDataTask()
        mockURLSession.nextDataTask = mockDataTask
        let mockRequest = MockRequest()
        var response: GatewayResult<MockResponse>? = nil
        testSubject.urlSession = mockURLSession
        
        _ = testSubject.execute(request: mockRequest) { (result) in
            response = result
        }
    
        mockURLSession.lastCompletion?(mockResponseJSON, HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        
        switch response {
        case .some(.success(let object)):
            XCTAssertEqual(object.value, "Test Data")
        default:
            XCTFail()
        }
    }
    
    func testExecuteRequestWithNetworkError() {
        let mockURLSession = MockURLSession()
        let mockDataTask = MockURLSessionDataTask()
        mockURLSession.nextDataTask = mockDataTask
        let mockRequest = MockRequest()
        var response: GatewayResult<MockResponse>? = nil
        testSubject.urlSession = mockURLSession
        
        _ = testSubject.execute(request: mockRequest) { (result) in
            response = result
        }
        
        mockURLSession.lastCompletion?(nil, nil, NSError(domain: "test.error", code: 1, userInfo: nil))
        
        switch response {
        case .some(.error(let error as NSError)):
            XCTAssertEqual(error, NSError(domain: "test.error", code: 1, userInfo: nil))
        default:
            XCTFail()
        }
    }
    
    func testExecuteRequestWithServerError() {
        let mockURLSession = MockURLSession()
        let mockDataTask = MockURLSessionDataTask()
        mockURLSession.nextDataTask = mockDataTask
        let mockRequest = MockRequest()
        var response: GatewayResult<MockResponse>? = nil
        testSubject.urlSession = mockURLSession
        
        _ = testSubject.execute(request: mockRequest) { (result) in
            response = result
        }
        
        mockURLSession.lastCompletion?(mockErrorResponseJSON, HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 500, httpVersion: nil, headerFields: nil), nil)
        
        switch response {
        case .some(.error(let error as GatewayError)):
            switch error {
            case .failedRequest(500, let errorResponse):
                XCTAssertNotNil(errorResponse)
                XCTAssertEqual(errorResponse!.result, .error)
                XCTAssertNotNil(errorResponse!.error)
                XCTAssertEqual(errorResponse!.error!.cause, .serverFailed)
            default:
                XCTFail()
            }
        default:
            XCTFail()
        }
    }
    
    func testExecuteUpdateSession() {
        let mockURLSession = MockURLSession()
        testSubject.urlSession = mockURLSession
        
        _ = testSubject.updateSession("123456", nameOnCard: "Teddy Tester", cardNumber: "5555555555554444", securityCode: "123", expiryMM: "12", expiryYY: "19", completion: { (result) in
            
        })
        
        guard let request = mockURLSession.lastRequest else {
            XCTFail("No Request Sent")
            return
        }
        
        XCTAssertEqual(request.url?.absoluteString, "https://test-gateway.matercard.com/api/rest/version/9/merchant/123456789/session/123456")
        XCTAssertEqual(request.httpMethod, "PUT")
        XCTAssertEqual(request.allHTTPHeaderFields!, ["Content-Type": "application/json", "User-Agent": testSubject.userAgent])
    }
    
}
