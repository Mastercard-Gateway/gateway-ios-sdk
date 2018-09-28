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

import Foundation
import PassKit

struct CollectCardInfoViewModel {
    var transaction: Transaction?
    
    var nameValid: Bool {
        return validate(transaction?.nameOnCard, min: 1, max: 256)
    }
    
    var cardNumberValid: Bool {
        return validate(transaction?.cardNumber, min: 1, max: 19)
    }
    
    var expirationMonthValid: Bool {
        return validate(transaction?.expiryMM, min: 2, max: 2)
    }
    
    var expirationYearValid: Bool {
        return validate(transaction?.expiryYY, min: 2, max: 2)
    }
    
    var cvvValid: Bool {
        return validate(transaction?.cvv, min: 3, max: 4)
    }
    
    var isValid: Bool {
        return (nameValid && cardNumberValid && expirationYearValid && expirationMonthValid && expirationYearValid && cvvValid) || transaction?.applePayPayment != nil
    }
    
    var applePayCapable: Bool {
        return transaction?.applePayMerchantIdentifier != nil && !transaction!.applePayMerchantIdentifier!.isEmpty
    }

    fileprivate func validate(_ value: String?, min: Int = 1, max: Int? = nil) -> Bool {
        guard let value = value, value.count >= min else { return false }
        if let max = max, value.count > max {
            return false
        } else {
            return true
        }
    }
}
