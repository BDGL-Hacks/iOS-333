//
//  RegisterViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 3/27/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class RegisterViewController: PartyUpViewController {
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var backToLoginButton: UIButton!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    @IBAction func register(sender: UIButton)
    {
        // Ensure the form is valid
        var validationError: NSString? = validateForm()
        if (validationError != nil) {
            displayAlert("Registration Failed", message: validationError!)
            return
        }
        
        // Registration successful: Dismiss Registration view and go to homepage
        var backendError: NSString? = backendRegister()
        if (backendError == nil) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            displayAlert("Registration Failed", message: backendError!)
        }
    }
    
    @IBAction func backToLogin() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func viewTapped(sender : AnyObject) {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        retypePasswordTextField.resignFirstResponder()
    }
   
    
   /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Validates the form fields.         *
     * Returns an error message string    *
     * if form is invalid, nil otherwise. */
    func validateForm() -> NSString?
    {
        var firstName: NSString = firstNameTextField.text
        var lastName: NSString = lastNameTextField.text
        var email: NSString = emailTextField.text
        var password: NSString = passwordTextField.text
        var retypePassword: NSString = retypePasswordTextField.text
        
        if (firstName == "") {
            return "First Name is required."
        }
        if (lastName == "") {
            return "Last Name is required."
        }
        if (email == "") {
            return "Email Address is required."
        }
        if (password == "") {
            return "Password is required."
        }
        if (!stringMatchesRegex(firstName, regex: NAME_VALIDATOR_REGEX)) {
            return "First Name is invalid."
        }
        if (!stringMatchesRegex(lastName, regex: NAME_VALIDATOR_REGEX)) {
            return "Last Name is invalid."
        }
        if (!stringMatchesRegex(email, regex: EMAIL_VALIDATOR_REGEX)) {
            return "Email Address is invalid."
        }
        if (password.length < 5) {
            return "Password is too short."
        }
        if (password != retypePassword) {
            return "Password and re-typed password do not match."
        }
        
        return nil
    }
    
    
   /*--------------------------------------------*
    * Backend Interfacing methods
    *--------------------------------------------*/
    
    /* Performs user registration on the backend.      *
     * Returns an error message string if registration *
     * failed, nil otherwise.                          */
    func backendRegister() -> NSString?
    {
        NSLog("Attempting to register new user...")
        
        var firstName: NSString = firstNameTextField.text
        var lastName: NSString = lastNameTextField.text
        var email: NSString = emailTextField.text
        var password: NSString = passwordTextField.text
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/users/register/"
        var postParams: [String: String] = ["email": email, "first_name": firstName, "last_name": lastName, "password": password]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as NSString?
            
            // Register successful on server side
            if (accepted) {
                NSLog("Register Successful!")
                return nil
            }
            
            // Register was unsuccessful on server side
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                NSLog("Register Failed: %@", errorMessage!)
                return errorMessage
            }
        }

        // We did not receive JSON data back
        else {
            NSLog("Register Failed: No JSON data received")
            return "Failed to connect to server"
        }
    }

}
