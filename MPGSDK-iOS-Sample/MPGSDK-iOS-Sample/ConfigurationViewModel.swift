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

import Foundation
import MPGSDK

struct ConfigurationViewModel {
    // MARK: - Inputs
    var merchantId: String?
    var region: GatewayRegion = .mtf
    var merchantServiceURLString: String?
    var applePayMerchantID: String?
    
    // MARK: - Computed Outputs
    var allRegions: [GatewayRegion] { return GatewayRegion.all }
    
    var merchantServiceURL: URL? {
        get {
            guard let urlString = merchantServiceURLString else { return nil }
            return URL(string: urlString)
        }
        set {
            merchantServiceURLString = newValue?.absoluteString
        }
    }
    
    var validMerchantId: Bool {
        guard let id = merchantId else { return false }
        return !id.isEmpty
    }
    
    var validMerchantServiceURL: Bool {
        return merchantServiceURL != nil
    }
    
    var isValid: Bool {
        return validMerchantId && validMerchantServiceURL
    }
    
    // MARK: - Loading and Saving
    func save(toUserDefaults defaults: UserDefaults = .standard) {
        defaults.set(merchantId, forKey: "merchantId")
        defaults.set(region.rawValue, forKey: "region")
        defaults.set(merchantServiceURL, forKey: "merchantServiceURL")
        defaults.set(applePayMerchantID, forKey: "applePayMerchantID")
    }
    
    mutating func load(fromUserDefaults defaults: UserDefaults = .standard) {
        merchantId = defaults.string(forKey: "merchantId")
        if let regionString = defaults.string(forKey: "region"), let new = GatewayRegion(rawValue: regionString) {
            region = new
        } else {
            region = .mtf
        }
        merchantServiceURL = defaults.url(forKey: "merchantServiceURL")
        applePayMerchantID = defaults.string(forKey: "applePayMerchantID")
    }
}

// MARK: - Helpers
extension GatewayRegion {
    static let all: [GatewayRegion] = [.mtf, .northAmerica, .europe, .asiaPacific]
    
    var name: String {
        switch self {
        case .mtf:
            return "Test (MTF)"
        case .northAmerica:
            return "North America"
        case .europe:
            return "Europe"
        case .asiaPacific:
            return "Asia Pacific"
        }
    }
}
