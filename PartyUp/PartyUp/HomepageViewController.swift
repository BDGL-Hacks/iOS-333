//
//  HomepageViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

protocol HomepageViewControllerDelegate {
    func showSideMenu()
    func hideSideMenu()
    func toggleSideMenu()
}

enum NavView: String {
    case GroupsList   = "Groups List Page"
    case GroupsDetail = "Groups Detail Page"
    case MyEvents     = "My Events Page"
    case SearchEvents = "Search Events Page"
    case Alerts       = "Alerts Page"
}

class HomepageViewController: PartyUpViewController, SideMenuViewControllerDelegate
{
   /*--------------------------------------------*
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    var delegate: HomepageViewControllerDelegate?


   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet var groupsListChildView: UIView!
    @IBOutlet var groupsDetailChildView: UIView!
    @IBOutlet var myEventsChildView: UIView!
    @IBOutlet var searchEventsChildView: UIView!
    @IBOutlet var alertsChildView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sideMenuButton: UIButton!
    
    
   /*--------------------------------------------*
    * Computed Properties
    *--------------------------------------------*/
    
    var activeView: UIView = UIView()
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Display the groups detail page at the start, hid everything else
        groupsListChildView.hidden = true
        groupsDetailChildView.hidden = true
        myEventsChildView.hidden = true
        searchEventsChildView.hidden = true
        alertsChildView.hidden = true
        setActiveView(.GroupsList)
        
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
    
    @IBAction func sideMenuButtonPressed(sender: UIBarButtonItem) {
        PULog("Side menu button pressed")
        delegate!.toggleSideMenu()
    }


   /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Sets the active view to either Groups or Events */
    func setActiveView(newActiveView: NavView) {
        PULog("Setting active view: \(newActiveView.rawValue)")
        delegate?.hideSideMenu()
        activeView.hidden = true
        switch newActiveView {
            case .GroupsList:
                activeView = groupsListChildView
            case .GroupsDetail:
                activeView = groupsDetailChildView
            case .MyEvents:
                activeView = myEventsChildView
            case .SearchEvents:
                activeView = searchEventsChildView
            case .Alerts:
                activeView = alertsChildView
            default:
                break
        }
        activeView.hidden = false
    }
    
    /* Logs the user out */
    func logout() {
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
        delegate!.hideSideMenu()
        self.performSegueWithIdentifier("homeToLogin", sender: self)
    }
    
    /* Segues to Create Group view */
    func segueToCreateGroup() {
        PULog("Transitioning to Create Group Page")
        delegate!.hideSideMenu()
        self.performSegueWithIdentifier("homeToCreateGroup", sender: self)
    }
    
    /* Segues to Create Event view */
    func segueToCreateEvent() {
        PULog("Transitioning to Create Event Page")
        delegate!.hideSideMenu()
        self.performSegueWithIdentifier("homeToCreateEvent", sender: self)
    }
}
