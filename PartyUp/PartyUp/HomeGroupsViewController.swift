//
//  HomeGroupsViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class HomeGroupsViewController: PartyUpViewController
{
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet var logoutButton: UIButton!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    @IBAction func logout(sender: UIButton) {
        NSLog("Logout button pressed")
        NSLog("Deleting cookies...")
        var cookieStorage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in cookieStorage.cookies! {
            cookieStorage.deleteCookie(cookie as NSHTTPCookie)
        }
        NSLog("Deleting app preferences...")
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let appDomain: String = NSBundle.mainBundle().bundleIdentifier!
        userDefaults.removePersistentDomainForName(appDomain)
        userDefaults.synchronize()
        NSLog("Transitioning to Login screen")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn: Bool = userDefaults.boolForKey("IS_LOGGED_IN")
        if (!isLoggedIn) {
            NSLog("User is not logged in.")
            NSLog("Deleting cookies...")
            var cookieStorage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in cookieStorage.cookies! {
                cookieStorage.deleteCookie(cookie as NSHTTPCookie)
            }
            NSLog("Transitioning to Login screen")
            self.performSegueWithIdentifier("homeToLogin", sender: self)
        } else {
            NSLog("User is logged in. Displaying homepage.")
        }
    }
    
}
