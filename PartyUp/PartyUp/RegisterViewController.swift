//
//  RegisterViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 3/27/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class RegisterViewController: PartyUpViewController, UITextFieldDelegate {
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var backToLoginButton: UIButton!
    
    
   /*--------------------------------------------*
    * Computed Properties
    *--------------------------------------------*/
    
    var activeTextField: UITextField? {
        get {
            if (firstNameTextField.isFirstResponder()) {
                return firstNameTextField
            }
            else if (lastNameTextField.isFirstResponder()) {
                return lastNameTextField
            }
            else if (emailTextField.isFirstResponder()) {
                return emailTextField
            }
            else if (passwordTextField.isFirstResponder()) {
                return passwordTextField
            }
            else if (retypePasswordTextField.isFirstResponder()) {
                return retypePasswordTextField
            }
            return nil
        }
        set {
            
        }
    }
    
<<<<<<< HEAD
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        retypePasswordTextField.delegate = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
=======
>>>>>>> origin/master
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    @IBAction func register(sender: UIButton)
    {
        NSLog("Register button pressed")
        
        // Ensure the form is valid
        var validationError: NSString? = validateForm()
        if (validationError != nil) {
            NSLog("Form is invalid: %@", validationError!)
            displayAlert("Registration Failed", message: validationError!)
            return
        }
        
        // Registration successful: Dismiss Registration view and go to homepage
        var backendError: NSString? = backendRegister()
        if (backendError == nil) {
            NSLog("Registration sucess!")
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
