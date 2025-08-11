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
public class GatewayBrowserPaymentController: BaseGatewayPaymentController {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate var url: URL? = nil {
        didSet {
            loaderBrowserPayment()
        }
    }
    
    /// Used to authenticate the secure browser payment
    /// - Parameters:
    ///   - url: The url provided by the Browser Payment operation
    ///   - handler: A closure to handle the Browser Payment response
    public func authenticatePayer(url: URL, handler: @escaping (BaseGatewayPaymentController, GatewayPaymentResult) -> Void) {
        self.completion = handler
        self.url = url
    }
    
    fileprivate func loaderBrowserPayment() {
        guard let paymentURL = url else {
            completion?(self, .error(.invalidURL))
            return
        }
        let urlRequest = URLRequest(url: paymentURL)
        webView.load(urlRequest)
    }
}
