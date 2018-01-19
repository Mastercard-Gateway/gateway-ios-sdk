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

class MockURLProtectionSpace: URLProtectionSpace {
    var mockServerTrust: SecTrust? = nil
    override var serverTrust: SecTrust? {
        get {
            return mockServerTrust
        }
        set {
            mockServerTrust = newValue
        }
    }
}

class MockURLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    override init() {}
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) { }
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) { }
    func cancel(_ challenge: URLAuthenticationChallenge) { }
}

class GatewayURLSessionDelegateTests: XCTestCase {
    
    var testSubject = Gateway(region: .mtf, merchantId: "TEST")
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCancelOnNonServerTrustAuthenticationMethod() {
        let protectionSpace = MockURLProtectionSpace(host: "test.com", port: 443, protocol: "https", realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
        let challengeSender = MockURLAuthenticationChallengeSender()
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: challengeSender)
        
        testSubject.urlSession(testSubject.urlSession, didReceive: challenge) { (disposition, credential) in
            XCTAssertEqual(.cancelAuthenticationChallenge, disposition)
            XCTAssertNil(credential)
        }
    }
    
    func testCancelOnIfServerTrustMissing() {
        let protectionSpace = MockURLProtectionSpace(host: "test.com", port: 443, protocol: "https", realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        let challengeSender = MockURLAuthenticationChallengeSender()
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: challengeSender)
        
        testSubject.urlSession(testSubject.urlSession, didReceive: challenge) { (disposition, credential) in
            XCTAssertEqual(.cancelAuthenticationChallenge, disposition)
            XCTAssertNil(credential)
        }
    }
    
    func testCancelWhenCertNotFound() {
        let certChain = [loadCert("untrusted-leaf"), loadCert("untrusted-intermediate"), loadCert("untrusted-ca")]
        var serverTrust: SecTrust?
        SecTrustCreateWithCertificates(certChain as AnyObject,
                                          SecPolicyCreateBasicX509(),
                                          &serverTrust)
        
        let protectionSpace = MockURLProtectionSpace(host: "test.com", port: 443, protocol: "https", realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        protectionSpace.serverTrust = serverTrust
        let challengeSender = MockURLAuthenticationChallengeSender()
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: challengeSender)
        
        testSubject.urlSession(testSubject.urlSession, didReceive: challenge) { (disposition, credential) in
            XCTAssertEqual(.cancelAuthenticationChallenge, disposition)
            XCTAssertNil(credential)
        }
    }
    
    func testCancelWhenChainDoesNotEvaluate() {
        let certChain = [loadCert("invalid-leaf"), loadCert("untrusted-intermediate"), loadCert("untrusted-ca")]
        var serverTrust: SecTrust?
        SecTrustCreateWithCertificates(certChain as AnyObject,
                                       nil,
                                       &serverTrust)
        let protectionSpace = MockURLProtectionSpace(host: "test.com", port: 443, protocol: "https", realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        protectionSpace.serverTrust = serverTrust
        let challengeSender = MockURLAuthenticationChallengeSender()
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: challengeSender)
        
        testSubject.urlSession(testSubject.urlSession, didReceive: challenge) { (disposition, credential) in
            XCTAssertEqual(.cancelAuthenticationChallenge, disposition)
            XCTAssertNil(credential)
        }
    }
    
    func testDefaultHandlingWhenCertFound() {
        let certChain = [loadCert("trusted-leaf"), loadCert("trusted-intermediate"), loadCert("trusted-ca")]
        var serverTrust: SecTrust?
        SecTrustCreateWithCertificates(certChain as AnyObject,
                                       SecPolicyCreateBasicX509(),
                                       &serverTrust)
        let protectionSpace = MockURLProtectionSpace(host: "test.com", port: 443, protocol: "https", realm: nil, authenticationMethod: NSURLAuthenticationMethodServerTrust)
        protectionSpace.serverTrust = serverTrust
        print(SecTrustGetCertificateCount(protectionSpace.serverTrust!))
        let challengeSender = MockURLAuthenticationChallengeSender()
        let challenge = URLAuthenticationChallenge(protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0, failureResponse: nil, error: nil, sender: challengeSender)
        
        testSubject.urlSession(testSubject.urlSession, didReceive: challenge) { (disposition, credential) in
            XCTAssertEqual(.performDefaultHandling, disposition)
            XCTAssertNotNil(credential)
        }
    }
    
    private func loadCert(_ named: String) -> SecCertificate? {
        let certPath = Bundle(for: type(of: self)).path(forResource: named, ofType: "cer")!
        let certData = try! Data(contentsOf: URL(fileURLWithPath: certPath))
        return SecCertificateCreateWithData(nil, certData as CFData)
    }
}
