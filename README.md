# Gateway SDK
This is a Swift SDK for taking payments with the Gateway.

## Compatibility

Disk requires **iOS 8+** and is compatible with **Swift 4** projects. Therefore you must use **Xcode 9** when using the Gateway SDK.

## Installation

* [Carthage]( https://github.com/Carthage/Carthage)

```
github "<#github project name#>#"
```
## Usage
### Step 1
Import the Gateway SDK into your project

```
import MPGSDK
```
### Step 2
Initialize the SDK with your Gateway API URL and merchant ID.

```
let gateway = try Gateway(url: "<#YOUR GATEWAY URL#>", merchantId: "<#YOUR MERCHANT ID#>")
```
### Step 3
Call the gateway to update the session with a payment card.
> The session should be a session id that was obtained by using your merchant services to contact the gateway.
If the session was succesfully updated with a payment, send this session id to your merchant services for processing with the gateway.

```
_ = gateway.updateSession("<#session id#>", nameOnCard: "<#name on card#>", cardNumber: "<#card number#>", securityCode: "<#security code#>", expiryMM: "<#expiration month#>", expiryYY: "<#expiration year#>") { (result) in
    switch result {
    case .success(let response):
        print(response.sessionId)
    case .error(let error):
        print(error)
    }
}
```
