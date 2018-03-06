import Foundation

struct Transaction {
    var sessionId: String?
    var apiVersion: String?
    var maskedCardNumber: String?
    var _3DSecureId: String?
    var amount: String
    var currency: String
    
    init(amount: String, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}

protocol TransactionConsumer {
    var transaction: Transaction? { get set }
}
