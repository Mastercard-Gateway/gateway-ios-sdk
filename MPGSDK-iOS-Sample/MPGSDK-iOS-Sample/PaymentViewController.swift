import UIKit

class PaymentViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var expirationField: UITextField!
    @IBOutlet weak var cvvField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            numberField.becomeFirstResponder()
        case numberField:
            expirationField.becomeFirstResponder()
        case expirationField:
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
        
    }
}
