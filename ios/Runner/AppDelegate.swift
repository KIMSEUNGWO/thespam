import Flutter
import UIKit
import CallKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
    // 메서드 채널 설정
    configureMethodChannels()
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    // Method Channel 설정
  private func configureMethodChannels() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    
    let callKitChannel = FlutterMethodChannel(
      name: "com.malgeum/callkit",
      binaryMessenger: controller.binaryMessenger
    )
    
    callKitChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "saveBlockingNumbers":
        if let numbers = call.arguments as? [String] {
          SharedData.shared.saveBlockingNumbers(numbers)
          self.reloadCallDirectoryExtension()
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid numbers array", details: nil))
        }
        
      case "saveIdentificationData":
        if let data = call.arguments as? [[String: String]] {
          SharedData.shared.saveIdentificationData(data)
          self.reloadCallDirectoryExtension()
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid identification data", details: nil))
        }
        
      case "addBlockingNumbers":
        if let numbers = call.arguments as? [String] {
          SharedData.shared.addBlockingNumbers(numbers)
          self.reloadCallDirectoryExtension(incremental: true)
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid numbers array", details: nil))
        }
        
      case "removeBlockingNumbers":
        if let numbers = call.arguments as? [String] {
          SharedData.shared.removeBlockingNumbers(numbers)
          self.reloadCallDirectoryExtension(incremental: true)
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid numbers array", details: nil))
        }
        
      case "addIdentificationData":
        if let data = call.arguments as? [[String: String]] {
          SharedData.shared.addIdentificationData(data)
          self.reloadCallDirectoryExtension(incremental: true)
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid identification data", details: nil))
        }
        
      case "removeIdentificationNumbers":
        if let numbers = call.arguments as? [String] {
          SharedData.shared.removeIdentificationNumbers(numbers)
          self.reloadCallDirectoryExtension(incremental: true)
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid numbers array", details: nil))
        }
      case "checkExtensionEnabled":
        checkCallDirectoryExtensionEnabled { (isEnabled, error) in
          if let error = error {
            result(FlutterError(code: "CHECK_FAILED", message: error.localizedDescription, details: nil))
          } else {
            result(isEnabled)
          }
      }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  // CallDirectoryExtension 새로고침
    // 로딩 중인지 추적하는 변수 추가
    private var isReloadingExtension = false

    private func reloadCallDirectoryExtension(incremental: Bool = false) {
        // 이미 로딩 중이면 무시
        if isReloadingExtension {
            NSLog("Extension reload already in progress, ignoring request")
            return
        }
        
        isReloadingExtension = true
        
        let bundleID = Bundle.main.bundleIdentifier ?? "com.malgeum.yourapp"
        let extensionID = bundleID + ".CallDirectoryExtension"
        
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: extensionID) { [weak self] error in
            // 로딩 완료 표시
            self?.isReloadingExtension = false
            
            if let error = error {
                NSLog("Error reloading extension: \(error)")
            } else {
                NSLog("Call directory extension reloaded successfully")
            }
        }
    }
    private func checkCallDirectoryExtensionEnabled(completion: @escaping (Bool, Error?) -> Void) {
      let bundleID = Bundle.main.bundleIdentifier ?? "com.malgeum"
      let extensionID = bundleID + ".CallDirectoryExtension"
        
      CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: extensionID) { (status, error) in
        if let error = error {
          completion(false, error)
          return
        }
          
        let isEnabled = (status == .enabled)
        completion(isEnabled, nil)
      }
    }
}
