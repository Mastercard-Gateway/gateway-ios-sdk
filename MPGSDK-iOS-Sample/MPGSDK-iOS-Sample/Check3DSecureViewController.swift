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
import MPGSDK

/// This view asks the user to confirm thier payment information before checking the session to see if the card is enrolled in 3DSecure.  If enrolled, it presents the Gateway3DSecureViewController from the gateway sdk.
class Check3DSecureViewController: UIViewController, TransactionConsumer {

    lazy var loadingViewController: LoadingViewController = {
        let vc = storyboard!.instantiateViewController(withIdentifier: "loading") as! LoadingViewController
        vc.localizedTitle = "Please Wait"
        vc.localizedDescription = "Checking 3DSecure Enrollment"
        return vc
    }()

    var transaction: Transaction? {
        didSet {
            syncMaskedCard()
        }
    }
    
    var apiVersion : Int!
    
    @IBOutlet weak var cardNumberField: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        syncMaskedCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncMaskedCard()
    }
    
    
    // MARK: - Check 3DS Enrollment
    @IBAction func checkEnrollment() {
        guard let transaction = transaction else { return }
        present(loadingViewController, animated: true) {
            let dddsid = self.randomID() // a generated 3DSecure Identifier
            // The redirect url should redirect to a URL provided by your merchant server.  If you are using the provided sample merchant server, it
            MerchantAPI.shared?.check3DSEnrollment(transaction, threeDSecureId: dddsid, redirectURL: merchantServerUrl.appending("/3DSecureResult.php?3DSecureId=\(dddsid)"), completion: self.enrollmentStatusReceived)
        }
    }
    
    fileprivate func handleEnrollmentStatus(_ result: Result<GatewayMap>) {
        switch result {
        case .success(let response):
            print(response)
            guard let _apiVersionString = response[at: "apiVersion"] as? String,
                let _apiVersion = Int(_apiVersionString) else {
                    self.showError()
                    return
                }
            apiVersion = _apiVersion
            
            // for API versions <= 46, you must use the summary status field to determine next steps for 3DS
            if apiVersion <= 46 {
                if let code = response[at: "gatewayResponse.3DSecure.summaryStatus"] as? String {
                    switch code {
                        case "CARD_ENROLLED":
                            // For enrolled cards, get the htmlBodyContent and present the Gateway3DSecureViewController
                            if let html = response[at: "gatewayResponse.3DSecure.authenticationRedirect.simple.htmlBodyContent"] as? String {
                                self.transaction?.threeDSecureId = response[at: "gatewayResponse.3DSecureId"] as? String
                                self.begin3DSAuth(simple: html)
                            }
                        case "CARD_DOES_NOT_SUPPORT_3DS":
                            // for cards that do not support 3DSecure, , go straight to payment confirmation
                            self.confirmPayment()
                        case "CARD_NOT_ENROLLED", "AUTHENTICATION_NOT_AVAILABLE":
                            // for cards that are not enrolled or if authentication is not available, go to payment confirmation but include the 3DSecureID
                            self.transaction?.threeDSecureId = response[at: "gatewayResponse.3DSecureId"] as? String
                            self.confirmPayment()
                        
                        default:
                            self.showError()
                    }
                } else {
                    self.showError()
                }
                
            // for API versions >= 47, you must look to the gateway recommendation and the presence of 3DS info in the payload
            } else {
                if let recommendaition = response[at: "gatewayResponse.response.gatewayRecommendation"] as? String {
                    // if DO_NOT_PROCEED returned in recommendation, should stop transaction
                    if recommendaition == "DO_NOT_PROCEED" {
                        self.showError()
                    }
                    
                    // if PROCEED in recommendation, and we have HTML for 3DS, perform 3DS
                    if let html = response[at: "gatewayResponse.3DSecure.authenticationRedirect.simple.htmlBodyContent"] as? String {
                        self.transaction?.threeDSecureId = response[at: "gatewayResponse.3DSecureId"] as? String
                        self.begin3DSAuth(simple: html)
                    } else {
                        // if PROCEED in recommendation, but no HTML, finish the transaction without 3DS
                        self.transaction?.threeDSecureId = response[at: "gatewayResponse.3DSecureId"] as? String
                        self.confirmPayment()
                    }
                }
            }
        case .error(_):
            self.showError()
        }
    }
    
    fileprivate func enrollmentStatusReceived(_ result: Result<GatewayMap>) {
        DispatchQueue.main.async {
            self.loadingViewController.dismiss(animated: true) {
                self.handleEnrollmentStatus(result)
            }
        }
    }
     
    // MARK: - 3DSecure Authentiation
    fileprivate func begin3DSAuth(simple: String) {
        // instatniate the Gateway 3DSecureViewController and present it
        let threeDSecureView = Gateway3DSecureViewController(nibName: nil, bundle: nil)
        present(threeDSecureView, animated: true)
        
        // Optionally customize the presentation
        threeDSecureView.title = "3-D Secure Auth"
        threeDSecureView.navBar.tintColor = UIColor(red: 1, green: 0.357, blue: 0.365, alpha: 1)
        
        threeDSecureView.authenticatePayer(htmlBodyContent: simple, handler: handle3DS(authView:result:))
    }
    
    func handle3DS(authView: Gateway3DSecureViewController, result: Gateway3DSecureResult) {
        // dismiss the 3DSecureViewController
        authView.dismiss(animated: true, completion: {
            
            switch result {
            case .error(_):
                self.showAuthenticationError() // failed authentication
            case .completed(gatewayResult: let result):
                if self.apiVersion <= 46, let status = result[at: "3DSecure.summaryStatus"] as? String , status == "AUTHENTICATION_FAILED" {
                    self.showError()
                } else if let status = result[at: "response.gatewayRecommendation"] as? String, status == "DO_NOT_PROCEED"  {
                     self.showError()
                }
                
                self.transaction?.threeDSecureId = result[at: "3DSecureId"] as? String
                self.confirmPayment() // continue with the payment for all other statuses
            default:
                self.showAuthenticationCancelled()
            }
        })
    }
    
    // MARK: -
    fileprivate func confirmPayment() {
        performSegue(withIdentifier: "payOperation", sender: nil)
    }
    
    
    fileprivate func syncMaskedCard() {
        cardNumberField?.text = transaction?.maskedCardNumber
    }
    
    fileprivate func showError() {
        let alert = UIAlertController(title: "Error", message: "Unable to check 3DSecure Enrollment Status.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showAuthenticationError() {
        let alert = UIAlertController(title: "Error", message: "Unable to complete 3DS authentication.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showAuthenticationCancelled() {
        let alert = UIAlertController(title: "Error", message: "3DSecure authentication cancelled.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var destination = segue.destination as? TransactionConsumer {
            destination.transaction = transaction
        }
    }
    
    fileprivate func randomID() -> String {
        return String(UUID().uuidString.split(separator: "-").first!)
    }
    
    
    
}
