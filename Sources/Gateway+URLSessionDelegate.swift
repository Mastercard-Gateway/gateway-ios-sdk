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

// MARK: - Certificate Pinning
extension Gateway: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS
        
        // verify that the request is using server trust and that there is a server trust object
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // evaluate the certificate chain
        var secResult = SecTrustResultType.invalid
        let validResults: [SecTrustResultType] = [.proceed, .unspecified]
        guard SecTrustEvaluate(serverTrust, &secResult) == errSecSuccess, validResults.contains(secResult) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // go through the cert chain looking for one of our trusted certificates.
        for cert in rawCertsFrom(trust: serverTrust) {
            if trustedCertificatesData().contains(cert) {
                // if one of the trusted certificates was found in the chain, tell the url session to do it's default handling.
                completionHandler(.performDefaultHandling, URLCredential(trust: serverTrust))
                return
            }
        }
        
        // None of our trusted certificates were found so we tell the url session to cancel the authentication challenge
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
    
    // The raw DER data from all the certificates the gateway is configured to trust.
    fileprivate func trustedCertificatesData() -> [Data] {
        // parse the build config's certs
        return BuildConfig.intermidateCaStrings.map { Data(base64Encoded: $0)! }
    }
    
    // Get the certificates from the SecTrust object as raw data so that we can compare against our trusted certificates.
    fileprivate func rawCertsFrom(trust: SecTrust) -> [Data] {
        let certChainLength = SecTrustGetCertificateCount(trust)
        let indecies = (0..<certChainLength)
        var certs: [Data] = []
        for index in indecies {
            let serverCertificate = SecTrustGetCertificateAtIndex(trust, index)
            if let serverCertificate = serverCertificate {
                let serverCertificateData = SecCertificateCopyData(serverCertificate)
                let data = serverCertificateData as Data
                certs.append(data)
            }
        }
        return certs
    }
}
