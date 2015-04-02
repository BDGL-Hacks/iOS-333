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
    
    
    var activeTextField: UITextField? {
        get {
            if (emailTextField.isFirstResponder()) {
                return emailTextField
            }
            else if (passwordTextField.isFirstResponder()) {
                return passwordTextField
            }
            return nil
        }
        set {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
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
        
        // Attempt backend authentication
        var backendError: NSString? = backendLogin()
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
    
    
    /*--------------------------------------------*
    * UITextField Delegate Methods
    *--------------------------------------------*/
    
    func textFieldDidBeginEditing(textField: UITextField!) {
        activeTextField = textField
        scrollView.scrollEnabled = true
    }
    
    func textFieldDidEndEditing(textField: UITextField!) {
        activeTextField = nil
        scrollView.scrollEnabled = false
    }
    
    /*--------------------------------------------*
    * Keyboard Scrolling Methods
    *--------------------------------------------*/
    
    // Code from creativecoefficient.net
    
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeShown:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWillBeShown(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize.height
        let activeTextFieldRect: CGRect? = activeTextField?.frame
        let activeTextFieldOrigin: CGPoint? = activeTextFieldRect?.origin
        if (!CGRectContainsPoint(aRect, activeTextFieldOrigin!)) {
            scrollView.scrollRectToVisible(activeTextFieldRect!, animated:true)
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(sender: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
}

