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
    
    @IBOutlet weak var cardNumberField: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        syncMaskedCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncMaskedCard()
    }
    
    @IBAction func checkEnrollment() {
        guard let transaction = transaction else { return }
        present(loadingViewController, animated: true) {
            let dddsid = self.randomID()
            MerchantAPI.shared?.check3DSEnrollment(transaction, _3DSecureId: dddsid, redirectURL: merchantServerUrl.appending("/3DSecureResult.php?3DSecureId=\(dddsid)"), completion: self.enrollmentStatusReceived)
        }
    }
    
    fileprivate func enrollmentStatusReceived(_ result: Result<GatewayMap>) {
        DispatchQueue.main.async {
            self.loadingViewController.dismiss(animated: true) {
                switch result {
                case .success(let response):
                    print(response)
                    if let code = response[at: "gatewayResponse.3DSecure.summaryStatus"] as? String {
                        switch code {
                        case "CARD_ENROLLED":
                            if let html = response[at: "gatewayResponse.3DSecure.authenticationRedirect.simple.htmlBodyContent"] as? String {
                                self.transaction?._3DSecureId = response[at: "gatewayResponse.3DSecureId"] as? String
                                self.begin3DSAuth(simple: html)
                            }
                        case "CARD_NOT_ENROLLED", "CARD_DOES_NOT_SUPPORT_3DS", "AUTHENTICATION_SUCCESSFUL":
                            self.confirmPayment()
                        default:
                            self.showError()
                        }
                    } else {
                        self.showError()
                    }
                case .error(_):
                    self.showError()
                }
            }
        }
    }
    
    fileprivate func begin3DSAuth(simple: String) {
        let webAuthView = WebAuthViewController(nibName: nil, bundle: nil)
        present(webAuthView, animated: true)
        webAuthView.AuthenticatePayer(htmlBodyContent: simple, handler: handle3DS(authView:result:))
    }
    
    func handle3DS(authView: WebAuthViewController, result: WebAuthResult) {
        authView.dismiss(animated: true, completion: {
            switch result {
            case .completed(status: "AUTHENTICATION_FAILED", id: _):
                self.showAuthenticationError()
            case .completed(status: _, id: let id):
                self.transaction?._3DSecureId = id
                self.confirmPayment()
            default:
                self.showAuthenticationError()
            }
        })
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var destination = segue.destination as? TransactionConsumer {
            destination.transaction = transaction
        }
    }
    
    fileprivate func randomID() -> String {
        return String(UUID().uuidString.split(separator: "-").first!)
    }
    
    
    
}
