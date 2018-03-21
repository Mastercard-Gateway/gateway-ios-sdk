# Gateway SDK [![Build Status](https://travis-ci.org/Mastercard/gateway-ios-sdk.svg?branch=master)](https://travis-ci.org/Mastercard/gateway-ios-sdk)

**\*\*DISCLAIMER: This SDK is currently in pilot phase. Pending a `1.X.X` release, the interface is subject to change. Please direct all support inquiries to your acquirer**

Our iOS SDK allows you to easily integrate payments into your Swift iOS app. By updating a hosted session directly with the Gateway, you avoid the risk of handling sensitive card details on your server. The included [sample app](#sample-app) demonstrates the basics of installing and configuring the SDK to complete a simple payment.

For more information, visit the [**Gateway iOS SDK Wiki**](https://github.com/Mastercard/gateway-ios-sdk/wiki) to find details about the basic transaction lifecycle and 3-D Secure support.

## Compatibility

The gateway SDK requires **iOS 8+** and is compatible with **Swift 4** projects. Therefore you must use **Xcode 9** when using the Gateway SDK.

## Installation [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

We recommend using [Carthage]( https://github.com/Carthage/Carthage) to integrate the Gateway SDK into your project.

```
github "Mastercard/gateway-ios-sdk"
```

If you do not want to use carthage, you can download the sdk manually and add the MPGSDK as a sub project manually.

## Usage
### Import the SDK
Import the Gateway SDK into your project

```swift
import MPGSDK
```
### Configuration
Initialize the SDK with your Gateway region and merchant ID.

> Possible region values include, `GatewayRegion.northAmerica`, `GatewayRegion.asiaPacific` and `GatewayRegion.europe`
```
let gateway = Gateway(region: GatewayRegion.<#YOUR GATEWAY REGION#>, merchantId: "<#YOUR MERCHANT ID#>")
```

### Basic Implementation
Using an existing Session Id, you may pass card information directly to the `Gateway` object:

```swift
var request = GatewayMap()
request[at: "sourceOfFunds.provided.card.nameOnCard"] = "<#name on card#>"
request[at: "sourceOfFunds.provided.card.number"] = "<#card number#>"
request[at: "sourceOfFunds.provided.card.securityCode"] = "<#security code#>"
request[at: "sourceOfFunds.provided.card.expiry.month"] = "<#expiration month#>"
request[at: "sourceOfFunds.provided.card.expiry.year"] = "<#expiration year#>"

gateway.updateSession("<#session id#>", apiVersion: <#Gateway API Version#>, payload: request) { (result) in
    // handle the result
}
```

## Sample App
Included with the sdk is a sample app named MPGSDK-iOS-Sample that demonstrates how to take a payment using the sdk.  This sample app requires a running instance of our **[Gateway Test Merchant Server]**. Follow the instructions for that project and copy the resulting URL of the instance you create.

### Configuration

To configure the sample app, open the `AppDelegate.swift` file. There are three fields which must be completed in order for the sample app to run a test payment.

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
