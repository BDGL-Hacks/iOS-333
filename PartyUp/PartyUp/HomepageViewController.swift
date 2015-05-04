//
//  HomepageViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

@objc
protocol HomepageViewControllerDelegate {
    func showSideMenu()
    func hideSideMenu()
    func toggleSideMenu()
}

class HomepageViewController: PartyUpViewController
{
   /*--------------------------------------------*
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    var delegate: HomepageViewControllerDelegate?
    
    enum NavView {
        case Groups
        case Events
    }


   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet var groupsChildView: UIView!
    @IBOutlet var eventsChildView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sideMenuButton: UIButton!
    
    
   /*--------------------------------------------*
    * Computed Properties
    *--------------------------------------------*/
    
    //var activeView: UIView! = self.groups
    //var inactiveView: UIView! = eventsChildView
    
    
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
    
    @IBAction func sideMenuButtonPressed(sender: UIBarButtonItem) {
        PULog("Side menu button pressed")
        delegate!.toggleSideMenu()
        
        /*
        if (activeView == eventsChildView) {
            PULog("Transitioning to Create Event Screen")
            self.performSegueWithIdentifier("homeToCreateEvent", sender: self)
        }
        else if (activeView == groupsChildView)
        {
            PULog("Transitioning to Create Group Screen")
            self.performSegueWithIdentifier("homeToCreateGroup", sender: self)
        }
        */
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        PULog("Ha!, this does nothing")
    }

}
