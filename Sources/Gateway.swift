import Foundation

public class Gateway {
    public var region: Region
    public var apiVersion: Int
    public var merchantId: String
    
    init(region: Region, merchantId: String, apiVersion: Int = BuildConfig.defaultAPIVersion) {
        self.region = region
        self.apiVersion = apiVersion
        self.merchantId = merchantId
    }
}
