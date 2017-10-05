import PlaygroundSupport // PLAYGROUND ONLY: Imported only for the purpose of demonstrating async tasks in Swift Plagrounds
//: # Integrating the Gateway SDK
//:
//: The following steps will guide you through integerating the Gateway SDK into your project.
//: > For testing purposes, you can fill in the placeholders to update a session with a payment card directly from this playground.
//:
//: ----
//: ## Step 1
//: Import the Gateway SDK into your project
import MPGSDK

//: ----
//: ## Step 2
//: Initialize the SDK with your Gateway API URL and merchant ID.
let gateway = try! Gateway(url: "<#YOUR GATEWAY URL#>", merchantId: "<#YOUR MERCHANT ID#>")
//: ----
//: ## Step 3
//: Call the gateway to update the session with a payment card.
//: > The session should be a session id that was obtained by using your merchant services to contact the gateway.
//:
//: If the session was succesfully updated with a payment, send this session id to your merchant services for processing with the gateway.
_ = gateway.updateSession("<#session id#>", nameOnCard: "<#name on card#>", cardNumber: "<#card number#>", securityCode: "<#security code#>", expiryMM: "<#expiration month#>", expiryYY: "<#expiration year#>") { (result) in
    switch result {
    case .success(let response):
        print(response.sessionId)
    case .error(let error):
        print(error)
    }
    PlaygroundPage.current.finishExecution() // PLAYGROUND DEMONSTRATION ONLY
}
