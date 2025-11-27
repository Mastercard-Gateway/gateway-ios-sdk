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

import UIKit

/// A view controller to handle browser-based redirect flows for Ottu or other hosted payment pages.
/// Similar in function to `ThreeDSecureViewController`, this controller loads a URL in a WebView and
/// listens for a custom scheme redirect indicating the result of the user’s interaction with the payment page.
/// Useful for non-3DS, browser-based payment validations.
final public class GatewayBrowserPaymentController: BaseGatewayPaymentController {
    
    /// The gateway host identifier used for browser-based payment authentication flows.
    /// This value helps the system recognize redirects or callbacks that are part of
    /// a browser payment process.
    /// - Returns: A `String` value `"browserpayment"` representing the browser payment host.
    override var gatewayHost: String { "browserpayment" }

    /// The query parameter key used to extract the browser payment result from the callback URL.
    /// This parameter is typically present in the return URL after the user completes
    /// the browser-based payment flow. It's used to retrieve the final result returned by the payment gateway.
    /// - Returns: A `String` value `"orderResult"` used to locate the result data.
    override var gatewayResultParam: String { "orderResult" }
    
}
