//
//  RegisterViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 3/27/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class RegisterViewController: PartyUpViewController {
    
    // regModel = new RegisterModel()

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var backToLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*--------------------------------------------*
     * View response methods
     *--------------------------------------------*/
    
    @IBAction func register(sender: UIButton) {
        backendRegister()
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
    * Backend Interfacing methods
    *--------------------------------------------*/
    
    // Saving Cookies: NSHTTPCookieStorage
    // Put POST stuff in seperate method
    // Save some constants
    // Put alert stuff in seperate method
    
    @IBAction func backendRegister()
    {
        NSLog("Register:\n---------------")
        
        var firstName: NSString = firstNameTextField.text
        var lastName: NSString = lastNameTextField.text
        var email: NSString = emailTextField.text
        var password: NSString = passwordTextField.text
        
        /* TODO: Put IP into a constant! */
        // Ubuntu IP = "52.4.3.6"
        // David's Linode IP = "23.239.14.40:8000"
        var url: NSURL = NSURL(string: "http://23.239.14.40:8000/users/register/")!
        
        var post: NSString = "email=\(email)&first_name=\(firstName)&last_name=\(lastName)&password=\(password)"
        var postData: NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        var postLength: NSString = String(postData.length)
        NSLog("Post: %@", post)
        
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        
        // ?? What's happening here ??
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var response: NSURLResponse?
        var responseError: NSError?
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &responseError)
        
        if (urlData != nil)
        {
            let httpResponse = response as NSHTTPURLResponse
            NSLog("Response Status Code: %ld", httpResponse.statusCode)
            
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300)
            {
                var responseData: NSString = NSString(data: urlData!, encoding: NSUTF8StringEncoding)!
                NSLog("Response Data %@", responseData)
                
                var error: NSError?
                let jsonData: NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                
                let accepted: Bool = jsonData.valueForKey("accepted") as Bool
                var errorMessage: NSString? = jsonData.valueForKey("error") as NSString?
                
                if (accepted) {
                    NSLog("Register Successful!")
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else
                {
                    if (errorMessage != nil) {
                        NSLog("Register Failed: %@", errorMessage!)
                    }
                    else {
                        NSLog("Register Failed: No error message sent back", errorMessage!)
                    }
                    
                    var alertView: UIAlertView = UIAlertView()
                    alertView.title = "Sign Up Failed"
                    alertView.message = errorMessage
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }
            else
            {
                NSLog("Error: Connection Failed")
                
                var alertView: UIAlertView = UIAlertView()
                alertView.title = "Sign Up Failed"
                alertView.message = "Connection Error: Bad status code"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
        else
        {
            NSLog("Error: Connection Failed - No data received back")
            
            if (response != nil) {
                NSLog("Response:%@", response!)
            }
            else {
                NSLog("Response var is nil")
            }
            
            if (responseError != nil) {
                NSLog("Response Error:%@", responseError!)
            }
            else {
                NSLog("Response Error var is nil")
            }
            
            var alertView: UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed"
            alertView.message = "Connection Failed"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        
        NSLog("---------------")
    }

}
