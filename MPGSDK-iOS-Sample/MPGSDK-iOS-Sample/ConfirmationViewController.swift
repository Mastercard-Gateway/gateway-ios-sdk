import UIKit

class ConfirmationViewController: UIViewController {

    var sessionId: String?
    var maskedPan: String? {
        didSet {
            syncPan()
        }
    }
    
    @IBOutlet weak var cardNumberField: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncPan()
    }
    
    func syncPan() {
        cardNumberField?.text = maskedPan
    }
}
