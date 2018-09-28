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
import PassKit

class CollectCardInfoViewViewController: UIViewController {

    @IBOutlet weak var fieldStack: UIStackView?
    
    @IBOutlet weak var nameField: UITextField?
    @IBOutlet weak var numberField: UITextField?
    @IBOutlet weak var expiryMMField: UITextField?
    @IBOutlet weak var expiryYYField: UITextField?
    @IBOutlet weak var cvvField: UITextField?
    @IBOutlet weak var continueButton: UIButton?
    @IBOutlet weak var orView: UIView?
    
    var applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
    
    var viewModel = CollectCardInfoViewModel() {
        didSet {
            renderViewModel()
        }
    }
    
    var completion: ((Transaction) -> Void)?
    var cancelled: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldStack?.addArrangedSubview(applePayButton)
        view.addConstraint(applePayButton.heightAnchor.constraint(equalTo: continueButton!.heightAnchor, multiplier: 1.0))
        
        renderViewModel()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAvoidingKeyboard()
        applePayButton.addTarget(self, action: #selector(applePayAction), for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAvoidingKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renderViewModel() {
        nameField?.text = viewModel.transaction?.nameOnCard
        nameField?.textColor = viewModel.nameValid ? UIColor.darkText : UIColor.red
        
        numberField?.text = viewModel.transaction?.cardNumber
        numberField?.textColor = viewModel.cardNumberValid ? UIColor.darkText : UIColor.red
        
        expiryMMField?.text = viewModel.transaction?.expiryMM
        expiryMMField?.textColor = viewModel.expirationMonthValid ? UIColor.darkText : UIColor.red
        
        expiryYYField?.text = viewModel.transaction?.expiryYY
        expiryYYField?.textColor = viewModel.expirationYearValid ? UIColor.darkText : UIColor.red
        
        cvvField?.text = viewModel.transaction?.cvv
        cvvField?.textColor = viewModel.cvvValid ? UIColor.darkText : UIColor.red
        
        continueButton?.isEnabled = viewModel.isValid
        
        if viewModel.applePayCapable && PKPaymentAuthorizationViewController.canMakePayments() {
            orView?.isHidden = false
            applePayButton.isHidden = false
        } else {
            orView?.isHidden = true
            applePayButton.isHidden = true
        }
    }
    
    @IBAction func updateViewModel() {
        var updated = viewModel
        updated.transaction?.nameOnCard   = nameField?.text
        updated.transaction?.cardNumber = numberField?.text
        updated.transaction?.expiryMM = expiryMMField?.text
        updated.transaction?.expiryYY = expiryYYField?.text
        updated.transaction?.cvv = cvvField?.text
        viewModel = updated
    }
    
    @objc func applePayAction() {
        guard let request = viewModel.transaction?.pkPaymentRequest, let apvc = PKPaymentAuthorizationViewController(paymentRequest: request) else { return }
        apvc.delegate = self
        self.present(apvc, animated: true, completion: nil)
    }
    
    @IBAction func continueAction(sender: Any) {
        self.dismiss(animated: true, completion: nil)
        completion?(viewModel.transaction!)
    }
    
    @IBAction func cancel(sender: Any) {
        self.dismiss(animated: true, completion: nil)
        cancelled?()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

extension CollectCardInfoViewViewController: PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        viewModel.transaction?.applePayPayment = payment
        self.completion?(viewModel.transaction!)
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
}
