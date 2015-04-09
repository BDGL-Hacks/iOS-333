//
//  ViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 3/21/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class PartyUpViewController: UIViewController {
    
   /*--------------------------------------------*
    * View Information:
    *  - The keys stored in user default prefs are:
    *    USERNAME (NSString), IS_LOGGED_IN (Bool)
    *--------------------------------------------*/
    
    
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
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle(buttonText)
        alertView.show()
    }
    
   
   /*--------------------------------------------*
    * Global Helper Methods
    *--------------------------------------------*/
    
    /* Authenticate the user and save related values   *
     * in user default prefs. Returns an error message *
     * string if login failed, nil otherwise.          */
    func authenticate(email: NSString, password: NSString) -> NSString? {
        var backendError: NSString? = PartyUpBackend.instance.backendLogin(email, password: password)
        if (backendError == nil) {
            PULog("Login Success!")
            var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(true, forKey: "IS_LOGGED_IN")
            userDefaults.setObject(email, forKey: "USERNAME")
            userDefaults.synchronize()
        }
        else {
            PULog("Login Failed.")
        }
        return backendError
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
        
        let regularExpression: NSRegularExpression = NSRegularExpression(pattern: regex, options: regexOptions, error: &error)!
        let numMatches: Int = regularExpression.numberOfMatchesInString(string, options: nil, range: NSMakeRange(0, string.length))
        
        return numMatches > 0
    }

}
