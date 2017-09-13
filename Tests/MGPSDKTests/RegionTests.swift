import XCTest
@testable import MPGSDK

class RegionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {

        super.tearDown()
    }
    
    func testURLPrefixForAllRegions() {
        XCTAssertEqual(Region.test.urlPrefix, "test")
        XCTAssertEqual(Region.europe.urlPrefix, "eu")
        XCTAssertEqual(Region.northAmerica.urlPrefix, "na")
        XCTAssertEqual(Region.asiaPacific.urlPrefix, "ap")
    }
    
}
