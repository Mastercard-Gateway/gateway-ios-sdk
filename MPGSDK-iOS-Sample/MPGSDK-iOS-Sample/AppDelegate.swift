import UIKit
import MPGSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // setup the merchant API with the url for your sample merchant server.  Information on the sample merchant server can be found at https://github.com/Mastercard/gateway-test-merchant-server
        MerchantAPI.shared = MerchantAPI(url: URL(string: "<#YOUR MERCHANT SERVER URL#>")!)
        
        return true
    }

}

