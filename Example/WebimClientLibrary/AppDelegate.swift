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


import UIKit
import WebimClientLibrary

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Constants
    enum UserDefaultsKey: String {
        case DEVICE_TOKEN = "device-token"
    }

    
    // MARK: - Properties
    var window: UIWindow?

    
    // MARK: - Methods
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Remote notifications configuration.
        let notificationTypes: UIUserNotificationType = [.alert,
                                                         .badge,
                                                         .sound]
        let remoteNotificationSettings = UIUserNotificationSettings(types: notificationTypes,
                                                                    categories: nil)
        application.registerUserNotificationSettings(remoteNotificationSettings)
        application.registerForRemoteNotifications()
        
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device token: \(deviceToken)")
        UserDefaults.standard.set(deviceToken,
                                  forKey: UserDefaultsKey.DEVICE_TOKEN.rawValue)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        
        // WEBIM: Remote notification handling.
        if Webim.isWebim(remoteNotification: userInfo) == true {
            _ = Webim.parse(remoteNotification: userInfo)
            // Handle Webim remote notification.
        } else {
            // Handle another type of remote notification.
        }
    }

}
