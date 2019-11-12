# Gateway iOS SDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/Mastercard-Gateway/gateway-ios-sdk.svg?branch=master)](https://travis-ci.org/Mastercard-Gateway/gateway-ios-sdk)

Our iOS SDK allows you to easily integrate payments into your Swift iOS app. By updating a hosted session directly with the Gateway, you avoid the risk of handling sensitive card details on your server. The included [sample app](#sample-app) demonstrates the basics of installing and configuring the SDK to complete a simple payment.

For more information, visit the [**Gateway iOS SDK Wiki**](https://github.com/Mastercard/gateway-ios-sdk/wiki) to find details about the basic transaction lifecycle and 3-D Secure support.


## Scope

The primary responsibility of this SDK is to eliminate the need for card details to pass thru your merchant service while collecting card information from a mobile device. The Gateway provides this ability by exposing an API call to update a session with card information. This is an "unathenticated" call in the sense that you are not required to provide your private API credentials. It is important to retain your private API password in a secure location and NOT distribute it within your mobile app.

Once you have updated a session with card information from the app, you may then perform a variety of operations using this session from your secure server. Some of these operations include creating an authorization or payment, creating a card token to save card information for a customer, etc. Refer to your gateway integration guide for more details on how a Session can be used in your application.


## Compatibility

The Gateway SDK requires a minimum of **iOS 8+** and is compatible with **Swift 5** projects. Therefore, the GatewaySDK requires **Xcode 10.2** or newer.


## Installation

We recommend using [Carthage]( https://github.com/Carthage/Carthage) to integrate the Gateway SDK into your project.

```
github "Mastercard-Gateway/gateway-ios-sdk"
```

If you do not want to use carthage, you can download the sdk manually and add the MPGSDK as a sub project manually.


## Usage

### Import the SDK
Import the Gateway SDK into your project

```swift
import MPGSDK
```


### Configuration
In order to use the SDK, you must initialize the Gateway object with your merchant ID and your gateway's region. If you are unsure about which region to select, please direct your inquiry to your gateway support team.

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


---

## Sample App
Included with the sdk is a sample app named MPGSDK-iOS-Sample that demonstrates how to take a payment using the sdk.  This sample app requires a running instance of our **[Gateway Test Merchant Server]**. Follow the instructions for that project and copy the resulting URL of the instance you create.
When you launch the sample app, you will be prompted to enter your merchant Id, gateway region, and test merchant server url and Apple Pay Merchant Id if applicable.
### Apple Pay
To conduct an Apple Pay transaction using the sample app, you must first complete the steps for [Configuring Apple Pay] provided by Apple.  This will setup your Apple Pay Merchant Id and the Payment Processing Certificate.

[Configuring Apple Pay]: https://developer.apple.com/library/archive/ApplePay_Guide/Configuration.html
[Gateway Test Merchant Server]: https://github.com/Mastercard/gateway-test-merchant-server
[certificate pinning]: https://en.wikipedia.org/wiki/HTTP_Public_Key_Pinning
