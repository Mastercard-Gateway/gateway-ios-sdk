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

/// An enum representing the status of the Gateway payment authentication.
/// This result type is returned upon the completion of a Gateway-based payment authentication process,
/// such as 3D Secure or browser-based redirects. It indicates whether the authentication was successful,
/// cancelled by the user, or failed due to an error.
/// Use this enum to handle the outcome of the authentication flow in your app logic.
/// - Note: Typically returned in the completion handler of a method like `authenticatePayer(completion:)`.
public enum GatewayPaymentResult {
    
    /// The authentication was successfully completed.
    /// - Parameter gatewayResult: A `GatewayMap` object containing key-value data from the Gateway,
    ///   such as transaction status, reference numbers, or any other metadata returned upon success.
    case completed(gatewayResult: GatewayMap)
    
    /// The authentication failed with an error.
    /// - Parameter error: A `GatewayPaymentError` describing the failure reason,
    ///   such as network issues, invalid redirect, or parsing errors.
    case error(GatewayPaymentError)
    
    /// The authentication was cancelled by the user.
    /// This typically occurs when the user dismisses or exits the authentication flow
    /// (e.g. closing a 3D Secure web view or browser tab) before completing it.
    /// No transaction or result data will be available in this case.
    case cancelled
}
