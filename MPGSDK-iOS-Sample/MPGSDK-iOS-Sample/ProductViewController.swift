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

class ProductViewController: UIViewController {

    var loadingViewController: LoadingViewController!
    
    var sessionId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingViewController = storyboard!.instantiateViewController(withIdentifier: "loading") as! LoadingViewController
        loadingViewController.localizedTitle = "Please Wait"
        loadingViewController.localizedDescription = "creating checkout session"
        
    }
    
    @IBAction func restartCheckout(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func checkoutAction(_ sender: Any) {
        present(loadingViewController, animated: true) {
            MerchantAPI.shared?.createSession(completion: self.sessionReceived(_:))
        }
    }
    
    fileprivate func sessionReceived(_ result: Result<CreateSessionResponse>) {
        DispatchQueue.main.async {
            self.loadingViewController.dismiss(animated: true) {
                switch result {
                case .success(let response):
                    if case .success = response.result {
                        self.sessionId = response.session.id
                        self.performSegue(withIdentifier: "collectCardDetails", sender: nil)
                    } else {
                        self.showError()
                    }
                case .error(_):
                    self.showError()
                }
            }
        }
    }
    
    fileprivate func showError() {
        let alert = UIAlertController(title: "Error", message: "Unable to create session.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PaymentViewController {
            destination.sessionId = sessionId
        }
    }
    
}

