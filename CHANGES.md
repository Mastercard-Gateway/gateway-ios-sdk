# Release Notes
## [Unreleased]
## [1.2.0-beta03] - 2025-09-12
### Added
- Integrate the Apple Pay flow into the sample app to demonstrate Apple Pay functionality.

## [Unreleased]
## [1.2.0-beta02] - 2025-08-25
### Added
- Integration and handling of Friction-less Card Scenarios within the payment flow.
- Support for HTML body content param in SDK integration to display payment authentication.
### Changed
- Updated access specifiers and marked Gateway controllers as final to prevent unintended code manipulation.
- Enhanced the base controller to handle HTML body loading and removed child initializer logic (now managed by the base).
- Streamlined the Friction-less card flow by removing redundant browser URL extraction and ensuring smoother handling directly via the SDK.

## [Unreleased]
## [1.2.0-beta01] - 2025-08-12
### Added
- Added sendPaymentOptionInquiry AP
- Added initiateAuthentication API along with device info
- Added initiateBrowserPayment API
- Added a dynamic step rendering capability for better user experience
- Added a Browser Payment capability with Base Payment controller and its error handing
### Changed
- Update SDK min deployment target to 11 to support latest update
- Update transaction model to keep Payment type info
- Update SDK Payment Controller with 3DS and its error handing
- Update Host and resultParam for 3dSecure and browserPayment
- Integrate create session API and handle its response as per sample server
- Integrate Payment Option Inquiry along with option selection capability and updating payment currency support
- Integrate Initiate Browser Payment API and manage to get Browser payment URL from html String
- Integrate Update session API
- Integrate Initiate Authentication API and load HTML div

## [Unreleased]
## [1.1.9] - 2025-03-24
### Changed
- Updated podspec file.

## [1.1.8]
### Changed
- Pinned certificate updated. New Expirey December 2038

## [1.1.7] - 2024-02-12
### Added
- Saudi region (KSA) URL

## [1.1.6]
### Changed
- Pinned certificate updated. New Expirey December 2030

## [1.1.5]
### Added
- Adding the China on-soil region
- Providing a way for integrators to use regions that have not yet been added to the SDK.
### Changed
- Converting all URLs to use the "<region>.gateway.mastercard.com" pattern

## [1.1.4]
### Changed
- Swift.package file version updated to specify swift 5.0
- Syncing Changes.md with releases

## [1.1.3]
### Added
- Added the India regions
### Changed
- Updated Fastlane versions

## [1.1.2]
### Changed
- Updated the project and source code to Swift 5
- Updated podspec file

## [1.1.1]
### Changed
- Updated the update session call to support Gateway API versions 50 and up

## [1.1.0]
### Changed
- Updated the update session call to support Gateway API versions 50 and up

### Added
- Sample app with support for Apple Pay

## [1.0.0]
### ADDED
- Initial Release of the sdk
- Support for updating a session with card information
- 3-D Secure 1.0 support for Gateway API versions 46 and below
