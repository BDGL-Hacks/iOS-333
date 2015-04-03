//
//  HomepageViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class HomepageViewController: PartyUpViewController
{
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet var groupsChildView: UIView!
    @IBOutlet var eventsChildView: UIView!
    
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var navSegmentedControl: UISegmentedControl!
    
    
   /*--------------------------------------------*
    * Computed Properties
    *--------------------------------------------*/
    
    var activeView: UIView!
    {
        get {
            if (navSegmentedControl.selectedSegmentIndex == 0) {
                return groupsChildView
            } else {
                return eventsChildView
            }
        }
    }
    
    var inactiveView: UIView! {
        get {
            if (navSegmentedControl.selectedSegmentIndex == 0) {
                return eventsChildView
            } else {
                return groupsChildView
            }
        }
    }
    
    
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
        self.performSegueWithIdentifier("homeToLogin", sender: self)
    }
    
    @IBAction func navSegmentedControlChanged(sender: UISegmentedControl) {
        activeView.hidden = false
        inactiveView.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn: Bool = userDefaults.boolForKey("IS_LOGGED_IN")
        
        // If the user is not logged in, delete cookies and go to login screen
        if (!isLoggedIn) {
            NSLog("User is not logged in.")
            NSLog("Deleting cookies...")
            var cookieStorage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in cookieStorage.cookies! {
                cookieStorage.deleteCookie(cookie as NSHTTPCookie)
            }
            NSLog("Transitioning to Login screen")
            self.performSegueWithIdentifier("homeToLogin", sender: self)
        }
        
        // If the user is logged in, display the homepage
        else {
            NSLog("User is logged in. Displaying homepage.")
            navSegmentedControl.selectedSegmentIndex = 0
            groupsChildView.hidden = false
            eventsChildView.hidden = true
        }
    }
    
}