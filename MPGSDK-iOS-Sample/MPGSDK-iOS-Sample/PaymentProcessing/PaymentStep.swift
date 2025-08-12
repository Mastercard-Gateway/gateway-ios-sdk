/*
 Copyright (c) 2017 Mastercard
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

enum PaymentStep {
    case createSession
    case paymentOptionsInquiry
    case selectPaymentOption
    case collectCard
    case updateSession
    case initiateAuthentication
    case authenticate3DSecurePayment
    case initiateBrowserPayment
    case authenticateBrowserPayment
    case processPayment
    
    var title: String {
        switch self {
        case .createSession:
            return "Create Session"
        case .paymentOptionsInquiry:
            return "Payment Option Inquiry"
        case .selectPaymentOption:
            return "Select Payment Option"
        case .collectCard:
            return "Collect Card"
        case .initiateBrowserPayment:
            return "Initiate Browser Payment"
        case .updateSession:
            return "Update Session with Payer Data"
        case .authenticate3DSecurePayment:
            return "Authenticate 3D Secure Payment"
        case .initiateAuthentication:
            return "Initiate Authentication"
        case .authenticateBrowserPayment:
            return "Authenticate Browser Payment"
        case .processPayment:
            return "Process Payment"
        }
    }
}
