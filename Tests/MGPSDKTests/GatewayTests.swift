import XCTest
@testable import MPGSDK

class GatewayTests: XCTestCase {
    
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
        XCTAssertEqual(testSubject.apiHost, "test-gateway.matercard.com")
        XCTAssertEqual(testSubject.merchantId, "123456789")
        XCTAssertEqual(testSubject.apiVersion, BuildConfig.defaultAPIVersion)
    }
    
    func testInitWithCustomAPIVersion() {
        do {
            testSubject = try Gateway(url: "https://test-gateway.matercard.com", merchantId: "123456789", apiVersion: 9)
        } catch {
            XCTFail("Init with valid parameters failed")
        }
        XCTAssertEqual(testSubject.apiHost, "test-gateway.matercard.com")
        XCTAssertEqual(testSubject.merchantId, "123456789")
        XCTAssertEqual(testSubject.apiVersion, 9)
    }
    
    func testAPIPath() {
        XCTAssertEqual(testSubject.apiPath, "api/rest/version/9")
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
        XCTAssertEqual(testSubject.trustedCertificates, ["default" : BuildConfig.intermediateCa])
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
        XCTAssertEqual(testSubject.trustedCertificates, ["default" : BuildConfig.intermediateCa])
    }
}
