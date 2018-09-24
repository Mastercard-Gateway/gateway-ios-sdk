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

class ConfigurationViewController: UIViewController {

    @IBOutlet weak var merchantIdField: UITextField?
    @IBOutlet weak var regionButton: UIButton?
    @IBOutlet weak var merchantServerUrlField: UITextField?
    @IBOutlet weak var applePayMerchantIdField: UITextField?
    
    @IBOutlet weak var continueButton: UIButton?
    
    var viewModel: ConfigurationViewModel = ConfigurationViewModel() {
        didSet {
            renderViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAvoidingKeyboard()
        viewModel.load()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAvoidingKeyboard()
        viewModel.save()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func syncMerchantIdField(sender: UITextField) {
        viewModel.merchantId = merchantIdField?.text
    }
    
    @IBAction func syncMerchantServiceUrlField(sender: UITextField) {
        viewModel.merchantServiceURLString = merchantServerUrlField?.text
    }
    
    @IBAction func syncApplePayMerchantIdField(sender: UITextField) {
        viewModel.applePayMerchantID = applePayMerchantIdField?.text
    }
    
    func renderViewModel() {
        merchantIdField?.text = viewModel.merchantId
        regionButton?.setTitle(viewModel.region.name, for: .normal)
        merchantServerUrlField?.text = viewModel.merchantServiceURLString
        applePayMerchantIdField?.text = viewModel.applePayMerchantID
        
        continueButton?.isEnabled = viewModel.isValid
    }

    @IBAction func selectRegion(sender: UIView) {
        let alert = UIAlertController(title: "Select a gateway region:", message: nil, preferredStyle: .actionSheet)
        
        alert.modalPresentationStyle = .popover
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        
        viewModel.allRegions.forEach { region in
            let action = UIAlertAction(title: region.name, style: .default, handler: { (_) in
                self.viewModel.region = region
            })
            alert.addAction(action)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let paymentVC = segue.destination as? ProcessPaymentViewController {
            paymentVC.configure(merchantId: viewModel.merchantId!, region: viewModel.region, merchantServiceURL: viewModel.merchantServiceURL!, applePayMerchantIdentifier: viewModel.applePayMerchantID)
        }
    }
    

}
