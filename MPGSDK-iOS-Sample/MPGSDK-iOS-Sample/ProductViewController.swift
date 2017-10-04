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

