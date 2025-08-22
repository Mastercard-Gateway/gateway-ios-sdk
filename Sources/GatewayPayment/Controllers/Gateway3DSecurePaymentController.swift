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

/// A view controller that handles 3D Secure 1.0 authentication flow using a WKWebView.
/// Loads the ACS (Access Control Server) page within a WebView and listens for a redirect URL
/// to detect when the user completes the authentication process.
public class Gateway3DSecureViewController: BaseGatewayPaymentController {
    
    /// The gateway host identifier used for 3D Secure authentication flows.
    /// This value is used internally to determine if the redirect or callback
    /// is related to a 3D Secure operation.
    /// - Returns: A `String` value `"3dsecure"` representing the 3DS-specific host.
    override var gatewayHost: String { "3dsecure" }

    /// The query parameter key used to extract the 3D Secure authentication result from the callback URL.
    /// This parameter is typically included in the return URL after a browser-based
    /// 3D Secure flow and is used to parse the final result returned from the Access Control Server (ACS).
    /// - Returns: A `String` value `"acsResult"` used to locate the result data.
    override var gatewayResultParam: String { "acsResult" }
    
}
