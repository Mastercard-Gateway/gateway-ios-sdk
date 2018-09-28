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

class ProcessPaymentViewController: UIViewController {
    // MARK: - Properties
    var transaction: Transaction = Transaction()

    // the object used to communicate with the merchant's api
    var merchantAPI: MerchantAPI!
    // the ojbect used to communicate with the gateway
    var gateway: Gateway!
    
    // MARK: View Outlets
    @IBOutlet weak var createSessionStatusImageView: UIImageView!
    @IBOutlet weak var createSessionActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectCardStatusImageView: UIImageView!
    @IBOutlet weak var collectCardActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var updateSessionStatusImageView: UIImageView!
    @IBOutlet weak var updateSessionActivityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var check3dsLabel: UILabel?
    @IBOutlet weak var check3dsStatusImageView: UIImageView!
    @IBOutlet weak var check3dsActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var processPaymentStatusImageView: UIImageView!
    @IBOutlet weak var processPaymentActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var paymentStatusView: UIView?
    @IBOutlet weak var paymentStatusIconView: UIImageView?
    @IBOutlet weak var statusTitleLabel: UILabel?
    @IBOutlet weak var statusDescriptionLabel: UILabel?
    
    @IBOutlet weak var continueButton: UIButton!
    
    // The next action to be executed when tapping the continue button
    var currentAction: (() -> Void)?
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // resets the payment view controller to a clean state prior to running a transaction
    func reset() {
        createSessionStatusImageView.isHidden = true
        createSessionActivityIndicator.stopAnimating()
        collectCardStatusImageView.isHidden = true
        collectCardActivityIndicator.stopAnimating()
        updateSessionStatusImageView.isHidden = true
        updateSessionActivityIndicator.stopAnimating()
        check3dsStatusImageView.isHidden = true
        check3dsActivityIndicator.stopAnimating()
        processPaymentStatusImageView.isHidden = true
        processPaymentActivityIndicator.stopAnimating()
        
        paymentStatusView?.isHidden = true
        statusTitleLabel?.text = nil
        statusDescriptionLabel?.text = nil
        
        setAction(action: createSession, title: "Pay \(transaction.amountFormatted)")
    }
    
    func finish() {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Called to configure the view controller with the gateway and merchant service information.
    func configure(merchantId: String, region: GatewayRegion, merchantServiceURL: URL, applePayMerchantIdentifier: String?) {
        gateway = Gateway(region: region, merchantId: merchantId)
        merchantAPI = MerchantAPI(url: merchantServiceURL)
        transaction.applePayMerchantIdentifier = applePayMerchantIdentifier
    }
    
    
    @IBAction func continueAction(sender: Any) {
        currentAction?()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if the view being presented is the card collection view, wait register the callbacks for when card information is collected or cancelled
        if let nav = segue.destination as? UINavigationController, let cardVC = nav.viewControllers.first as? CollectCardInfoViewViewController {
            cardVC.viewModel.transaction = transaction
            cardVC.completion = cardInfoCollected
            cardVC.cancelled = cardInfoCancelled
        }
    }
 
}

// MARK: - 1. Create Session
extension ProcessPaymentViewController {
    /// This function creates a new session using the merchant service
    func createSession() {
        // update the UI
        createSessionActivityIndicator.startAnimating()
        continueButton.isEnabled = false
        continueButton.backgroundColor = .lightGray
        
        merchantAPI.createSession { (result) in
            DispatchQueue.main.async {
                // stop the activity indictor
                self.createSessionActivityIndicator.stopAnimating()
                guard case .success(let response) = result,
                    "SUCCESS" == response[at: "gatewayResponse.result"] as? String,
                    let session = response[at: "gatewayResponse.session.id"] as? String,
                    let apiVersion = response[at: "apiVersion"] as? String else {
                        // if anything was missing, flag the step as having errored
                        self.stepErrored(message: "Error Creating Session", stepStatusImageView: self.createSessionStatusImageView)
                        return
                }
                
                // The session was created successfully
                self.transaction.session = GatewaySession(id: session, apiVersion: apiVersion)
                self.stepCompleted(stepStatusImageView: self.createSessionStatusImageView)
                self.collectCardInfo()
            }
        }
    }
}

// MARK: - 2. Collect Card Info
extension ProcessPaymentViewController {
    // Presents the card collection UI and waits for a response
    func collectCardInfo() {
        // update the UI
        collectCardActivityIndicator.startAnimating()
        
        performSegue(withIdentifier: "collectCardInfo", sender: nil)
    }
    
    func cardInfoCollected(transaction: Transaction) {
        // populate the card information
        self.transaction = transaction
        // mark the step as completed
        stepCompleted(stepStatusImageView: collectCardStatusImageView)
        collectCardActivityIndicator.stopAnimating()
        // start the action to update the session with payer data
        self.updateWithPayerData()
    }
    
    func cardInfoCancelled() {
        collectCardActivityIndicator.stopAnimating()
        self.stepErrored(message: "Card Information Not Entered", stepStatusImageView: self.collectCardStatusImageView)
    }
}

// MARK: - 3. Update Session With Payer Data
extension ProcessPaymentViewController {
    // Updates the gateway session with payer data using the gateway.updateSession function
    func updateWithPayerData() {
        // update the UI
        updateSessionActivityIndicator.startAnimating()
    
        guard let sessionId = transaction.session?.id, let apiVersion = transaction.session?.apiVersion else { return }
        
        // construct the Gateway Map with the desired parameters.
        var request = GatewayMap()
        request[at: "sourceOfFunds.provided.card.nameOnCard"] = transaction.nameOnCard
        request[at: "sourceOfFunds.provided.card.number"] = transaction.cardNumber
        request[at: "sourceOfFunds.provided.card.securityCode"] = transaction.cvv
        request[at: "sourceOfFunds.provided.card.expiry.month"] = transaction.expiryMM
        request[at: "sourceOfFunds.provided.card.expiry.year"] = transaction.expiryYY
        
        // if the transaction has an Apple Pay Token, populate that into the map
        if let tokenData = transaction.applePayPayment?.token.paymentData, let token = String(data: tokenData, encoding: .utf8) {
            request[at: "sourceOfFunds.provided.card.devicePayment.paymentToken"] = token
        }
        
        // execute the update
        gateway.updateSession(sessionId, apiVersion: apiVersion, payload: request, completion: updateSessionHandler(_:))
    }
    
    // Call the gateway to update the session.
    fileprivate func updateSessionHandler(_ result: GatewayResult<GatewayMap>) {
        DispatchQueue.main.async {
            self.updateSessionActivityIndicator.stopAnimating()
            
            guard case .success(_) = result else {
                self.stepErrored(message: "Error Updating Session", stepStatusImageView: self.updateSessionStatusImageView)
                return
            }
            
            // mark the step as completed
            self.stepCompleted(stepStatusImageView: self.updateSessionStatusImageView)
            
            // check for 3DS enrollment
            self.check3dsEnrollment()
        }
    }
}

// MARK: - 4. Check 3DS Enrollment
extension ProcessPaymentViewController {
    // uses the gateway (throught the merchant service) to check the card to see if it is enrolled in 3D Secure
    func check3dsEnrollment() {
        // if the transaction is an Apple Pay Transaction, 3DSecure is not supported.  Therfore, the app should skip this step and no longer provide a 3DSecureId
        guard !transaction.isApplePay else {
            check3dsActivityIndicator.isHidden = true
            check3dsStatusImageView.isHidden = true
            check3dsLabel?.attributedText = NSAttributedString(string: "Check 3DS Enrollment", attributes: [.strikethroughStyle: 1])
            transaction.threeDSecureId = nil
            prepareForProcessPayment()
            return
        }
        
        // update the UI
        check3dsActivityIndicator.startAnimating()
        
        // A redirect URL for 3D Secure that will redirect the browser back to a page on our merchant service after 3D Secure authentication
        let redirectURL = merchantAPI.merchantServerURL.absoluteString.appending("/3DSecureResult.php?3DSecureId=\(transaction.threeDSecureId!)")
        // check enrollment
        merchantAPI.check3DSEnrollment(transaction: transaction, redirectURL: redirectURL , completion: check3DSEnrollmentHandler)
    }
    
    func check3DSEnrollmentHandler(_ result: Result<GatewayMap>) {
        DispatchQueue.main.async {
            self.check3dsActivityIndicator.stopAnimating()
            if Int(self.transaction.session!.apiVersion)! <= 46 {
                self.check3DSEnrollmentV46Handler(result)
            } else {
                self.check3DSEnrollmentv47Handler(result)
            }
        }
    }
    
    func check3DSEnrollmentV46Handler(_ result: Result<GatewayMap>) {
        guard case .success(let response) = result, let code = response[at: "gatewayResponse.3DSecure.summaryStatus"] as? String else {
            self.stepErrored(message: "Error checking 3DS Enrollment", stepStatusImageView: self.check3dsStatusImageView)
            return
        }
        
        // check to see if the card was enrolled, not enrolled or does not support 3D Secure
        switch code {
        case "CARD_ENROLLED":
            // For enrolled cards, get the htmlBodyContent and present the Gateway3DSecureViewController
            if let html = response[at: "gatewayResponse.3DSecure.authenticationRedirect.simple.htmlBodyContent"] as? String {
                self.begin3DSAuth(simple: html)
            }
        case "CARD_DOES_NOT_SUPPORT_3DS":
            // for cards that do not support 3DSecure, go straight to payment confirmation without a 3DSecureID
            self.transaction.threeDSecureId = nil
            self.stepCompleted(stepStatusImageView: self.check3dsStatusImageView)
            self.prepareForProcessPayment()
        case "CARD_NOT_ENROLLED", "AUTHENTICATION_NOT_AVAILABLE":
            // for cards that are not enrolled or if authentication is not available, go to payment confirmation but include the 3DSecureID
            self.stepCompleted(stepStatusImageView: self.check3dsStatusImageView)
            self.prepareForProcessPayment()
        default:
            self.stepErrored(message: "Error checking 3DS Enrollment", stepStatusImageView: self.check3dsStatusImageView)
        }
    }
    
    func check3DSEnrollmentv47Handler(_ result: Result<GatewayMap>) {
        guard case .success(let response) = result, let recommendaition = response[at: "gatewayResponse.response.gatewayRecommendation"] as? String else {
            self.stepErrored(message: "Error checking 3DS Enrollment", stepStatusImageView: self.check3dsStatusImageView)
            return
        }
        
        // if DO_NOT_PROCEED returned in recommendation, should stop transaction
        if recommendaition == "DO_NOT_PROCEED" {
            self.stepErrored(message: "3DS Do Not Proceed", stepStatusImageView: self.check3dsStatusImageView)
        }
        
        // if PROCEED in recommendation, and we have HTML for 3DS, perform 3DS
        if let html = response[at: "gatewayResponse.3DSecure.authenticationRedirect.simple.htmlBodyContent"] as? String {
            self.begin3DSAuth(simple: html)
        } else {
            // if PROCEED in recommendation, but no HTML, finish the transaction without 3DS
            self.prepareForProcessPayment()
        }
    }
    
    fileprivate func begin3DSAuth(simple: String) {
        // instatniate the Gateway 3DSecureViewController and present it
        let threeDSecureView = Gateway3DSecureViewController(nibName: nil, bundle: nil)
        present(threeDSecureView, animated: true)
        
        // Optionally customize the presentation
        threeDSecureView.title = "3-D Secure Auth"
        threeDSecureView.navBar.tintColor = brandColor
        
        // Start 3D Secure authentication by providing the view with the HTML content provided by the check enrollment step
        threeDSecureView.authenticatePayer(htmlBodyContent: simple, handler: handle3DS(authView:result:))
    }
    
    func handle3DS(authView: Gateway3DSecureViewController, result: Gateway3DSecureResult) {
        // dismiss the 3DSecureViewController
        authView.dismiss(animated: true, completion: {
            switch result {
            case .error(_):
                self.stepErrored(message: "3DS Authentication Failed", stepStatusImageView: self.check3dsStatusImageView)
            case .completed(gatewayResult: let response):
                // check for version 46 and earlier api authentication failures and then version 47+ failures
                if Int(self.transaction.session!.apiVersion)! <= 46, let status = response[at: "3DSecure.summaryStatus"] as? String , status == "AUTHENTICATION_FAILED" {
                    self.stepErrored(message: "3DS Authentication Failed", stepStatusImageView: self.check3dsStatusImageView)
                } else if let status = response[at: "response.gatewayRecommendation"] as? String, status == "DO_NOT_PROCEED"  {
                    self.stepErrored(message: "3DS Authentication Failed", stepStatusImageView: self.check3dsStatusImageView)
                } else {
                    // if authentication succeeded, continue to proceess the payment
                    self.stepCompleted(stepStatusImageView: self.check3dsStatusImageView)
                    self.prepareForProcessPayment()
                }
            default:
                self.stepErrored(message: "3DS Authentication Cancelled", stepStatusImageView: self.check3dsStatusImageView)
            }
        })
    }
    
    func prepareForProcessPayment() {
        statusTitleLabel?.text = "Confirm Payment Details"
        if transaction.isApplePay {
            statusDescriptionLabel?.text = "Apple Pay\n\(transaction.amountFormatted)"
        } else {
            statusDescriptionLabel?.text = "\(transaction.maskedCardNumber!)\n\(transaction.amountFormatted)"
        }
        setAction(action: processPayment, title: "Confirm and Pay")
    }
}

// MARK: - 5. Process Payment
extension ProcessPaymentViewController {
    /// Processes the payment by completing the session with the gateway.
    func processPayment() {
        // update the UI
        processPaymentActivityIndicator.startAnimating()
        continueButton.isEnabled = false
        continueButton.backgroundColor = .lightGray
        
        merchantAPI.completeSession(transaction: transaction) { (result) in
            DispatchQueue.main.async {
                self.processPaymentHandler(result: result)
            }
        }
    }
    
    func processPaymentHandler(result: Result<GatewayMap>) {
        processPaymentActivityIndicator.stopAnimating()
        guard case .success(let response) = result, "SUCCESS" == response[at: "gatewayResponse.result"] as? String else {
                stepErrored(message: "Unable to complete Pay Operation", stepStatusImageView: processPaymentStatusImageView)
                return
        }
        
        stepCompleted(stepStatusImageView: processPaymentStatusImageView)
        
        paymentStatusView?.isHidden = false
        paymentStatusIconView?.image = #imageLiteral(resourceName: "check")
        statusTitleLabel?.text = "Payment Successful!"
        statusDescriptionLabel?.text = nil
        
        setAction(action: finish, title: "Done")
    }
}

// MARK: - Helpers
extension ProcessPaymentViewController {
    fileprivate func stepErrored(message: String, detail: String? = nil, stepStatusImageView: UIImageView) {
        stepStatusImageView.image = #imageLiteral(resourceName: "error")
        stepStatusImageView.isHidden = false
        
        paymentStatusView?.isHidden = false
        paymentStatusIconView?.image = #imageLiteral(resourceName: "error")
        statusTitleLabel?.text = message
        statusDescriptionLabel?.text = detail
        
        setAction(action: self.finish, title: "Done")
    }
    
    fileprivate func stepCompleted(stepStatusImageView: UIImageView) {
        stepStatusImageView.image = #imageLiteral(resourceName: "check")
        stepStatusImageView.isHidden = false
    }
    
    fileprivate func setAction(action: @escaping (() -> Void), title: String) {
        continueButton.setTitle(title, for: .normal)
        currentAction = action
        continueButton.isEnabled = true
        continueButton.backgroundColor = brandColor
    }
    
    fileprivate func randomID() -> String {
        return String(UUID().uuidString.split(separator: "-").first!)
    }
}
