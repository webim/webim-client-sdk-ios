//
//  AppDelegate.swift
//  WebimClientLibrary_Example
//
//  Created by Nikita Lazarev-Zubov on 01.00.2017.
//  Copyright © 2017 Webim. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Firebase
import UIKit
import WebimMobileSDK
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    static var shared: AppDelegate!
    lazy var isApplicationConnected: Bool = false
    var hasRemoteNotification = false
    
    private var notificationUserInfo: [AnyHashable: Any]?
    
    // MARK: - Methods
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.shared = self
        WMKeychainWrapper.standard.setAppGroupName(userDefaults: UserDefaults(suiteName: "group.WebimClient.Share") ?? UserDefaults.standard,
                                                   keychainAccessGroup: Bundle.main.infoDictionary!["keychainAppIdentifier"] as! String)
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        // Remote notifications configuration
        let notificationTypes: UNAuthorizationOptions = [.alert,
                                                         .badge,
                                                         .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: notificationTypes) { (granted, error) in
            if granted {
                // application.registerUserNotificationSettings(remoteNotificationSettings)
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    application.applicationIconBadgeNumber = 0
                }
            } else {
                print(error ?? "Error with remote notification")
            }
        }

        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        WMKeychainWrapper.standard.setString(deviceToken, forKey: WMKeychainWrapper.deviceTokenKey)
        
        print("Device token: \(deviceToken)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo["aps"] as? [String: Any] else {
            completionHandler(.newData)
            return
        }
        if let delString = aps["del-id"] as? String,
           let delData = delString.data(using: .utf8) {
            do {
                let del = try JSONDecoder().decode([String].self, from: delData)
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: del)
            } catch {
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [delString])
            }
        } else {
            completionHandler(.newData)
            return
        }
        
        openChatFromNotification(userInfo)
        completionHandler(.noData)
    }
        
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }

    static func checkMainThread() {
        if !Thread.isMainThread {
#if DEBUG
            fatalError("Not main thread error")
#else
            print("Not main thread error")
#endif
        }
    }

    private func openChatFromNotification(_ notificationUserInfo: [AnyHashable: Any]) {
        // WEBIM: Remote notification handling.
        if Webim.isWebim(remoteNotification: notificationUserInfo) {
            _ = Webim.parse(remoteNotification: notificationUserInfo)
            // Handle Webim remote notification.
            
            guard !isChatIsTopViewController() else { return }

            if let navigationController = getNavigationController() {
                navigationController.popToRootViewController(animated: false)
                guard let startViewController = navigationController.viewControllers.first as? WMStartViewController else { return }
                startViewController.startChat()
            }
        } else {
            // Handle another type of remote notification.
        }
    }

    private func isChatIsTopViewController() -> Bool {
        guard let navigationController = getNavigationController() else {
            return false
        }
    
        return navigationController.viewControllers.last?.isChatViewController == true
    }
    
    private func getNavigationController() -> UINavigationController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let navigationController = windowScene?.windows.first?.rootViewController as? UINavigationController
        return navigationController
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        notificationUserInfo = notification.request.content.userInfo

        guard !isChatIsTopViewController() else {
            completionHandler([])
            return
        }

        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        hasRemoteNotification = true
        if let notificationUserInfo = notificationUserInfo {
            openChatFromNotification(notificationUserInfo)
        }
        
        completionHandler()
    }
}
