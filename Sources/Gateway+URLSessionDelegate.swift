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
        guard SecTrustEvaluate(serverTrust, nil) == errSecSuccess else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        for cert in rawCertsFrom(trust: serverTrust) {
            if trustedCertificates.values.contains(cert) {
                completionHandler(.performDefaultHandling, URLCredential(trust: serverTrust))
                return
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
    
    fileprivate func rawCertsFrom(trust: SecTrust) -> [Data] {
        let certChainLength = SecTrustGetCertificateCount(trust)
        let indecies = (0..<certChainLength)
        var certs: [Data] = []
        for index in indecies {
            let serverCertificate = SecTrustGetCertificateAtIndex(trust, index)
            if let serverCertificate = serverCertificate {
                let serverCertificateData = SecCertificateCopyData(serverCertificate)
                let data = serverCertificateData as NSData as Data // https://bugs.swift.org/browse/SR-1797
                certs.append(data)
            }
        }
        return certs
    }
}
