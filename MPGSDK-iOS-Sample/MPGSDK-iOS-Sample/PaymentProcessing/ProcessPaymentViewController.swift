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

public enum PaymentType {
    case cardPayment
    case browserPayment(String)
}

class ProcessPaymentViewController: UIViewController {
    // MARK: - Properties
    var transaction: Transaction = Transaction()

    // the object used to communicate with the merchant's api
    var merchantAPI: MerchantAPI!
    // the ojbect used to communicate with the gateway
    var gateway: Gateway!
    
    // MARK: View Outlets
    @IBOutlet weak var stepsStackView: UIStackView!
    
    @IBOutlet weak var paymentStatusView: UIView?
    @IBOutlet weak var paymentStatusIconView: UIImageView?
    @IBOutlet weak var statusTitleLabel: UILabel?
    @IBOutlet weak var statusDescriptionLabel: UILabel?
    
    @IBOutlet weak var continueButton: UIButton!
    
    private var stepCount: Int = 1
    
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
        stepsStackView.subviews.forEach { $0.removeFromSuperview()}
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
        continueButton.isEnabled = false
        continueButton.backgroundColor = .lightGray
        addStepViews(step: .createSession)
        merchantAPI.createSession { (result) in
            DispatchQueue.main.async {
                var errorMessage: String = "Fail Creating Session"
                switch result {
                case .success(let response):
                    let apiVersion = "100"
                    let responseDictionary = response.dictionary
                    if "SUCCESS" == responseDictionary["result"] as? String,
                       let session = responseDictionary["session"] as? [String: Any] ,
                       let sessionId = session["id"] as? String {
                        self.transaction.session = GatewaySession(id: sessionId, apiVersion: apiVersion)
                        self.updateLastStep(state: .completed)
                        self.sendPaymentOptionInquiry()
                        return
                    }
                case .error(let error):
                    errorMessage = error.localizedDescription
                    break
                }
                // error handling
                self.stepErrored(message: errorMessage)
            }
        }
    }
}

// MARK: - 2. Payment Option Inquiry
extension ProcessPaymentViewController {
    func sendPaymentOptionInquiry() {
        addStepViews(step: .paymentOptionsEnquiry)
        merchantAPI.sendPaymentOptionInquiry{ [weak self] (result) in
            DispatchQueue.main.async {
                // stop the activity indictor
                guard case .success(let response) = result,
                      "SUCCESS" == response[at: "result"] as? String,
                      let paymentTypes = response[at:"paymentTypes"]  as? [String: Any]
                else {
                    self?.stepErrored(message: "Payment Option Inquiry Failed")
                    return
                }
                var paytmentOptions: [PaymentOption] = []
                for (key, value) in paymentTypes {
                    switch key {
                    case "browserPayment":
                        let options = value as? [[String: Any]] ?? []
                        for option in options {
                            let type = option["type"] as? String
                            let currencyList = option["currencies"] as? [[String:String]]
                            let currency = currencyList?.first?["currency"]
                            let displayName: String? = option["displayName"] as? String
                            
                            let paymentOption = PaymentOption(isBrowserPayment: true,
                                                              type: type,
                                                              currency: currency,
                                                              displayName: displayName)
                            paytmentOptions.append(paymentOption)
                        }
                    case "card":
                        let cardPaymentInfo = value as? [String: Any] ?? [:]
                        let currencyList = cardPaymentInfo["currencies"] as? [[String:String]]
                        let currency = currencyList?.first?["currency"]
                        let paymentOption = PaymentOption(currency: currency)
                        paytmentOptions.append(paymentOption)
                    default:
                        break
                    }
                }
                
                print("\nPayment Options: \(paytmentOptions)")
                self?.updateLastStep(state: .completed)
                self?.showPaymentOptions(paytmentOptions)
            }
        }
    }
    
    fileprivate func showPaymentOptions(_ options: [PaymentOption]) {
        //Show action sheet
        guard !options.isEmpty
        else {
            collectCardInfo()
            return
        }
        
        // Avoid additional step to select payment type if it has only one option
//        if options.count == 1 {
//            didPaymentOptionSelected(options[0])
//            return
//        }
        
        addStepViews(step: .selectPaymentOption)
        let actionSheet = UIAlertController(title: "Payment Option",
                          message: "Select a option to process payment",
                          preferredStyle: .actionSheet)
        
        for option in options {
            let action = UIAlertAction(title: option.type, style: .default) { _ in
                self.updateLastStep(state: .completed)
                self.didPaymentOptionSelected(option)
            }
            actionSheet.addAction(action)
        }
        
        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func didPaymentOptionSelected(_ option: PaymentOption) {
        let isBrowserPayment = option.isBrowserPayment
        let type = option.type
        transaction.paymentType = isBrowserPayment ? .browserPayment(type) : .cardPayment
        transaction.browserPaymentType = type
        transaction.currency = option.currency
        isBrowserPayment ? initiateBrowserPayment() : collectCardInfo()
    }
}

// MARK: - 3A. Initiate Browser Payment API
extension ProcessPaymentViewController {
    func initiateBrowserPayment() {
        self.addStepViews(step: .initiateBrowserPayment)
        merchantAPI.initiateBrowserPayment(transaction: self.transaction) { (result) in
            DispatchQueue.main.async {
                guard case .success(let response) = result,
                      "SUCCESS" == response[at: "result"] as? String,
                      let redirectURL = response[at:"browserPayment.redirectHtml"] as? String
                else {
                    self.stepErrored(message: "Initiate Browser Payment Failed")
                    return
                }
                self.updateLastStep(state: .completed)
                self.executeGatewayPayment(htmlString: redirectURL)
            }
        }
    }
}

// MARK: 3A. 1. Browser Payment Authentication
extension ProcessPaymentViewController {
    fileprivate func presentBrowserPayment(htmlString: String) {
        addStepViews(step: .authenticateBrowserPayment)
        guard let paymentURL = getBrowserPaymentURL(from: htmlString)
        else {
            stepErrored(message: "Invalid Browser Payment URL")
            return
        }
        
        // instatniate the Gateway Browser Payment and present it
        let browserPayView = GatewayBrowserPaymentController(nibName: nil, bundle: nil)
        browserPayView.modalPresentationStyle = .fullScreen
        present(browserPayView, animated: true)
        
        // Optionally customize the presentation
        browserPayView.title = "Browser Payment Authentication"
        browserPayView.navBar.tintColor = brandColor
        
        // Start Browser Payment authentication by providing payment URL
        browserPayView.authenticatePayer(url: paymentURL, handler: handleBrowserPayment(authView:result:))
    }
    
    fileprivate func handleBrowserPayment(authView: BaseGatewayPaymentController, result: GatewayPaymentResult) {
        // dismiss the GatewayBrowserPaymentController
        authView.dismiss(animated: true) {
            switch result {
            case .completed(gatewayResult: let response):
                self.updateLastStep(state: .completed)
                guard let resultStatus = response[at:"result"] as? String,
                      let gatewayResponse = response[at: "response"] as? [String: Any],
                      let gatewayCode = gatewayResponse["gatewayCode"] as? String
                else {
                    self.stepErrored(message: "Authenticate Browser Payment API Failed: Invalid Response")
                    return
                }
                
                if resultStatus == "SUCCESS" {
                    self.updatePaymentSuccess(status: "Browser Payment \(gatewayCode)")
                    return
                }
                
                self.stepErrored(message: "Browser Payment Authentication \(gatewayCode)")
                
            case .cancelled:
                self.stepErrored(message: "Browser Payment Authentication Cancelled")
                
            case .error(let error):
                self.stepErrored(message: "Browser Payment Authentication Failed with error: \n\(error.localizedDescription)")
            }
        }
    }
    
    fileprivate func getBrowserPaymentURL(from htmlString: String) -> URL? {
        var paymentURL: URL?
        let pattern = "<script.*?>([\\s\\S]*?)<\\/script>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        else { return paymentURL }
        let range = NSRange(htmlString.startIndex..<htmlString.endIndex, in: htmlString)
        if let match = regex.firstMatch(in: htmlString, options: [], range: range),
           let scriptRange = Range(match.range(at: 1), in: htmlString) {
            let scriptContent = String(htmlString[scriptRange])
            
            let scriptComponents = scriptContent.components(separatedBy: "'")
            let redirectURL = scriptComponents.first(where: { $0.hasPrefix("https") }) ?? ""
            paymentURL = URL(string: redirectURL)
        }
        return paymentURL
    }
}

// MARK: - 3B. Collect Card Info
extension ProcessPaymentViewController {
    // Presents the card collection UI and waits for a response
    func collectCardInfo() {
        // update the UI
        performSegue(withIdentifier: "collectCardInfo", sender: nil)
    }
    
    func cardInfoCollected(transaction: Transaction) {
        addStepViews(step: .collectCard, withState: .completed)
        self.transaction = transaction
        
        // start the action to update the session with payer data
        self.updateWithPayerData()
    }
    
    func cardInfoCancelled() {
        self.stepErrored(message: "Card Information Not Entered")
    }
}

// MARK: 3B. 1. Update Session With Payer Data
extension ProcessPaymentViewController {
    // Updates the gateway session with payer data using the gateway.updateSession function
    func updateWithPayerData() {
        // update the UI
        addStepViews(step: .updateSession)
    
        guard let sessionId = transaction.session?.id, let apiVersion = transaction.session?.apiVersion else { return }
        
        // construct the Gateway Map with the desired parameters. (nested GatewayMap not dot notation)
        //Build card expiry map
        var expiryMap = GatewayMap()
        expiryMap["month"] = transaction.expiryMM
        expiryMap["year"] = transaction.expiryYY

        //Build card map
        var cardMap = GatewayMap()
        cardMap["nameOnCard"] = transaction.nameOnCard
        cardMap["number"] = transaction.cardNumber
        cardMap["securityCode"] = transaction.cvv
        cardMap["expiry"] = expiryMap
        
        
        // if the transaction has an Apple Pay Token, populate that into the map
        if let tokenData = transaction.applePayPayment?.token.paymentData, let token = String(data: tokenData, encoding: .utf8) {
            var devicePaymentMap = GatewayMap()
            devicePaymentMap["paymentToken"] = token
            cardMap["devicePayment"] = devicePaymentMap
        }
        
        // Build provided map
        var providedMap = GatewayMap()
        providedMap["card"] = cardMap

        // Build sourceOfFunds map
        var sourceOfFundsMap = GatewayMap()
        sourceOfFundsMap["provided"] = providedMap

        // Final request map
        var request = GatewayMap()
        request["sourceOfFunds"] = sourceOfFundsMap
        
        // execute the update
        gateway.updateSession(sessionId, apiVersion: apiVersion, payload: request, completion: updateSessionHandler(_:))
    }
    
    // Call the gateway to update the session.
    fileprivate func updateSessionHandler(_ result: GatewayResult<GatewayMap>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let response):
                if let result = response[at:"result"] as? String, result.lowercased() == "error" {
                    self.stepErrored(message: "Updating Session Failed: \(self.errorMessage(for: response))")
                } else {
                    self.updateLastStep(state: .completed)
                    self.initiateAuthentication()
                }
            case .error(let error):
                self.stepErrored(message: "Updating Session Failed with error: \n\(error.localizedDescription)")
                return
            }
        }
    }
}

// MARK: 3B. 2. Initiate Authentication
extension ProcessPaymentViewController {
    // uses the gateway (throught the merchant service) to check the card to see if it is enrolled in 3D Secure
    func initiateAuthentication(){
        // update the UI
        continueButton.isEnabled = false
        continueButton.backgroundColor = .lightGray
        addStepViews(step: .initiateAuthentication)
        
        merchantAPI.initiateAuthentication(transaction: transaction, payload: GatewayMap()) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let result = response[at:"result"] as? String, result.lowercased() == "error" {
                        self.stepErrored(message: "Authenticating Payer Failed: \(self.errorMessage(for: response))")
                    } else {
                        self.updateLastStep(state: .completed)
                        self.didCompleteAuthentication(with: response)
                    }
                case .error(let error):
                    self.stepErrored(message: "Authenticating Payer Failed with error: \n\(error.localizedDescription)")
                }
            }
        }
    }
    
    fileprivate func didCompleteAuthentication(with response: GatewayMap) {
        guard let html = response[at: "authentication.redirect.html"] as? String
        else {
            stepErrored(message: "Authenticating Payer Failed: No HTML String found")
            return
        }
        executeGatewayPayment(htmlString: html)
    }
    
    fileprivate func executeGatewayPayment(htmlString: String) {
        switch transaction.paymentType {
        case .browserPayment(let type):
            presentBrowserPayment(htmlString: htmlString)
        case .cardPayment:
            present3DSAuth(htmlString: htmlString)
        }
    }
}

// MARK: 3B. 3. 3DS Security Check
extension ProcessPaymentViewController {
    fileprivate func present3DSAuth(htmlString: String) {
        // instatniate the Gateway 3DSecureViewController and present it
        addStepViews(step: .authenticate3DSecurePayment)
        let threeDSecureView = Gateway3DSecureViewController(nibName: nil, bundle: nil)
        threeDSecureView.modalPresentationStyle = .fullScreen
        present(threeDSecureView, animated: true)
        
        // Optionally customize the presentation
        threeDSecureView.title = "3DS Payment Authentication"
        threeDSecureView.navBar.tintColor = brandColor
        
        // Start 3D Secure authentication by providing the view with the HTML content provided by the check enrollment step
        threeDSecureView.authenticatePayer(htmlBodyContent: htmlString, handler: handle3DS(authView:result:))
    }
    
    func handle3DS(authView: BaseGatewayPaymentController, result: GatewayPaymentResult) {
        // dismiss the 3DSecureViewController
        authView.dismiss(animated: true) {
            switch result {
            case .error(let error):
                self.stepErrored(message: "3DS Authentication Failed with error: \n\(error.localizedDescription)")
            case .completed(gatewayResult: let response):
                // check for version 46 and earlier api authentication failures and then version 47+ failures
                if Int(self.transaction.session!.apiVersion)! <= 46, let status = response[at: "3DSecure.summaryStatus"] as? String , status == "AUTHENTICATION_FAILED" {
                    self.stepErrored(message: "3DS Authentication Failed")
                } else if let status = response[at: "response.gatewayRecommendation"] as? String, status == "DO_NOT_PROCEED"  {
                    self.stepErrored(message: "3DS Authentication Failed")
                } else if let resultStatus = response[at: "result"] as? String {
                    // Read PHP server payment status via redirect URL
                    if resultStatus.lowercased() == "success" {
                        self.updateLastStep(state: .completed)
                        self.prepareForProcessPayment()
                    } else {
                        let authenticationStatus = (response[at: "transaction.authenticationStatus"] as? String)?.replacingOccurrences(of: "_", with: " ") ?? "Authentication Failed"
                        self.stepErrored(message: "3DS \(authenticationStatus)")
                    }
                } else {
                    // if authentication succeeded, continue to proceess the payment
                    self.updateLastStep(state: .completed)
                    self.prepareForProcessPayment()
                }
            default:
                self.stepErrored(message: "3DS Authentication Cancelled")
            }
        }
    }
}

// MARK: 3B. 4. Process Payment
extension ProcessPaymentViewController {
    
    func prepareForProcessPayment() {
        statusTitleLabel?.text = "Confirm Payment Details"
        if transaction.isApplePay {
            statusDescriptionLabel?.text = "Apple Pay\n\(transaction.amountFormatted)"
        } else {
            statusDescriptionLabel?.text = "\(transaction.maskedCardNumber!)\n\(transaction.amountFormatted)"
        }
        setAction(action: processPayment, title: "Confirm and Pay")
    }
    
    /// Processes the payment by completing the session with the gateway.
    func processPayment() {
        // update the UI
        addStepViews(step: .processPayment)
        continueButton.isEnabled = false
        continueButton.backgroundColor = .lightGray
        merchantAPI.completeSession(transaction: transaction) { (result) in
            DispatchQueue.main.async {
                self.processPaymentHandler(result: result)
            }
        }
    }
    
    func processPaymentHandler(result: Result<GatewayMap>) {
        guard case .success(let response) = result, "SUCCESS" == response[at: "gatewayResponse.result"] as? String else {
                stepErrored(message: "Unable to complete Pay Operation")
                return
        }
        updateLastStep(state: .completed)
        updatePaymentSuccess()
    }
    
    fileprivate func updatePaymentSuccess( status: String = "Payment Successful!") {
        paymentStatusIconView?.image = #imageLiteral(resourceName: "check")
        statusTitleLabel?.text = status
        statusDescriptionLabel?.text = nil
        paymentStatusView?.isHidden = false
        
        setAction(action: finish, title: "Done")
    }
}

// MARK: - Helpers
extension ProcessPaymentViewController {
    
    fileprivate  func addStepViews(step:PaymentStep, withState state: ProcessingStepViewModel.State = .loading) {
        var model = ProcessingStepViewModel(sequence: stepCount, stepName: step.title)
        model.state = state
        stepsStackView.addArrangedSubview(ProcessingStepView(with: model))
        stepCount += 1
    }
    
    fileprivate func updateLastStep(state: ProcessingStepViewModel.State) {
        if let lastView = stepsStackView.subviews.last as? ProcessingStepView {
            lastView.updateState(state: state)
        }
    }
    
    fileprivate func stepErrored(message: String, detail: String? = nil) {
        updateLastStep(state: .failed)
        paymentStatusView?.isHidden = false
        paymentStatusIconView?.image = #imageLiteral(resourceName: "error")
        statusTitleLabel?.text = message
        statusDescriptionLabel?.text = detail
        
        setAction(action: self.finish, title: "Done")
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
    
    fileprivate func errorMessage(for response:GatewayMap) -> String {
        let errorCauses = response[at: "error.causes"] as? String
        let errorExplanation = response[at: "error.explanation"] as? String
        let message = [errorCauses, errorExplanation].compactMap({$0}).joined(separator: " ")
        return message.isEmpty ? "Unknown Error" : message
    }
}
