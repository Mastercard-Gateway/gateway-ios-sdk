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

/// An enum representing errors encountered during the 3D Secure (3DS) redirect flow in a Gateway-based payment process.
/// These errors may occur while handling responses from the gateway, parsing response data,
/// or interacting with external web resources such as browser-based authentication.
/// Use this error type to diagnose and handle issues that arise during authentication flows.
public enum GatewayPaymentError: Error {
    
    /// The response from the gateway was missing.
    /// This typically indicates that no data was returned after the 3DS or browser redirect.
    case missingGatewayResponse
    
    /// Failed to parse or map the JSON string returned by the gateway.
    /// This could happen due to an unexpected format or invalid data structure.
    case mappingError
    
    /// The URL provided for browser-based payment authentication is invalid.
    /// Ensure the URL is well-formed and non-nil before attempting to open it.
    case invalidURL
    
    /// An SSL error occurred, possibly due to an insecure connection or an unknown server.
    /// The connection was rejected for security reasons.
    case sslError
    
    /// A general or unknown error occurred during the authentication process.
    /// - Parameter error: The underlying error that caused the failure.
    case paymentError(Error)
    
    /// A user-friendly description of the error, suitable for displaying in logs or UI.
    public var localizedDescription: String {
        switch self {
        case .missingGatewayResponse:
            return "The response from the gateway was missing."
        case .mappingError:
            return "An error occurred while attempting to map the JSON response."
        case .invalidURL:
            return "The URL provided is not valid."
        case .sslError:
            return "An SSL error occurred. A secure connection to the server could not be established."
        case .paymentError(let error):
            return error.localizedDescription
        }
    }
}
