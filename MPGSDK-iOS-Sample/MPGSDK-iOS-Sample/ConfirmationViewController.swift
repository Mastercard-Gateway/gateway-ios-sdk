import UIKit

class ConfirmationViewController: UIViewController {

    var sessionId: String?
    var maskedPan: String? {
        didSet {
            syncPan()
        }
    }
    
    var loadingViewController: LoadingViewController!
    @IBOutlet weak var cardNumberField: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingViewController = storyboard!.instantiateViewController(withIdentifier: "loading") as! LoadingViewController
        loadingViewController.localizedTitle = "Please Wait"
        loadingViewController.localizedDescription = "completing checkout session"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncPan()
    }
    
    fileprivate func syncPan() {
        cardNumberField?.text = maskedPan
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        present(loadingViewController, animated: true) {
            MerchantAPI.shared?.completeSession(self.sessionId!, orderId: self.randomID(), transactionId: self.randomID(), amount: "250.00", currency: "USD", completion: self.sessionCompleted(_:))
        }
    }
    
    fileprivate func sessionCompleted(_ result: Result<CompleteSessionResponse>) {
        DispatchQueue.main.async {
            self.loadingViewController.dismiss(animated: true) {
                switch result {
                case .success(let response):
                    if case .success = response.result {
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
        let alert = UIAlertController(title: "Error", message: "Unable to complete session.  Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PaymentViewController {
            destination.sessionId = sessionId
        }
    }
    
    fileprivate func randomID() -> String {
        return String(UUID().uuidString.split(separator: "-").first!)
    }
}
