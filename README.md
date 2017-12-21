# Gateway SDK [![Build Status](https://travis-ci.org/Mastercard/gateway-ios-sdk.svg?branch=master)](https://travis-ci.org/Mastercard/gateway-ios-sdk)
Our iOS SDK allows you to easily integrate payments into your Swift iOS app. By updating a hosted session directly with the Gateway, you avoid the risk of handling sensitive card details on your server. The included [sample app](#sample-app) demonstrates the basics of installing and configuring the SDK to complete a simple payment.

**\*\*DISCLAIMER: This SDK is currently in pilot phase. Pending a `1.X.X` release, the interface is subject to change. Please direct all support inquiries to `gateway_support@mastercard.com`**

## Basic Payment Flow Diagram

![Payment Flow](./payment-flow.png "Payment Flow")

## Compatibility

The gateway SDK requires **iOS 8+** and is compatible with **Swift 4** projects. Therefore you must use **Xcode 9** when using the Gateway SDK.

## Installation [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

We recommend using [Carthage]( https://github.com/Carthage/Carthage) to integrate the Gateway SDK into your project.

```
github "Mastercard/gateway-ios-sdk"
```

If you do not want to use carthage, you can download the sdk manually and add the MPGSDK as a sub project manually.

## Usage
### Step 1 - Import the SDK
Import the Gateway SDK into your project

```swift
import MPGSDK
```
### Step 2 - Configure the SDK
Initialize the SDK with your Gateway region and merchant ID.

```
let gateway = Gateway(region: "<#YOUR REGION#>", merchantId: "<#YOUR MERCHANT ID#>")
```

### Step 3 - Updating a Session with Card Information
Call the gateway to update the session with a payment card.

> The session should be a session id that was obtained by using your merchant services to contact the gateway.

If the session was successfully updated with a payment, send this session id to your merchant services for processing with the gateway.

```swift
gateway.updateSession("<#session id#>", apiVersion: <#api version#>,  nameOnCard: "<#name on card#>", cardNumber: "<#card number#>",
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


```swift
let card = Card(nameOnCard: "<#name on card#>",
                cardNumber: "<#card number#>",
                securityCode: "<#security code#>",
                expiry: Expiry(month: "<#expiration month#>", year: "<#expiration year#>")
                )

gateway.updateSession("<#session id#>", apiVersion: <#api version#>,  card: card) { (result) in
    switch result {
    case .success(let response):
        print(response.sessionId)
    case .error(let error):
        print(error)
    }
}
```

You may also include additional information such as shipping/billing addresses, customer info, and device data by manually building the `UpdateSessionRequest` object and providing that to the SDK.

```swift
var request = UpdateSessionRequest(sessionId: "<#session id#>", apiVersion: <#api version#>)
let card = Card(...)
request.sourceOfFunds = SourceOfFunds(provided: Provided(card: card))
request.customer = Customer(...)
request.shipping = Shipping(...)
request.billing = Billing(...)
request.device = Device(...)
gateway.execute(request: request) { (result) in
    ...
}
```

## Sample App
Included with the sdk is a sample app named MPGSDK-iOS-Sample that demonstrates how to take a payment using the sdk.  This sample app requires a running instance of our **[Gateway Test Merchant Server]**. Follow the instructions for that project and copy the resulting URL of the instance you create.

Making a payment with the Gateway SDK is a three step process.
1. The mobile app uses a merchant server to securely create a session on the gateway.
2. The app prompts the user to enter their payment details and the gateway SDK is used to update the session with the payment card.
3. The merchant server securely completes the payment.

In the sample app, these three steps can are performed using the Gateway Test Merchant Server and gateway sdk in the ProductViewController, PaymentViewController and ConfirmationViewController.

### Initialize the Sample App

To configure the sample app, open the AppDelegate.swift file. There are three fields which must be completed in order for the sample app to run a test payment.

```swift
// TEST Gateway Merchant ID
let gatewayMerchantId = "<#your-merchant-id#>"

// Gateway Region
let gatewayRegion = GatewayRegion."<#YOUR GATEWAY REGION#>"

// TEST Merchant Server URL (test server app deployed to Heroku)
// For more information, see: https://github.com/Mastercard/gateway-test-merchant-server
// ex: https://{your-app-name}.herokuapp.com
let merchantServerUrl = "<#YOUR MERCHANT SERVER URL#>"
```


[Gateway Test Merchant Server]: https://github.com/Mastercard/gateway-test-merchant-server
[certificate pinning]: https://en.wikipedia.org/wiki/HTTP_Public_Key_Pinning
