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
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    var navView: NavView = NavView.Groups

    enum NavView: Int {
        case Groups = 0
        case Events = 1
    }


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
        PULog("Logout button pressed")
        PULog("Deleting cookies...")
        var cookieStorage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in cookieStorage.cookies! {
            cookieStorage.deleteCookie(cookie as! NSHTTPCookie)
        }
        PULog("Deleting app preferences...")
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let appDomain: String = NSBundle.mainBundle().bundleIdentifier!
        userDefaults.removePersistentDomainForName(appDomain)
        userDefaults.synchronize()
        PULog("Transitioning to Login screen")
        self.performSegueWithIdentifier("homeToLogin", sender: self)
    }
    
    @IBAction func createButtonPressed(sender: UIBarButtonItem) {
        PULog("Create button pressed")
        if (activeView == eventsChildView) {
            PULog("Transitioning to Create Event Screen")
            self.performSegueWithIdentifier("homeToCreateEvent", sender: self)
        }
        else if (activeView == groupsChildView)
        {
            PULog("Transitioning to Create Group Screen")
            self.performSegueWithIdentifier("homeToCreateGroup", sender: self)
        }
    }
    
    @IBAction func navSegmentedControlChanged(sender: UISegmentedControl) {
        PULog("Navbar segment control changed")
        if (activeView == groupsChildView) {
            PULog("Displaying Groups child view")
            navView = NavView.Groups
        } else {
            PULog("Displaying Events child view")
            navView = NavView.Events
        }
        activeView.hidden = false
        inactiveView.hidden = true
    }

    override func viewWillAppear(animated: Bool) {
        navSegmentedControl.selectedSegmentIndex = navView.rawValue
        navSegmentedControlChanged(navSegmentedControl)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If the user is not logged in, delete cookies and go to login screen
        if (!isLoggedIn()) {
            PULog("User is not logged in.")
            PULog("Deleting cookies...")
            var cookieStorage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in cookieStorage.cookies! {
                cookieStorage.deleteCookie(cookie as! NSHTTPCookie)
            }
            PULog("Deleting app preferences...")
            var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let appDomain: String = NSBundle.mainBundle().bundleIdentifier!
            userDefaults.removePersistentDomainForName(appDomain)
            userDefaults.synchronize()
            PULog("Transitioning to Login screen")
            self.performSegueWithIdentifier("homeToLogin", sender: self)
        }
            
        // If the user is logged in, display the homepage
        else {
            NSLogPageSize()
            PULog("User is logged in. Displaying homepage.")
        }
    }


   /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Sets the active view to either Groups or Events */
    func setActiveView(newActiveView: NavView) {
        navView = newActiveView
    }

}
