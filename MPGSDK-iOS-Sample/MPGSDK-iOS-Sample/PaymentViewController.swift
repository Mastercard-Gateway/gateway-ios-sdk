import UIKit
import MPGSDK

class PaymentViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var expiryMMField: UITextField!
    @IBOutlet weak var expiryYYField: UITextField!
    @IBOutlet weak var cvvField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    var loadingViewController: LoadingViewController!
    
    var sessionId: String?
    
    var gateway: Gateway!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingViewController = storyboard!.instantiateViewController(withIdentifier: "loading") as! LoadingViewController
        loadingViewController.localizedTitle = "Please Wait"
        loadingViewController.localizedDescription = "updating session with payment information"
        
        gateway = try! Gateway(url: "<#YOUR GATEWAY URL#>", merchantId: "<#YOUR MERCHANT ID#>")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        startAvoidingKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAvoidingKeyboard()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            numberField.becomeFirstResponder()
        case numberField:
            expiryMMField.becomeFirstResponder()
        case expiryMMField:
            expiryYYField.becomeFirstResponder()
        case expiryYYField:
            cvvField.becomeFirstResponder()
        case cvvField:
            cvvField.resignFirstResponder()
            continueAction(textField)
        default:
            return false
        }
        return true
    }
    
    @IBAction func continueAction(_ sender: Any) {
        present(loadingViewController, animated: true) {
            self.updateSession()
        }
    }
    
    func updateSession() {
        _ = gateway.updateSession(sessionId!, nameOnCard: nameField.text!, cardNumber: numberField.text!, securityCode: cvvField.text!, expiryMM: expiryMMField.text!, expiryYY: expiryYYField.text!, completion: updateSessionHandler(_:))
    }
    
    fileprivate func updateSessionHandler(_ result: GatewayResult<UpdateSessionRequest.responseType>) {
        DispatchQueue.main.async {
            self.loadingViewController.dismiss(animated: true) {
                switch result {
                case .success(let response):
                    self.performSegue(withIdentifier: "showConfirmation", sender: nil)
                case .error(_):
                    self.showError()
                }
            }
        }
    }
    
    fileprivate func showError() {
        let alert = UIAlertController(title: "Error", message: "Unable to update session.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConfirmationViewController {
            destination.sessionId = sessionId
            destination.maskedPan = maskPan()
        }
    }
    
    fileprivate func maskPan() -> String? {
        guard let number = numberField.text else { return nil }
        let visibleLength = number.count > 8 ? 4 : 0
        let maskLength = number.count - visibleLength
        return String(repeating: "•", count: maskLength) + number.suffix(visibleLength)
    }
    
    
}
