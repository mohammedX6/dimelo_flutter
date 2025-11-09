import Flutter
import UIKit
import Dimelo

public class DimeloFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var initialized: Bool = false
  private var apiKey: String?
  private var applicationSecret: String?
  private var apiSecret: String?
  private var domain: String?
  private var userId: String?
  private var userName: String?
  private var userEmail: String?
  private var userPhone: String?
  private var authInfo: [String: Any] = [:]
  
  // App bar customization properties
  private var appBarTitle: String = "Dimelo Chat"
  private var appBarColor: UIColor = UIColor.systemBlue
  private var appBarTitleColor: UIColor = UIColor.black
  private var backArrowColor: UIColor = UIColor.black
  private var showBackButton: Bool = true
  private var appBarVisible: Bool = true
  private var fullScreenPresentation: Bool = true
  
  // Reference to the chat view controller for updating title
  private weak var currentChatViewController: UIViewController?
  
  // Event channel for streaming events to Flutter
  private var eventSink: FlutterEventSink?
  
  // Unread count monitoring
  private var lastUnreadCount: Int = 0
  private var unreadCountTimer: Timer?
  private var currentUserId: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dimelo_flutter", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "dimelo_flutter_events", binaryMessenger: registrar.messenger())
    let instance = DimeloFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  // Converts a hexadecimal string (e.g., "<a1b2c3...>" or "a1b2c3...") to Data
  // APNs device tokens are byte sequences typically represented as hex strings.
  private func dataFromHexString(_ hexString: String) -> Data? {
    // Remove spaces and angle brackets often present in token descriptions
    let cleaned = hexString
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "<", with: "")
      .replacingOccurrences(of: ">", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)

    // Must be even-length to map pairs of hex digits to bytes
    guard cleaned.count % 2 == 0 else { return nil }

    var data = Data(capacity: cleaned.count / 2)
    var index = cleaned.startIndex
    while index < cleaned.endIndex {
      let nextIndex = cleaned.index(index, offsetBy: 2)
      let byteString = cleaned[index..<nextIndex]
      if let byte = UInt8(byteString, radix: 16) {
        data.append(byte)
      } else {
        return nil
      }
      index = nextIndex
    }
    return data
  }

  private func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
    .compactMap { ($0 as? UIWindowScene)?.keyWindow }
    .first?.rootViewController) -> UIViewController? {
      if let nav = base as? UINavigationController { return topViewController(base: nav.visibleViewController) }
      if let tab = base as? UITabBarController { return topViewController(base: tab.selectedViewController) }
      if let presented = base?.presentedViewController { return topViewController(base: presented) }
      return base
  }

  @objc func dismissChat() {
    DispatchQueue.main.async { [weak self] in
      // Send onChatActivityClosed event to Flutter
      self?.sendEvent(["event": "onChatActivityClosed", "timestamp": Int64(Date().timeIntervalSince1970 * 1000)])
      
      // Stop monitoring unread count when chat is closed
      self?.stopUnreadCountMonitoring()
      
      // Dismiss the chat view controller
      if let chatVC = self?.currentChatViewController {
        chatVC.dismiss(animated: true, completion: nil)
      } else if let top = self?.topViewController() {
        if top.navigationController != nil {
          top.navigationController?.popViewController(animated: true)
        } else {
          top.dismiss(animated: true, completion: nil)
        }
      }
      // Clear the reference to the chat view controller
      self?.currentChatViewController = nil
    }
  }
  
  // Helper function to create a clean back button without background
  private func createBackButton() -> UIBarButtonItem {
    let backButton = UIBarButtonItem(
      image: UIImage(systemName: "chevron.left"),
      style: .plain,
      target: self,
      action: #selector(self.dismissChat)
    )
    backButton.tintColor = self.backArrowColor
    
    // Remove any background
    if #available(iOS 14.0, *) {
      backButton.backgroundImage(for: .normal, barMetrics: .default)
    }
    
    return backButton
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "initialize":
      if self.initialized {
        result(true)
        return
      }
      let args = call.arguments as? [String: Any]
      self.applicationSecret = args?["applicationSecret"] as? String
      self.apiKey = args?["apiKey"] as? String
      self.apiSecret = args?["apiSecret"] as? String
      self.domain = args?["domain"] as? String
      self.userId = args?["userId"] as? String
      let developmentApns = args?["developmentApns"] as? Bool

      // Initialize Dimelo SDK
      let secretToUse = (self.apiSecret?.isEmpty == false) ? self.apiSecret : self.apiKey
      if let key = secretToUse, let domain = self.domain, !key.isEmpty {
        if let dimelo = Dimelo.sharedInstance() {
          if let dev = developmentApns {
            dimelo.developmentAPNS = dev
          } else {
            #if DEBUG
              dimelo.developmentAPNS = true
            #else
              dimelo.developmentAPNS = false
            #endif
          }
          dimelo.initialize(withApiSecret: key, domainName: domain, delegate: nil)
          if let user = self.userId { dimelo.userIdentifier = user }
          self.initialized = true
        } else {
          self.initialized = false
        }
      } else {
        self.initialized = false
      }
      result(self.initialized)
    case "showMessenger":
      guard self.initialized else { result(false); return }
      DispatchQueue.main.async {
        guard let dimelo = Dimelo.sharedInstance() else { result(false); return }
        if let chatVC = dimelo.chatViewController() {
          // Store reference to the chat view controller
          self.currentChatViewController = chatVC
          
          // Set the title on the chat view controller
          chatVC.title = self.appBarTitle
          chatVC.navigationItem.title = self.appBarTitle
          
          // Add back button to navigation bar
          if self.showBackButton {
            chatVC.navigationItem.leftBarButtonItem = self.createBackButton()
          }
          
          // Set modal presentation style to full screen (not bottom sheet)
          chatVC.modalPresentationStyle = .fullScreen
          
          // Configure navigation bar appearance if available
          if let navController = chatVC.navigationController {
            self.configureNavigationController(navController)
          }
          
          if let top = self.topViewController() {
            // Send onChatActivityOpened event to Flutter
            self.sendEvent(["event": "onChatActivityOpened", "timestamp": Int64(Date().timeIntervalSince1970 * 1000)])
            
            // Start monitoring unread count when chat is opened
            self.startUnreadCountMonitoring()
            
            // Present the chat view controller full screen
            top.present(chatVC, animated: true) {
              // Set the title and back button again after presentation to ensure they stick
              chatVC.title = self.appBarTitle
              chatVC.navigationItem.title = self.appBarTitle
              
              if self.showBackButton && chatVC.navigationItem.leftBarButtonItem == nil {
                chatVC.navigationItem.leftBarButtonItem = self.createBackButton()
              }
              
              // Set title and back button with delays to ensure they persist
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                chatVC.title = self.appBarTitle
                chatVC.navigationItem.title = self.appBarTitle
                if self.showBackButton && chatVC.navigationItem.leftBarButtonItem == nil {
                  chatVC.navigationItem.leftBarButtonItem = self.createBackButton()
                }
              }
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                chatVC.title = self.appBarTitle
                chatVC.navigationItem.title = self.appBarTitle
                if self.showBackButton && chatVC.navigationItem.leftBarButtonItem == nil {
                  chatVC.navigationItem.leftBarButtonItem = self.createBackButton()
                }
              }
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                chatVC.title = self.appBarTitle
                chatVC.navigationItem.title = self.appBarTitle
                if self.showBackButton && chatVC.navigationItem.leftBarButtonItem == nil {
                  chatVC.navigationItem.leftBarButtonItem = self.createBackButton()
                }
              }
              
              result(true)
            }
          } else {
            result(false)
          }
        } else {
          result(false)
        }
      }
    case "setUser":
      let args = call.arguments as? [String: Any]
      self.userId = args?["userId"] as? String
      self.userName = args?["name"] as? String
      self.userEmail = args?["email"] as? String
      self.userPhone = args?["phone"] as? String
      
      // Update current user ID for unread count tracking
      self.currentUserId = self.userId
      
      if let dimelo = Dimelo.sharedInstance() {
        if let id = self.userId { dimelo.userIdentifier = id }
        if let name = self.userName { dimelo.userName = name }
        var auth = dimelo.authenticationInfo ?? [:]
        if let email = self.userEmail { auth["email"] = email }
        if let phone = self.userPhone { auth["phone"] = phone }
        for (k, v) in self.authInfo { auth[k] = v }
        dimelo.authenticationInfo = auth
      }
      result(true)
    case "setAuthInfo":
      if let args = call.arguments as? [String: Any] {
        for (k, v) in args { if let s = v as? String { self.authInfo[k] = s } }
      }
      if let dimelo = Dimelo.sharedInstance() {
        var auth = dimelo.authenticationInfo ?? [:]
        for (k, v) in self.authInfo { auth[k] = v }
        dimelo.authenticationInfo = auth
      }
      result(true)
    case "logout":
      if let dimelo = Dimelo.sharedInstance() {
        dimelo.userIdentifier = nil
        dimelo.userName = nil
        dimelo.authenticationInfo = nil
      }
      self.userId = nil
      self.userName = nil
      self.userEmail = nil
      self.userPhone = nil
      self.currentUserId = nil
      self.authInfo.removeAll()
      // Reset unread count when user logs out
      self.lastUnreadCount = 0
      result(true)
    case "isAvailable":
      result(self.initialized)
    case "getUnreadCount":
      if let dimelo = Dimelo.sharedInstance() {
        dimelo.fetchUnreadCount { [weak self] count, error in
          if let _ = error {
            result(0)
          } else {
            let unreadCount = Int(count)
            // Also trigger event if count changed
            if let self = self, unreadCount != self.lastUnreadCount {
              self.lastUnreadCount = unreadCount
              self.sendEvent([
                "event": "onUnreadCountChanged",
                "unreadCount": unreadCount,
                "userId": self.currentUserId ?? "",
                "userName": self.userName ?? "",
                "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
              ])
            }
            result(unreadCount)
          }
        }
      } else {
        result(0)
      }
    case "setDeviceToken":
      if let args = call.arguments as? [String: Any], let token = args["token"] as? String, let dimelo = Dimelo.sharedInstance() {
        // Expect a hex string representation of the APNs token
        if let data = dataFromHexString(token) {
          dimelo.deviceToken = data
          result(true)
        } else {
          result(false)
        }
      } else {
        result(false)
      }
    case "handlePush":
      if let _ = call.arguments as? [String: Any], let _ = Dimelo.sharedInstance() {
        // iOS push handling is typically via UNUserNotificationCenter; return false for app to route.
        result(false)
      } else {
        result(false)
      }
    case "setAppBarTitle":
      if let args = call.arguments as? [String: Any], let title = args["title"] as? String {
        self.appBarTitle = title
        
        // Update the current chat view controller if it exists
        if let chatVC = self.currentChatViewController {
          DispatchQueue.main.async {
            chatVC.title = title
            chatVC.navigationItem.title = title
          }
        }
        
        self.updateAppBar()
        result(true)
      } else {
        result(false)
      }
    case "setAppBarColor":
      if let args = call.arguments as? [String: Any], let colorHex = args["color"] as? String {
        if let color = self.colorFromHex(colorHex) {
          self.appBarColor = color
          self.updateAppBar()
          result(true)
        } else {
          result(false)
        }
      } else {
        result(false)
      }
    case "setAppBarTitleColor":
      if let args = call.arguments as? [String: Any], let colorHex = args["color"] as? String {
        if let color = self.colorFromHex(colorHex) {
          self.appBarTitleColor = color
          self.updateAppBar()
          result(true)
        } else {
          result(false)
        }
      } else {
        result(false)
      }
    case "setBackArrowColor":
      if let args = call.arguments as? [String: Any], let colorHex = args["color"] as? String {
        if let color = self.colorFromHex(colorHex) {
          self.backArrowColor = color
          
          // Update the back button color on the current chat if visible
          if let chatVC = self.currentChatViewController {
            DispatchQueue.main.async {
              if let leftButton = chatVC.navigationItem.leftBarButtonItem {
                leftButton.tintColor = color
              }
            }
          }
          
          self.updateAppBar()
          result(true)
        } else {
          result(false)
        }
      } else {
        result(false)
      }
    case "setAppBarVisibility":
      if let args = call.arguments as? [String: Any], let visible = args["visible"] as? Bool {
        self.appBarVisible = visible
        self.updateAppBar()
        result(true)
      } else {
        result(false)
      }
    case "setBackButtonVisibility":
      if let args = call.arguments as? [String: Any], let visible = args["visible"] as? Bool {
        self.showBackButton = visible
        self.updateAppBar()
        result(true)
      } else {
        result(false)
      }
    case "getAppBarConfig":
      let config: [String: Any] = [
        "title": self.appBarTitle,
        "color": self.hexFromColor(self.appBarColor),
        "visible": self.appBarVisible,
        "showBackButton": self.showBackButton,
        "fullScreenPresentation": self.fullScreenPresentation
      ]
      result(config)
    case "setFullScreenPresentation":
      if let args = call.arguments as? [String: Any], let fullScreen = args["fullScreen"] as? Bool {
        self.fullScreenPresentation = fullScreen
        result(true)
      } else {
        result(false)
      }
    case "getCurrentUser":
      let userInfo: [String: Any] = [
        "userId": self.currentUserId ?? "",
        "userName": self.userName ?? "",
        "userEmail": self.userEmail ?? "",
        "userPhone": self.userPhone ?? ""
      ]
      result(userInfo)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - App Bar Helper Methods
  
  /// Convert hex color string to UIColor
  private func colorFromHex(_ hex: String) -> UIColor? {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt64 = 0
    
    var r: CGFloat = 0.0
    var g: CGFloat = 0.0
    var b: CGFloat = 0.0
    var a: CGFloat = 1.0
    
    let length = hexSanitized.count
    
    guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
    
    if length == 6 {
      r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
      g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
      b = CGFloat(rgb & 0x0000FF) / 255.0
    } else if length == 8 {
      r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
      g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
      b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
      a = CGFloat(rgb & 0x000000FF) / 255.0
    } else {
      return nil
    }
    
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
  
  /// Convert UIColor to hex string
  private func hexFromColor(_ color: UIColor) -> String {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    
    let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
    
    return String(format: "#%06x", rgb)
  }
  
  /// Configure navigation controller with app bar settings
  private func configureNavigationController(_ navController: UINavigationController) {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = self.appBarColor
    appearance.titleTextAttributes = [.foregroundColor: self.appBarTitleColor]
    
    // Remove button background
    appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: self.backArrowColor]
    
    navController.navigationBar.standardAppearance = appearance
    navController.navigationBar.scrollEdgeAppearance = appearance
    navController.navigationBar.compactAppearance = appearance
    navController.navigationBar.tintColor = self.backArrowColor
    
    // Set navigation bar visibility
    navController.setNavigationBarHidden(!self.appBarVisible, animated: false)
  }

  /// Update the app bar configuration for the current view controller
  private func updateAppBar() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      if let topVC = self.topViewController() {
        // Update navigation bar appearance
        if let navController = topVC.navigationController {
          let appearance = UINavigationBarAppearance()
          appearance.configureWithOpaqueBackground()
          appearance.backgroundColor = self.appBarColor
          appearance.titleTextAttributes = [.foregroundColor: self.appBarTitleColor]
          
          // Remove button background
          appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: self.backArrowColor]
          
          navController.navigationBar.standardAppearance = appearance
          navController.navigationBar.scrollEdgeAppearance = appearance
          navController.navigationBar.compactAppearance = appearance
          navController.navigationBar.tintColor = self.backArrowColor
          
          // Update title
          topVC.navigationItem.title = self.appBarTitle
          
          // Update back button
          if self.showBackButton {
            topVC.navigationItem.leftBarButtonItem = self.createBackButton()
          } else {
            topVC.navigationItem.leftBarButtonItem = nil
          }
          
          // Update navigation bar visibility
          navController.setNavigationBarHidden(!self.appBarVisible, animated: true)
        }
      }
    }
  }
  
  // MARK: - FlutterStreamHandler
  
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    stopUnreadCountMonitoring()
    return nil
  }
  
  // MARK: - Event Helper Methods
  
  /// Send event to Flutter via event channel
  private func sendEvent(_ event: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(event)
    }
  }
  
  // MARK: - Unread Count Monitoring
  
  /// Start monitoring unread message count
  private func startUnreadCountMonitoring() {
    stopUnreadCountMonitoring() // Stop any existing timer
    
    guard self.initialized, let dimelo = Dimelo.sharedInstance() else {
      return
    }
    
    unreadCountTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
      self?.checkUnreadCount()
    }
  }
  
  /// Stop monitoring unread message count
  private func stopUnreadCountMonitoring() {
    unreadCountTimer?.invalidate()
    unreadCountTimer = nil
  }
  
  /// Check current unread count and notify if changed
  private func checkUnreadCount() {
    guard self.initialized, let dimelo = Dimelo.sharedInstance() else {
      return
    }
    
    dimelo.fetchUnreadCount { [weak self] count, error in
      guard let self = self else { return }
      
      if let error = error {
        print("Error checking unread count: \(error)")
        return
      }
      
      let unreadCount = Int(count)
      if unreadCount != self.lastUnreadCount {
        self.lastUnreadCount = unreadCount
        self.sendEvent([
          "event": "onUnreadCountChanged",
          "unreadCount": unreadCount,
          "userId": self.currentUserId ?? "",
          "userName": self.userName ?? "",
          "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
        ])
        print("Dimelo unread count changed: \(unreadCount) for user: \(self.currentUserId ?? "unknown")")
      }
    }
  }
}
