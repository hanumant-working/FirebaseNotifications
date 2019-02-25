//
//  AppDelegate.swift
//  FirebasePushNotification
//
//  Created by Hanumant S on 10/01/19.
//  Copyright © 2019 Hanumant S. All rights reserved.
//



// Install Pod -
// Activate Push Notifications Capabilities
// Activate Background Notifications If Required
// pod 'Firebase/Core'
// pod 'Firebase/Messaging'



import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureFirebase(for: application)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}



// Push Notifications Methods
extension AppDelegate {
    
    func registerPush(_ application: UIApplication) {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
                if !granted {
                    // Handle notification permission denied
                }
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNS: \(token)")
        Messaging.messaging().apnsToken = deviceToken
        print("Token: \(deviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let state : UIApplication.State = application.applicationState
        if state == UIApplication.State.active {
            
        } else if state == UIApplication.State.background {
            
        } else {
            // Inactive
            
        }
        /*
         if USER.userId.count > 0 {
         parseNotificationJson(userInfo: userInfo as? [String: Any])
         }
         */
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    private func configureFirebase(for application:  UIApplication) {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
    }
}


extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("fcmToken: \(fcmToken)")
        /*
         UserDefaultsManager.updateCurrentDeviceToken(token: fcmToken)
         if USER.userId.count > 0 {
         // Sent old and new device tokens to server.
         //UserDefaultsManager.isDeviceTokenUpdated()
         } */
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("remoteMessage: \(remoteMessage.appData)")
        
    }
    
}


@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let payload = notification.request.content.userInfo as? [String:Any]
        print("Will Present Payload: \(payload)")
        /*
         if USER.userId.count > 0 {
         parseNotificationJson(userInfo: notification.request.content.userInfo as? [String:Any])
         }
         */
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let payload = response.notification.request.content.userInfo as? [String:Any]
        print("didReceive Payload: \(payload)")
        /*
         if USER.userId.count > 0 {
         parseNotificationJson(userInfo: response.notification.request.content.userInfo as? [String:Any])
         }
         */
        completionHandler()
    }
}


func getFCMToken() -> String {
    if let fcmToken = Messaging.messaging().fcmToken {
        return fcmToken
    }
    return "NoTokenAvialable"
}

func getDeviceUUID() -> String {
    return String(describing: UIDevice.current.identifierForVendor!.uuidString)
}
