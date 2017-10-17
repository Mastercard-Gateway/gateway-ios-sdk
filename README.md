# Gateway SDK
This is a Swift SDK for taking payments with the Gateway.

## Compatibility

The gateway SDK requires **iOS 8+** and is compatible with **Swift 4** projects. Therefore you must use **Xcode 9** when using the Gateway SDK.

## Installation [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

We recommend using [Carthage]( https://github.com/Carthage/Carthage) to integrate the Gateway SDK into your project.

```
github "<#github project name#>#"
```

If you do not want to use carthage, you can download the sdk manually and add the MPGSDK as a sub project manually.

## Usage
### Step 1 - Import the SDK
Import the Gateway SDK into your project

```
import MPGSDK
```
### Step 2 - Configure the SDK
Initialize the SDK with your Gateway API URL and merchant ID.

```
let gateway = try Gateway(url: "<#YOUR GATEWAY URL#>", merchantId: "<#YOUR MERCHANT ID#>")
```

The SDK strictly enforces certificate pinning for added security. If you have a custom base URL (ie. NOT a mastercard.com domain), you will also need to provide the PEM-encoded SSL public certificate for that domain. We recommend using the intermediate certificate since it typically has a longer life-span than server certificates.
```
let customCert = Data(base64Encoded: "MIIFAzCCA+ugAwIBAgIEUdNg7jANBgkq...")!
gateway.addTrustedCertificate(customCert, "mycustomCert")
```

### Step 3 - Updating a Session with Card Information
Call the gateway to update the session with a payment card.

> The session should be a session id that was obtained by using your merchant services to contact the gateway.

If the session was successfully updated with a payment, send this session id to your merchant services for processing with the gateway.

```
gateway.updateSession("<#session id#>",  nameOnCard: "<#name on card#>", cardNumber: "<#card number#>",
            securityCode: "<#security code#>", expiryMM: "<#expiration month#>", expiryYY: "<#expiration year#>") { (result) in
    switch result {
    case .success(let response):
        print(response.sessionId)
    case .error(let error):
        print(error)
    }
}
```

You can also construct a Card object and pass that as argument to the SDK.


```
let card = Card(nameOnCard: "<#name on card#>",
                cardNumber: "<#card number#>",
                securityCode: "<#security code#>",
                expiry: Expiry(month: "<#expiration month#>", year: "<#expiration year#>")
                )

gateway.updateSession("<#session id#>",  card: card) { (result) in
    switch result {
    case .success(let response):
        print(response.sessionId)
    case .error(let error):
        print(error)
    }
}
```

## Sample App
Included with the sdk is a sample app named MPGSDK-iOS-Sample that demonstrates how to take a payment using the sdk.  This sample app requires a running instance of our **[Gateway Test Merchant Server](https://github.com/Mastercard/gateway-test-merchant-server)**. Follow the instructions for that project and copy the resulting URL of the instance you create.

Making a payment with the Gateway SDK is a three step process.
1. The mobile app uses a merchant server to securely create a session on the gateway.
2. The app prompts the user to enter their payment details and the gateway SDK is used to update the session with the payment card.
3. The merchant server securely completes the payment.

In the sample app, these three steps can are performed using the Gateway Test Merchant Server and gateway sdk in the ProductViewController, PaymentViewController and ConfirmationViewController.

To try out the sample app, simply fill in the URL for your sample merchant server url in the AppDelegate and your gateway url and merchant id in the PaymentViewController.

For more information, visit [https://test-gateway.mastercard.com/api/documentation/integrationGuidelines/index.html](https://test-gateway.mastercard.com/api/documentation/integrationGuidelines/index.html)
