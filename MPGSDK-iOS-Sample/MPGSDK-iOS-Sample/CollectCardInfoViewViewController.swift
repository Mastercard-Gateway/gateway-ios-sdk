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

class CollectCardInfoViewViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField?
    @IBOutlet weak var numberField: UITextField?
    @IBOutlet weak var expiryMMField: UITextField?
    @IBOutlet weak var expiryYYField: UITextField?
    @IBOutlet weak var cvvField: UITextField?
    @IBOutlet weak var continueButton: UIButton?
    
    var viewModel = CollectCardInfoViewModel() {
        didSet {
            renderViewModel()
        }
    }
    
    var completion: ((String, String, String, String, String) -> Void)?
    var cancelled: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderViewModel()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func renderViewModel() {
        nameField?.text = viewModel.name
        nameField?.textColor = viewModel.nameValid ? UIColor.darkText : UIColor.red
        
        numberField?.text = viewModel.cardNumber
        numberField?.textColor = viewModel.cardNumberValid ? UIColor.darkText : UIColor.red
        
        expiryMMField?.text = viewModel.expirationMonth
        expiryMMField?.textColor = viewModel.expirationMonthValid ? UIColor.darkText : UIColor.red
        
        expiryYYField?.text = viewModel.expirationYear
        expiryYYField?.textColor = viewModel.expirationYearValid ? UIColor.darkText : UIColor.red
        
        cvvField?.text = viewModel.cvv
        cvvField?.textColor = viewModel.cvvValid ? UIColor.darkText : UIColor.red
        
        continueButton?.isEnabled = viewModel.isValid
    }
    
    @IBAction func updateViewModel() {
        var updated = viewModel
        updated.name = nameField?.text
        updated.cardNumber = numberField?.text
        updated.expirationMonth = expiryMMField?.text
        updated.expirationYear = expiryYYField?.text
        updated.cvv = cvvField?.text
        viewModel = updated
    }
    
    @IBAction func continueAction(sender: Any) {
        self.dismiss(animated: true, completion: nil)
        completion?(viewModel.name!, viewModel.cardNumber!, viewModel.expirationMonth!, viewModel.expirationYear!, viewModel.cvv!)
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
