import Flutter
import UIKit
import WeScan

public class SwiftEdgeDetectionPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {
  
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    
    let channel = FlutterMethodChannel(name: "edge_detection", binaryMessenger: registrar.messenger())
    let instance = SwiftEdgeDetectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    if let viewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
        let destinationViewController = HomeViewController()
        destinationViewController._result = result
        viewController.present(destinationViewController,animated: true,completion: nil);
    }
  }
}
