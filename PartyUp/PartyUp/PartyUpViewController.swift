//
//  ViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 3/21/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class PartyUpViewController: UIViewController {
    
   /*--------------------------------------------------*
    * View Information:
    *  - The keys stored in user default prefs are:
    *    USERNAME (NSString), IS_LOGGED_IN (Bool)
    *    USER_ID (NSInteger), USER_FULL_NAME (NSString)
    *--------------------------------------------------*/
    
    
   /*--------------------------------------------*
    * Global View Constants
    *--------------------------------------------*/
    
    let NAME_VALIDATOR_REGEX: NSString = "\\A\\p{L}+\\z"
    let EMAIL_VALIDATOR_REGEX: NSString = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.]{1}[A-Za-z]{2,4}$"
    
    
   /*--------------------------------------------*
    * Global UI Methods
    *--------------------------------------------*/
    
    /* Displays an alert with the provided title and message */
    func displayAlert(title: NSString, message: NSString, buttonText: NSString = "OK") {
        var alertView: UIAlertView = UIAlertView()
        alertView.title = title as String
        alertView.message = message as String
        alertView.delegate = self
        alertView.addButtonWithTitle(buttonText as String)
        alertView.show()
    }
    
   
   /*--------------------------------------------*
    * Global Helper Methods
    *--------------------------------------------*/
    
    /* Authenticate the user and save related values   *
     * in user default prefs. Returns an error message *
     * string if login failed, nil otherwise.          */
    func authenticate(email: NSString, password: NSString) -> NSString?
    {
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var deviceTokenData: NSData? = userDefaults.objectForKey("DEVICE_ID") as! NSData?
        
        var test = UIApplication.sharedApplication().isRegisteredForRemoteNotifications()
        
        if (deviceTokenData == nil) {
            PULog("Device not registered... Using 'zero' device ID")
            deviceTokenData = NSData()
        }
        
        let deviceID: String = "\(deviceTokenData!)"
        
        var backendError: NSString? = PartyUpBackend.instance.backendLogin(email, password: password, deviceID: deviceID)
        
        if (backendError == nil)
        {
            PULog("Login Success!")
            
            var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(true, forKey: "IS_LOGGED_IN")
            userDefaults.setObject(email, forKey: "USERNAME")
            
            var (errorMessage: NSString?, user: NSDictionary?) = (nil, nil)
            (errorMessage, user) = PartyUpBackend.instance.queryUserInfo()
            
            if (errorMessage == nil) {
                PULog("Retrieved user information")
                userDefaults.setInteger(DataManager.getUserID(user!), forKey: "USER_ID")
                userDefaults.setObject(DataManager.getUserFullName(user!), forKey: "USER_FULL_NAME")
            }
            else {
                PULog("Failed to retrieve user information")
                userDefaults.setInteger(0, forKey: "USER_ID")
                userDefaults.setObject("--No User--", forKey: "USER_FULL_NAME")
            }
            
            userDefaults.synchronize()
        }
            
        else {
            PULog("Login Failed.")
        }
        
        return backendError
    }
    
    /* Returns whether the user is logged in */
    func isLoggedIn() -> Bool {
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.boolForKey("IS_LOGGED_IN")
    }
    
    
    /* Returns whether the string matches the regex */
    func stringMatchesRegex(string: NSString, regex: NSString, caseInsensitive: Bool = false) -> Bool
    {
        var regexOptions: NSRegularExpressionOptions
        if caseInsensitive {
            regexOptions = .CaseInsensitive
        } else {
            regexOptions = nil
        }
        var error: NSError?
        
        let regularExpression: NSRegularExpression = NSRegularExpression(pattern: regex as String, options: regexOptions, error: &error)!
        let numMatches: Int = regularExpression.numberOfMatchesInString(string as String, options: nil, range: NSMakeRange(0, string.length))
        
        return numMatches > 0
    }

}
