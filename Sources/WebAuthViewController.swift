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

public enum WebAuthResult {
    case completed(status: String, id: String)
    case cancelled
}

public class WebAuthViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    
    /// The navigation Bar shown at the top of the view
    public var navBar: UINavigationBar!
    
    /// The cancel button allowing the user to abandon 3DS Authentication
    public var cancelButton: UIBarButtonItem!
    
    var gatewayScheme: String = "gatewaysdk"
    var gatewayHost: String = "3dsecure"
    var redirectStatusParam: String = "summaryStatus"
    var _3DSecureIdParam: String = "3DSecureId"
    
    fileprivate var completion: ((WebAuthViewController, WebAuthResult) -> Void)?
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
    
    public func AuthenticatePayer(htmlBodyContent: String, handler: @escaping (WebAuthViewController, WebAuthResult) -> Void) {
        self.completion = handler
        self.bodyContent = htmlBodyContent
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        navigationItem.leftBarButtonItems = [cancelButton]
        
        navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = .white
        navBar.items = [self.navigationItem]
        view.addSubview(navBar)
        
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        var constraints: [NSLayoutConstraint] = []
        if #available(iOSApplicationExtension 11.0, *) {
            constraints.append(NSLayoutConstraint(item: navBar, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0))
        } else {
            constraints.append(NSLayoutConstraint(item: navBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        }
        
        constraints.append(NSLayoutConstraint(item: navBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: navBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: navBar, attribute: .bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        NSLayoutConstraint.activate(constraints)
    }
    
    fileprivate func loadContent() {
        webView.loadHTMLString(bodyContent ?? "", baseURL: nil)
    }
    
    @objc func cancelAction() {
        completion?(self, .cancelled)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let comp = URLComponents(url: url, resolvingAgainstBaseURL: false), comp.scheme == gatewayScheme, comp.host == gatewayHost {
            decisionHandler(.cancel)
            
            let statusItem = comp.queryItems?.first { (item) -> Bool in
                return item.name == redirectStatusParam
            }
            let idItem = comp.queryItems?.first { (item) -> Bool in
                return item.name == _3DSecureIdParam
            }
            
            if let status = statusItem?.value, let _3DSecureId = idItem?.value {
                completion?(self, .completed(status: status, id: _3DSecureId))
            } else {
                completion?(self, .cancelled)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
}
