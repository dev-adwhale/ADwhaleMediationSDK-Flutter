import AdWhaleSDK
import adwhale_sdk_flutter
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Dart `AdWhaleNativeCustomView(factoryId: 'app_custom')` 와 동일한 id로 등록
    AdWhaleSdkFlutterPlugin.registerNativeAdViewFactory(
      "app_custom",
      factory: AdWhaleBlockNativeAdViewFactory { frame in
        ExampleCustomNativeAdView(frame: frame)
      }
    )
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
