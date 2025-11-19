# Gateway iOS SDK
**This Mobile SDK supports 3-D Secure and Browser Payment.** If you require EMV 3DS support, please obtain the version 2 Mobile SDK by following these instructions: https://na.gateway.mastercard.com/api/documentation/integrationGuidelines/mobileSDK/emv3DSsdk.html

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/Mastercard-Gateway/gateway-ios-sdk.svg?branch=master)](https://travis-ci.org/Mastercard-Gateway/gateway-ios-sdk)

Our iOS SDK allows you to easily integrate payments into your Swift iOS app. By updating a session directly with the Gateway, you avoid the risk of handling sensitive card details on your server. Also, you can securly load the 3DS and Browser Payment page via SDK. The included [sample app](#sample-app) demonstrates the basics of installing and configuring the SDK to complete a simple payment.

For more information, visit the [**Gateway iOS SDK Wiki**](https://github.com/Mastercard/gateway-ios-sdk/wiki) to find details about the basic transaction lifecycle and 3-D Secure support.


## Scope

The primary responsibility of this SDK is to eliminate the need for card details to pass thru your merchant service while collecting card information from a mobile device. The Gateway provides this ability by exposing an API call to update a session with card information. This is an "unathenticated" call in the sense that you are not required to provide your private API credentials. It is important to retain your private API password in a secure location and NOT distribute it within your mobile app.

Once you have updated a session with card information from the app, you may then perform a variety of operations using this session from your secure server. Some of these operations include creating an authorization or payment, creating a card token to save card information for a customer, etc. Refer to your gateway integration guide for more details on how a Session can be used in your application.


## Compatibility

The Gateway SDK requires a minimum of **iOS 13+** and is compatible with **Swift 5** projects. Therefore, the GatewaySDK requires **Xcode 10.2** or newer.


## Installation

### Recommended: Swift Package Manager (SPM)

The SDK is **best integrated via Swift Package Manager**. Manual integration or Carthage is available but not recommended.

#### Steps:

1. Open your Xcode project.
2. Go to `File → Add Package Dependencies...`.
3. Enter the repository URL: https://github.com/Mastercard-Gateway/gateway-ios-sdk.git
4. From `Add to Project -> Select Desired Project`.
5. Add the `MPGSDK` library and Import like described below
6. Build and run your app

Notes:
1. Only the binary XCFramework is included. Sample apps, docs, and scripts are not part of the package.
2. If you are upgrading from an older manual SDK version, remove any references to MPGSDK.framework in your project and replace them with the SPM package.
3. The SDK supports iOS 13+ and Swift 5.

## Usage

### Import the SDK
Import the Gateway SDK into your project

```swift
import MPGSDK
```


### Configuration
In order to use the SDK, you must initialize the Gateway object with your merchant ID and your gateway's region. If you are unsure about which region to select, please direct your inquiry to your gateway support team.

> Possible region values include, `GatewayRegion.northAmerica`, `GatewayRegion.asiaPacific`, `GatewayRegion.india`, `GatewayRegion.china` and `GatewayRegion.europe`
> For a complete list of regions see the `GatewayRegion.swift`.
```
let gateway = Gateway(region: GatewayRegion.<#YOUR GATEWAY REGION#>, merchantId: "<#YOUR MERCHANT ID#>")
```


### Basic Implementation
Using an existing Session Id, you may pass card information directly to the `Gateway` object in case of Card Payment and Apple Pay flow, browser payment flow do not required update session:

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


### WebView Integration
Render the HTML necessary to facilitate the challenge flow for card payments and to securely authenticate browserd payments:

## A. Card Payment 3DSecure Authentication
```swift
let threeDSecureView = Gateway3DSecureViewController(nibName: nil, bundle: nil)
present(threeDSecureView, animated: true)
threeDSecureView.authenticatePayer(htmlBodyContent: htmlString, handler: handle3DS(authView:result:))
    
func handle3DS(authView: BaseGatewayPaymentController, result: GatewayPaymentResult) {
    // dismiss the 3DSecureViewController
    authView.dismiss(animated: true) {
        switch result {
        case .error(let error):
            // Handle error event
        case .completed(gatewayResult: let response):
            // Handle completion to manage response
        case .cancelled:
            // Handle cancel event
        }
    }
}
```

## B. Browser Payment
```swift
let browserPayView = GatewayBrowserPaymentController(nibName: nil, bundle: nil)
present(browserPayView, animated: true)
browserPayView.authenticatePayer(htmlBodyContent: htmlString, handler: handleBrowserPayment(authView:result:))
    
func handleBrowserPayment(authView: BaseGatewayPaymentController, result: GatewayPaymentResult) {
    // dismiss the GatewayBrowserPaymentController
    authView.dismiss(animated: true) {
        switch result {
        case .completed(gatewayResult: let response):
            // Handle completion to manage response
        case .cancelled:
            // Handle cancel event
        case .error(let error):
            // Handle error event
        }
    }
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
