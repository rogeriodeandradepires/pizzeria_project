import UIKit
import Flutter
import FBSDKCoreKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate{
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      
        let handled: Bool = ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
      // Add any custom logic here.
      return handled
  }
    
  
    
}
