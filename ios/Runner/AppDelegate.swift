import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard let mapsKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPIKey") as? String,
          !mapsKey.isEmpty, !mapsKey.hasPrefix("$(") else {
      fatalError("Missing Google Maps configuration. Run ruby ios/maps_config.rb.")
    }
    GMSServices.provideAPIKey(mapsKey)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
