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

class PayOperationViewController: UIViewController, TransactionConsumer {

    var transaction: Transaction?
    
    lazy var loadingViewController: LoadingViewController = {
        var loadingViewController = storyboard!.instantiateViewController(withIdentifier: "loading") as! LoadingViewController
        loadingViewController.localizedTitle = "Please Wait"
        loadingViewController.localizedDescription = "processing payment for session"
        return loadingViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        payOperation()
    }
    
    func payOperation() {
        guard let transaction = transaction, let sessionId = transaction.sessionId else { return }
        present(loadingViewController, animated: true) {
            
            MerchantAPI.shared?.completeSession(sessionId, orderId: self.randomID(), transactionId: self.randomID(), amount: transaction.amount, currency: transaction.currency, completion: self.sessionCompleted(_:))
        }
    }
    
    fileprivate func sessionCompleted(_ result: Result<GatewayMap>) {
        DispatchQueue.main.async {
            self.loadingViewController.dismiss(animated: true) {
                switch result {
                case .success(let response):
                    print(response)
                    if "SUCCESS" == response[at: "gatewayResponse.result"] as? String {
                        self.performSegue(withIdentifier: "showSuccess", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "showFailure", sender: nil)
                    }
                case .error(_):
                    self.showError()
                }
            }
        }
    }
    
    fileprivate func showError() {
        let alert = UIAlertController(title: "Error", message: "Unable to process payment.  Please try again.", preferredStyle: .alert)
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
