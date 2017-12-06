# Gateway SDK [![Build Status](https://travis-ci.org/Mastercard/gateway-ios-sdk.svg?branch=master)](https://travis-ci.org/Mastercard/gateway-ios-sdk)
Our iOS SDK allows you to easily integrate payments into your Swift iOS app. By updating a checkout session directly with the Gateway, you avoid the risk of handling sensitive card details on your server. The included [sample app](#sample-app) demonstrates the basics of installing and configuring the SDK to complete a simple transaction.

## Basic Transaction Flow Diagram

![Transaction Flow](./transaction-flow.png "Transaction Flow")

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
Initialize the SDK with your Gateway API URL and merchant ID.

```
let gateway = try Gateway(url: "<#YOUR GATEWAY URL#>", merchantId: "<#YOUR MERCHANT ID#>")
```

The SDK strictly enforces [certificate pinning] for added security. If you have a custom base URL (ie. **NOT** a *mastercard.com* domain), you will also need to provide a valid X.509 certificate for your domain. We recommend using the intermediate certificate since it typically has a longer life-span than server certificates. Read more about how to obtain this certificate in the **Certificate Pinning** section below.

You can provide the certificate as a valid PEM-format certificate string:
```swift
let customCertString = """
    -----BEGIN CERTIFICATE-----
    MIIFAzCCA+ugAwIBAgIEUdNg7jANBgkq
    ...
    UgiUX6C
    -----END CERTIFICATE-----

    """
try gateway.addTrustedCertificate(customCertString, alias: "mycustomCert")
```
Or read in a valid X.509 certificate file as Data from a file in your app:
```swift
// Load the certificate from our app bundle
let certFileURL = try Bundle.main.url(forResource: "myGatewayCert", withExtension: "cer")!
let customCertData = try Data(contentsOf: certFileURL)
// Provide the certificate data to the gateway
try gateway.addTrustedCertificate(customCertData, alias: "mycustomCert")
```

### Step 3 - Updating a Session with Card Information
Call the gateway to update the session with a payment card.

> The session should be a session id that was obtained by using your merchant services to contact the gateway.

If the session was successfully updated with a payment, send this session id to your merchant services for processing with the gateway.

```swift
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


```swift
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

## Certificate Pinning

[Certificate pinning] is a security measure used to prevent man-in-the-middle attacks by reducing the number of trusted certificate authorities from the default list to only those you provide. If your gateway instance is not a *mastercard.com* URL, then you will need to provide a valid X.509 certificate for that domain. We recommend using the 'intermediate' certificate, as it typically has a much longer life-span than the 'leaf' certificate issued for your domain.

One easy method of retrieving this certificate is to download it through your browser.
1. In the **Chrome** browser, navigate to your gateway integration guide. (ie. https://your-gateway-domain.com/api/documentation)
1. Right-click on the page and click *Inspect* in the menu
1. Select the *Security* tab in the inspector and click *View certificate*
1. In the popup window, click on the intermediate certificate (most likely the middle certificate in the chain)
1. In the info window below, drag the large certificate icon onto your desktop, downloading the *.cer* file to your machine
1. Rename this file to something simple, like *gateway_cert.cer*, and copy it into your project's *raw* (or *assets*) directory

With the certificate now stored in your app, you can add it as a parameter to the Gateway SDK as an InputStream.

If you prefer to store the certificate as a String constant rather than a resource file, you can convert the certificate to PEM format using the following command:
```
openssl x509 -inform der -in gateway_cert.cer -out gateway_cert.pem
```
Open this PEM file in a text editor and copy the entire contents to a static variable in your project. You can reference this variable when adding an additional trusted certificate to the SDK.

## Sample App
Included with the sdk is a sample app named MPGSDK-iOS-Sample that demonstrates how to take a payment using the sdk.  This sample app requires a running instance of our **[Gateway Test Merchant Server]**. Follow the instructions for that project and copy the resulting URL of the instance you create.

Making a payment with the Gateway SDK is a three step process.
1. The mobile app uses a merchant server to securely create a session on the gateway.
2. The app prompts the user to enter their payment details and the gateway SDK is used to update the session with the payment card.
3. The merchant server securely completes the payment.

In the sample app, these three steps can are performed using the Gateway Test Merchant Server and gateway sdk in the ProductViewController, PaymentViewController and ConfirmationViewController.

### Initialize the Sample App

To configure the sample app, open the AppDelegate.swift file. There are three fields which must be completed in order for the sample app to run a test transaction.

```swift
// TEST Gateway Merchant ID
let gatewayMerchantId = "<#your-merchant-id#>"

// Gateway Base URL
let gatewayBaseUrl = "<#https://your-gateway-url-com#>"

// TEST Merchant Server URL (test server app deployed to Heroku)
// For more information, see: https://github.com/Mastercard/gateway-test-merchant-server
// ex: https://{your-app-name}.herokuapp.com
let merchantServerUrl = "<#YOUR MERCHANT SERVER URL#>"
```

For more information, visit [https://test-gateway.mastercard.com/api/documentation/integrationGuidelines/index.html](https://test-gateway.mastercard.com/api/documentation/integrationGuidelines/index.html)

[Gateway Test Merchant Server]: https://github.com/Mastercard/gateway-test-merchant-server
[certificate pinning]: https://en.wikipedia.org/wiki/HTTP_Public_Key_Pinning
