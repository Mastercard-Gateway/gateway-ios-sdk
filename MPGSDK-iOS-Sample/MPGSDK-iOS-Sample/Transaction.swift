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

// a structure bundling the session id and the api version on which that session was created.
struct GatewaySession {
    var id: String
    var apiVersion: String
}

struct Transaction {
    // The Payment Session from the gateway
    var session: GatewaySession?
    
    // basic transaction properties
    var amount: NSDecimalNumber = 1.0
    var amountString = "1.00"
    var amountFormatted = "$1.00"
    var currency = "USD"
    var summary = "Some transaction"
    
    // card information
    var nameOnCard: String?
    var cardNumber: String?
    var expiryMM: String?
    var expiryYY: String?
    var cvv: String?
    
    // Apple Pay Information
    var applePayMerchantIdentifier: String?
    var countryCode = "US"
    var supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .discover, .amex]
    var applePayPayment: PKPayment?
    
    var isApplePay: Bool {
        return applePayPayment != nil
    }
    
    var orderId: String = Transaction.randomID()
    var id: String = Transaction.randomID()
    
    // a masked card number for the confirmation text
    var maskedCardNumber: String? {
        guard let number = cardNumber else { return nil }
        let last4 = number.suffix(4)
        let dotCount = number.dropLast(last4.count).count
        return String(repeating: "•", count: dotCount) + last4
    }
    
    // a 3DSecure ID used to identify the transaction durring the 3DS steps with the gateway
    var threeDSecureId: String? = Transaction.randomID()
    
    var pkPaymentRequest: PKPaymentRequest? {
        guard let merchantId = applePayMerchantIdentifier else { return nil }
        let request = PKPaymentRequest()
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: summary, amount: amount, type: .final)]
        request.merchantIdentifier = merchantId
        request.countryCode = countryCode
        request.currencyCode = currency
        request.supportedNetworks = supportedNetworks
        request.merchantCapabilities = [.capabilityCredit, .capabilityDebit, .capability3DS]
        return request
    }
    
    static func randomID() -> String {
        return String(UUID().uuidString.split(separator: "-").first!)
    }
}
