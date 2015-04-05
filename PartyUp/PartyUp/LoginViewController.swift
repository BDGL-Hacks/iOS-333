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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    @IBAction func login(sender: UIButton)
    {
        NSLog("Login button pressed")
        
        // Ensure the form is valid
        var validationError: NSString? = validateForm()
        if (validationError != nil) {
            NSLog("Form is invalid: %@", validationError!)
            displayAlert("Login Failed", message: validationError!)
            return
        }
        
        // Retrieve necessary fields
        var email: NSString = emailTextField.text
        var password: NSString = passwordTextField.text
        
        // Attempt backend authentication
        var backendError: NSString? = PartyUpBackend.instance.backendLogin(email, password: password)
        if (backendError == nil)
        {
            NSLog("Login Success!")
            
            // Save logged in status in app defaults
            var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(true, forKey: "IS_LOGGED_IN")
            userDefaults.synchronize()
            
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
    
}
