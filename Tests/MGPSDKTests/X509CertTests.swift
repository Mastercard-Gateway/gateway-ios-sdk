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

class X509CertTests: XCTestCase {
    
    let testPemString = """
            -----BEGIN CERTIFICATE-----
            MIIFAzCCA+ugAwIBAgIEUdNg7jANBgkqhkiG9w0BAQsFADCBvjELMAkGA1UEBhMC
            VVMxFjAUBgNVBAoTDUVudHJ1c3QsIEluYy4xKDAmBgNVBAsTH1NlZSB3d3cuZW50
            cnVzdC5uZXQvbGVnYWwtdGVybXMxOTA3BgNVBAsTMChjKSAyMDA5IEVudHJ1c3Qs
            IEluYy4gLSBmb3IgYXV0aG9yaXplZCB1c2Ugb25seTEyMDAGA1UEAxMpRW50cnVz
            dCBSb290IENlcnRpZmljYXRpb24gQXV0aG9yaXR5IC0gRzIwHhcNMTQxMDIyMTcw
            NTE0WhcNMjQxMDIzMDczMzIyWjCBujELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUVu
            dHJ1c3QsIEluYy4xKDAmBgNVBAsTH1NlZSB3d3cuZW50cnVzdC5uZXQvbGVnYWwt
            dGVybXMxOTA3BgNVBAsTMChjKSAyMDEyIEVudHJ1c3QsIEluYy4gLSBmb3IgYXV0
            aG9yaXplZCB1c2Ugb25seTEuMCwGA1UEAxMlRW50cnVzdCBDZXJ0aWZpY2F0aW9u
            IEF1dGhvcml0eSAtIEwxSzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
            ANo/ltBNuS9E59s5XptQ7lylYdpBZ1MJqgCajld/KWvbx+EhJKo60I1HI9Ltchbw
            kSHSXbe4S6iDj7eRMmjPziWTLLJ9l8j+wbQXugmeA5CTe3xJgyJoipveR8MxmHou
            fUAL0u8+07KMqo9Iqf8A6ClYBve2k1qUcyYmrVgO5UK41epzeWRoUyW4hM+Ueq4G
            RQyja03Qxr7qGKQ28JKyuhyIjzpSf/debYMcnfAf5cPW3aV4kj2wbSzqyc+UQRlx
            RGi6RzwE6V26PvA19xW2nvIuFR4/R8jIOKdzRV1NsDuxjhcpN+rdBQEiu5Q2Ko1b
            Nf5TGS8IRsEqsxpiHU4r2RsCAwEAAaOCAQkwggEFMA4GA1UdDwEB/wQEAwIBBjAP
            BgNVHRMECDAGAQH/AgEAMDMGCCsGAQUFBwEBBCcwJTAjBggrBgEFBQcwAYYXaHR0
            cDovL29jc3AuZW50cnVzdC5uZXQwMAYDVR0fBCkwJzAloCOgIYYfaHR0cDovL2Ny
            bC5lbnRydXN0Lm5ldC9nMmNhLmNybDA7BgNVHSAENDAyMDAGBFUdIAAwKDAmBggr
            BgEFBQcCARYaaHR0cDovL3d3dy5lbnRydXN0Lm5ldC9ycGEwHQYDVR0OBBYEFIKi
            cHTdvFM/z3vU981/p2DGCky/MB8GA1UdIwQYMBaAFGpyJnrQHu995ztpUdRsjZ+Q
            EmarMA0GCSqGSIb3DQEBCwUAA4IBAQA/HBpb/0AiHY81DC2qmSerwBEycNc2KGml
            jbEnmUK+xJPrSFdDcSPE5U6trkNvknbFGe/KvG9CTBaahqkEOMdl8PUM4ErfovrO
            GhGonGkvG9/q4jLzzky8RgzAiYDRh2uiz2vUf/31YFJnV6Bt0WRBFG00Yu0GbCTy
            BrwoAq8DLcIzBfvLqhboZRBD9Wlc44FYmc1r07jHexlVyUDOeVW4c4npXEBmQxJ/
            B7hlVtWNw6f1sbZlnsCDNn8WRTx0S5OKPPEr9TVwc3vnggSxGJgO1JxvGvz8pzOl
            u7sY82t6XTKH920l5OJ2hiEeEUbNdg5vT6QhcQqEpy02qUgiUX6C
            -----END CERTIFICATE-----

            """
    
    let testB64DataString = "MIIFAzCCA+ugAwIBAgIEUdNg7jANBgkqhkiG9w0BAQsFADCBvjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUVudHJ1c3QsIEluYy4xKDAmBgNVBAsTH1NlZSB3d3cuZW50cnVzdC5uZXQvbGVnYWwtdGVybXMxOTA3BgNVBAsTMChjKSAyMDA5IEVudHJ1c3QsIEluYy4gLSBmb3IgYXV0aG9yaXplZCB1c2Ugb25seTEyMDAGA1UEAxMpRW50cnVzdCBSb290IENlcnRpZmljYXRpb24gQXV0aG9yaXR5IC0gRzIwHhcNMTQxMDIyMTcwNTE0WhcNMjQxMDIzMDczMzIyWjCBujELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUVudHJ1c3QsIEluYy4xKDAmBgNVBAsTH1NlZSB3d3cuZW50cnVzdC5uZXQvbGVnYWwtdGVybXMxOTA3BgNVBAsTMChjKSAyMDEyIEVudHJ1c3QsIEluYy4gLSBmb3IgYXV0aG9yaXplZCB1c2Ugb25seTEuMCwGA1UEAxMlRW50cnVzdCBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAtIEwxSzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANo/ltBNuS9E59s5XptQ7lylYdpBZ1MJqgCajld/KWvbx+EhJKo60I1HI9LtchbwkSHSXbe4S6iDj7eRMmjPziWTLLJ9l8j+wbQXugmeA5CTe3xJgyJoipveR8MxmHoufUAL0u8+07KMqo9Iqf8A6ClYBve2k1qUcyYmrVgO5UK41epzeWRoUyW4hM+Ueq4GRQyja03Qxr7qGKQ28JKyuhyIjzpSf/debYMcnfAf5cPW3aV4kj2wbSzqyc+UQRlxRGi6RzwE6V26PvA19xW2nvIuFR4/R8jIOKdzRV1NsDuxjhcpN+rdBQEiu5Q2Ko1bNf5TGS8IRsEqsxpiHU4r2RsCAwEAAaOCAQkwggEFMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMECDAGAQH/AgEAMDMGCCsGAQUFBwEBBCcwJTAjBggrBgEFBQcwAYYXaHR0cDovL29jc3AuZW50cnVzdC5uZXQwMAYDVR0fBCkwJzAloCOgIYYfaHR0cDovL2NybC5lbnRydXN0Lm5ldC9nMmNhLmNybDA7BgNVHSAENDAyMDAGBFUdIAAwKDAmBggrBgEFBQcCARYaaHR0cDovL3d3dy5lbnRydXN0Lm5ldC9ycGEwHQYDVR0OBBYEFIKicHTdvFM/z3vU981/p2DGCky/MB8GA1UdIwQYMBaAFGpyJnrQHu995ztpUdRsjZ+QEmarMA0GCSqGSIb3DQEBCwUAA4IBAQA/HBpb/0AiHY81DC2qmSerwBEycNc2KGmljbEnmUK+xJPrSFdDcSPE5U6trkNvknbFGe/KvG9CTBaahqkEOMdl8PUM4ErfovrOGhGonGkvG9/q4jLzzky8RgzAiYDRh2uiz2vUf/31YFJnV6Bt0WRBFG00Yu0GbCTyBrwoAq8DLcIzBfvLqhboZRBD9Wlc44FYmc1r07jHexlVyUDOeVW4c4npXEBmQxJ/B7hlVtWNw6f1sbZlnsCDNn8WRTx0S5OKPPEr9TVwc3vnggSxGJgO1JxvGvz8pzOlu7sY82t6XTKH920l5OJ2hiEeEUbNdg5vT6QhcQqEpy02qUgiUX6C"
    
    let testDerData = try! Data(contentsOf: Bundle.init(for: X509CertTests.self).url(forResource: "testcert", withExtension: "cer")!)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCertFromDERData() {
        
        var cert: X509Cert? = nil
        XCTAssertNoThrow(cert = try X509Cert(der: testDerData))
        XCTAssertNotNil(cert)
        XCTAssertEqual(cert?.derData, testDerData)
    }
    
    func testCertFromPEMString() {
        var cert: X509Cert? = nil
        XCTAssertNoThrow(cert = try X509Cert(pem: testPemString))
        XCTAssertNotNil(cert)
        XCTAssertEqual(cert?.derData, testDerData)
    }
    
    func testCertFromBase64String() {
        var cert: X509Cert? = nil
        XCTAssertNoThrow(cert = try X509Cert(pem: testB64DataString))
        XCTAssertNotNil(cert)
        XCTAssertEqual(cert?.derData, testDerData)
    }
    
    func testCertThrowsWithInvalidData() {
        var cert: X509Cert? = nil
        do {
            cert = try X509Cert(der: Data("definately not a cert".utf8))
            XCTFail("Constructing a certificate with bad data succeeded")
        } catch CertificateError.invalidFormat {
            XCTAssertNil(cert)
        } catch {
            XCTFail("Constructing a certificate with bad data threw unexpected error")
        }
    }
    
    func testCertThrowsWithNonBase64String() {
        var cert: X509Cert? = nil
        do {
            cert = try X509Cert(pem: "definately not a cert")
            XCTFail("Constructing a certificate with invalid string succeeded")
        } catch CertificateError.invalidFormat {
            XCTAssertNil(cert)
        } catch {
            XCTFail("Constructing a certificate with invalid string threw unexpected error")
        }
    }
}
