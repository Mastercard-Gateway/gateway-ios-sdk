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
import Security

enum CertificateError: Error {
    case invalidFormat
    
    public var description: String {
        switch self {
        case .invalidFormat:
            return "The provided certificate could not be parsed into an x509 certificate"
        }
    }
}

/// A struct for representing X509 Certificates
struct X509Cert {
    
    
    /// The raw certificate data in DER format
    let derData: Data
    
    /// Create a certificate from raw DER data
    ///
    /// - Parameter der: Certificate data in DER format
    /// - Throws: 'CertificateError.invalidFormat' if the data could not be parsed into a SecCertificate.
    init(der: Data) throws {
        self.derData = der
        _ = try getSecCertificate() // attempt to get the SecCertificate to validate the certificate
    }
}

// MARK: - PEM Extension for parsing PEM strings into DER certificates
extension X509Cert {
    /// Create a cert from a PEM (or Base64 encoded string)
    ///
    /// - Parameter pem: A string with the certificate data in PEM format.
    /// - Throws: 'CertificateError.invalidFormat' if the provided string did not contain Base64 encoded data or if the underlying data could not be parsed into a SecCertificate.
    public init(pem: String) throws {
        let pemHeader = "-----BEGIN CERTIFICATE-----"
        let pemFooter = "-----END CERTIFICATE-----"
        
        var certString = pem.trimmingCharacters(in: .whitespacesAndNewlines) // drop whitespaces
        certString = certString.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
        certString = certString.replacingOccurrences(of: pemHeader, with: "", options: .literal, range: nil)
        certString = certString.replacingOccurrences(of: pemFooter, with: "", options: .literal, range: nil)
        
        guard let certData = Data(base64Encoded: certString) else {
            throw CertificateError.invalidFormat
        }
        
        try self.init(der: certData)
    }
}

// MARK: - SecCertificate Extension
extension X509Cert {
    
    /// Create a SecCertificate from the DER data stored in the X.509 certificate
    ///
    /// - Returns: A SecCertificate from the DER data.
    /// - Throws: 'CertificateError.invalidFormat' if SecCertificate was unable to parse the data.
    func getSecCertificate() throws -> SecCertificate {
        // attempt to create a SecCertificate from the DER data
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: derData.count)
        derData.copyBytes(to: buffer, count: derData.count)
        let size = derData.count
        let cert = SecCertificateCreateWithData(nil, CFDataCreate(nil, buffer, size))
        buffer.deallocate(capacity: size)
        // if cert creation was not successfull throw an exception
        if let cert = cert {
            return cert
        } else {
            throw CertificateError.invalidFormat
        }
    }
}
