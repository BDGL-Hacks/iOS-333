//
//  AppDelegate.swift
//  PartyUp
//
//  Created by Lance Goodridge on 3/21/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Register for Push Notifications
        PULog("Attempting to register for push notifications")
        UIApplication.sharedApplication().registerForRemoteNotifications()
        let settings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        // Check if the user is logged in...
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn = userDefaults.boolForKey("IS_LOGGED_IN")
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // If logged in, go straight to master view controller
        if (isLoggedIn) {
            let masterViewController = MasterViewController()
            window!.rootViewController = masterViewController
        }
        
        // If you aren't logged in, go to login view controller
        else {
            let loginViewController = LoginViewController()
            window!.rootViewController = loginViewController
        }
        
        window!.makeKeyAndVisible()
        return true
    }
    
    /* Handle registering for push notifications */
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        PULog("User push notification settings registered: \(notificationSettings)")
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PULog("Registered for push notifications with device token: \(deviceToken)")
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(deviceToken, forKey: "DEVICE_ID")
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        PULog("Failed to register for push notifications: \(error)")
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSData(), forKey: "DEVICE_ID")
    }
    
    /* Handle receiving a push notification */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PULog("Printing out JSON: \(userInfo)")
        PULog("Re-querying for alerts")
        AlertsModel.instance.update()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

