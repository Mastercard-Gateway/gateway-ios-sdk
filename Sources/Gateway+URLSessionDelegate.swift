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
        
        // go through the cert chain looking for one of our trusted certificates.
        for cert in rawCertsFrom(trust: serverTrust) {
            if BuildConfig.intermediateCas.contains(cert) || trustedCertificates.values.contains(cert) {
                // if one of the trusted certificates was found in the chain, tell the url session to do it's default handling.
                completionHandler(.performDefaultHandling, URLCredential(trust: serverTrust))
                return
            }
        }
        
        // None of our trusted certificates were found so we tell the url session to cancel the authentication challenge
        completionHandler(.cancelAuthenticationChallenge, nil)
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
