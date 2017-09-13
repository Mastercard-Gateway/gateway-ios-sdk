import XCTest
@testable import MPGSDK

class GatewayTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitWithDefaultAPIVersion() {
        let testSubject = Gateway(region: .test, merchantId: "123456789")
        XCTAssertEqual(testSubject.region, .test)
        XCTAssertEqual(testSubject.merchantId, "123456789")
        XCTAssertEqual(testSubject.apiVersion, BuildConfig.defaultAPIVersion)
    }
    
    func testInitWithCustomAPIVersion() {
        let testSubject = Gateway(region: .test, merchantId: "123456789", apiVersion: 9)
        XCTAssertEqual(testSubject.region, .test)
        XCTAssertEqual(testSubject.merchantId, "123456789")
        XCTAssertEqual(testSubject.apiVersion, 9)
    }
    
}
