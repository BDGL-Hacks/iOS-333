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
    
    @IBAction func login(sender: UIButton)
    {
        // Ensure the form is valid
        var validationError: NSString? = validateForm()
        if (validationError != nil) {
            displayAlert("Login Failed", message: validationError!)
            return
        }
        
        // Attempt backend authentication
        var backendError: NSString? = backendLogin()
        if (backendError == nil) {
            self.dismissViewControllerAnimated(true, completion:nil)
        }
        else {
            displayAlert("Login Failed", message: backendError!)
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
    * View helper methods
    *--------------------------------------------*/
    
    /* Validates the form fields.         *
     * Returns an error message string    *
     * if form is invalid, nil otherwise. */
    func validateForm() -> NSString?
    {
        let email: NSString = emailTextField.text
        let password: NSString = passwordTextField.text
        
        if (email == "" || password == "") {
            return "Email Address and Password are required."
        }
        if (!stringMatchesRegex(email, regex: EMAIL_VALIDATOR_REGEX)) {
            return "Email Address is invalid."
        }
        
        return nil
    }
    
    
   /*--------------------------------------------*
    * Backend Interfacing methods
    *--------------------------------------------*/
    
    /* Performs user authentication on the backend.                    *
     * Returns an error message string if login failed, nil otherwise. */
    func backendLogin() -> NSString?
    {
        NSLog("Attempting to authenticate user...")
        
        var email: NSString = emailTextField.text
        var password: NSString = passwordTextField.text
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/users/login/"
        var postParams: [String: String] = ["username": email, "password": password]
        
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
