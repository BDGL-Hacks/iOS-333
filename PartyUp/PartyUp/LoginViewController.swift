//
//  LoginViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 3/28/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class LoginViewController: PartyUpViewController, UITextFieldDelegate {
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!

    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    @IBAction func login(sender: UIButton) {
        var error: NSString? = backendLogin()
        
        // Authentication successful: Dismiss Login view and go to homepage
        if (error == nil) {
            self.dismissViewControllerAnimated(true, completion:nil)
        }
        
        // Authentication failed: Alert user of the failure
        else {
            displayAlert("Login Failed", message: error!)
        }
    }
    
    @IBAction func viewTapped(sender : AnyObject) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
   /*--------------------------------------------*
    * Backend Interfacing methods
    *--------------------------------------------*/
    
    /* Performs user authentication on the backend.                    *
     * Returns an error message string is login failed, nil otherwise. */
    func backendLogin() -> NSString?
    {
        NSLog("Attempting to authenticate user...")
        
        var email: NSString = emailTextField.text
        var password: NSString = passwordTextField.text
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/users/login/"
        var postParams: [String: String] = ["email": email, "password": password]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as NSString?
            
            // Authentication successful on server side
            if (accepted) {
                NSLog("Authentication Successful!")
                return nil
            }
            
            // Authentication was unsucessful on server side
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                NSLog("Authentication Failed: %@", errorMessage!)
                return errorMessage
            }
        }
        
        // We did not receive JSON data back
        else {
            NSLog("Authentication Failed: No JSON data received")
            return "Failed to connect to server"
        }
    }
}
