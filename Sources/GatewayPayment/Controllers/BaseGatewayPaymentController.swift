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
import WebKit

/// A view controller to perform 3DSecure 1.0 or browser-based Ottu payment authentication using an embedded web view.
/// This controller is responsible for presenting a WebView to complete authentication flows such as 3D Secure or browser-based redirections.
/// It listens for a URL redirect in the following format:
//     gatewaysdk://3dsecure?paymentResult=<jsonData>
/// When this redirect occurs, the controller will parse the `paymentResult` JSON data embedded in the query parameters
/// and pass the result to the completion handler provided in the `authenticatePayer(completion:)` function.
/// This controller is typically used by the payment SDK or host application to authenticate the user as part of the payment flow.
public class BaseGatewayPaymentController: UIViewController {
    
    /// The internal webview used to perform authentication.
    var webView: WKWebView!
    
    /// The navigation Bar shown at the top of the view
    public var navBar: UINavigationBar!
    
    /// The cancel button allowing the user to abandon 3DS Authentication
    public var cancelButton: UIBarButtonItem!
    
    /// An activity indicatior that is displayed any time there is activity on the web view
    public var activityIndicator: UIActivityIndicatorView!
    
    /// The expected host value in the redirect URL used to identify the payment type or flow.
    /// This helps determine whether the redirect is related to a specific payment flow
    var gatewayHost: String { "" }
    
    /// The query parameter key used to extract payment result data from the redirect URL,
    /// depending on the payment type
    /// This key is used to parse the result returned after a redirect flow,
    var gatewayResultParam: String { "" }
    
    /// The custom URL scheme registered by the application to handle redirects from the payment gateway.
    /// This scheme is used to intercept the return URL after authentication is complete.
    /// Default value: `"gatewaysdk"`for all type of payment
    fileprivate var gatewayScheme: String = "gatewaysdk"
    
    fileprivate var bodyContent: String? = nil {
        didSet {
            loadContent()
        }
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    var completion: ((BaseGatewayPaymentController, GatewayPaymentResult) -> Void)?
    
    /// Authenticates the payer using an HTML-based flow (e.g., 3DSecure or browser-based payments rendered via HTML).
    /// - Parameters:
    ///   - htmlBodyContent: The HTML body provided for rendering the authentication UI.
    ///   - handler: A closure to handle the result of the authentication process.
    ///
    public func authenticatePayer(htmlBodyContent: String, handler: @escaping (BaseGatewayPaymentController, GatewayPaymentResult) -> Void) {
        self.completion = handler
        self.bodyContent = htmlBodyContent
    }
    
    fileprivate func loadContent() {
        webView.loadHTMLString(bodyContent ?? "", baseURL: nil)
    }
    
    fileprivate func setupView() {
        view.backgroundColor = .white
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        navigationItem.leftBarButtonItems = [cancelButton]
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: activityIndicator)]
        
        navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = .white
        navBar.items = [self.navigationItem]
        view.addSubview(navBar)
        
        let config = WKWebViewConfiguration()
        if #available(iOS 14.0, *) {
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true
            config.defaultWebpagePreferences = preferences
        } else {
            // For iOS <14
            config.preferences.javaScriptEnabled = true
        }
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(webView)
        
        var constraints: [NSLayoutConstraint] = []
        if #available(iOSApplicationExtension 11.0, *) {
            constraints.append(NSLayoutConstraint(item: navBar!, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0))
        } else {
            constraints.append(NSLayoutConstraint(item: navBar!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        }
        
        constraints.append(NSLayoutConstraint(item: navBar!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: navBar!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: webView!, attribute: .top, relatedBy: .equal, toItem: navBar, attribute: .bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: webView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: webView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: webView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func cancelAction() {
        completion?(self, .cancelled)
    }
}

// MARK: - WKNavigationDelegate methods
extension BaseGatewayPaymentController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url,
           let comp = URLComponents(url: url, resolvingAgainstBaseURL: false),
           comp.scheme == gatewayScheme, comp.host == gatewayHost {
            decisionHandler(.cancel)
            
            let gatewayResultItem = comp.queryItems?.first { (item) -> Bool in
                return item.name == gatewayResultParam
            }
            
            guard let gatewayString = gatewayResultItem?.value, let gatewayData = gatewayString.data(using: .utf8) else {
                completion?(self, .error(GatewayPaymentError.missingGatewayResponse))
                return
            }
            
            do {
                let gatewayResult = try JSONDecoder().decode(GatewayMap.self, from: gatewayData)
                completion?(self, .completed(gatewayResult: gatewayResult))
            } catch {
                completion?(self, .error(GatewayPaymentError.mappingError))
            }
            return
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        let err = error as NSError
        if err.code == -1200, err.localizedDescription.contains("SSL") {
            completion?(self, .error(.sslError))
        } else if err.code == 102 {
            return
        }
    }
}
