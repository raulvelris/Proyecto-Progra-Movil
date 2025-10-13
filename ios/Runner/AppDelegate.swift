import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] ?? "TU_NUEVA_API_KEY_AQUI"
    
    if apiKey != "TU_NUEVA_API_KEY_AQUI" {
        GMSServices.provideAPIKey(apiKey)
        print("Google Maps API Key configurada desde variable de entorno")
    } else {
        print("ADVERTENCIA: Google Maps API Key no configurada")
        print("La funcionalidad de mapas no estará disponible")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}