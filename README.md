# Gateway SDK
This is a Swift SDK for taking payments with the Gateway.

## Compatibility

Disk requires **iOS 8+** and is compatible with **Swift 4** projects. Therefore you must use **Xcode 9** when using the Gateway SDK.

## Installation

We recommend using [Carthage]( https://github.com/Carthage/Carthage) to integrate the Gateway SDK into your project.

```
github "<#github project name#>#"
```

If you do not want to use carthage, you can download the sdk manually and add the MPGSDK as a sub project manually.

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
_ = gateway.updateSession("<#session id#>",  nameOnCard: "<#name on card#>", cardNumber: "<#card number#>",
            securityCode: "<#security code#>", expiryMM: "<#expiration month#>", expiryYY: "<#expiration year#>") { (result) in
    switch result {
    case .success(let response):
        print(response.sessionId)
    case .error(let error):
        print(error)
    }
}
```
## Sample App
Included with the sdk is a sample app named MPGSDK-iOS-Sample that demonstrates how to take a payment using the sdk.  The sample app is designed to work in with the sample merchant server available at [https://github.com/Mastercard/gateway-test-merchant-server](https://github.com/Mastercard/gateway-test-merchant-server).
Making a payment with the Gateway SDK is a three step process.
1. The mobile app uses a merchant server to securely create a session on the gateway.
2. The app prompts the user to enter their payment details and the gateway SDK is used to update the session with the payment card.
3. The merchant server securely completes the payment.

In the sample app, these three steps can are performed using the sample merchant server and gateway sdk in the ProductViewController, PaymentViewController and ConfirmationViewController.

To try out the sample app, simply fill in the URL for your sample merchant server url in the AppDelegate and your gateway url and merchant id in the PaymentViewController.

For more information, visit [https://test-gateway.mastercard.com/api/documentation/integrationGuidelines/index.html](https://test-gateway.mastercard.com/api/documentation/integrationGuidelines/index.html)
