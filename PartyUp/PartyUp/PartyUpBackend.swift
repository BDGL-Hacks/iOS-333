//
//  PartyUpStore.swift
//  PartyUp
//
//  Created by Graham Turk on 3/29/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation

/* Singleton PartyUpBackend Instance */
private let _PartyUpBackendInstance = PartyUpBackend()

class PartyUpBackend {
    
   /*--------------------------------------------*
    * Singleton instance method
    *--------------------------------------------*/
    
    class var instance: PartyUpBackend {
        return _PartyUpBackendInstance
    }
    
    
   /*--------------------------------------------*
    * Backend Constants
    *--------------------------------------------*/
    
    let UBUNTU_SERVER_IP: NSString = "52.4.3.6"
    let DAVID_LINODE_SERVER_IP: NSString = "23.239.14.40:8000"
    
    
   /*--------------------------------------------*
    * Backend Interfacing Methods
    *--------------------------------------------*/
    
    /* Performs user authentication on the backend.                    *
     * Returns an error message string if login failed, nil otherwise. */
    func backendLogin(email: NSString, password: NSString) -> NSString?
    {
        NSLog("Attempting to authenticate user...")
        
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
    
    /* Performs user registration on the backend.      *
     * Returns an error message string if registration *
     * failed, nil otherwise.                          */
    func backendRegister(firstName: NSString, lastName: NSString,
        email: NSString, password: NSString) -> NSString?
    {
        NSLog("Attempting to register new user...")
        
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
    * Backend Helper Methods
    *--------------------------------------------*/
    
    /* Sends POST Request to url with provided parameters.             *
     * Returns JSON data as NSDictionary if successful, nil otherwise. */
    func sendPostRequest(params: Dictionary<String, String>, url: NSString) -> NSDictionary?
    {
        NSLog("\nSending POST Request:")
        NSLog("URL: %@", url)
        NSLog("Params Dictionary: %@", params)
        
        var requestURL: NSURL = NSURL(string: url)!
        var requestErr: NSError?
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        
        var requestString: NSMutableString = ""
        for (key, value) in params {
            requestString.appendString("&\(key)=\(value)")
        }
        if (requestString.length > 0) {
            requestString = NSMutableString(string: requestString.substringFromIndex(1))
        }
        
        NSLog("Request Data String: %@", requestString)
        let requestData: NSData = requestString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        request.HTTPMethod = "POST"
        request.HTTPBody = requestData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var response: NSURLResponse?
        var responseError: NSError?
        
        // Send request to URL and (hopefully) receive data back
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &responseError)
        
        // We got data back from the URL ...
        if (urlData != nil)
        {
            let httpResponse = response as NSHTTPURLResponse
            NSLog("Response Status Code: %ld", httpResponse.statusCode)
            
            // We got a success status code from URL: return JSON data
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300)
            {
                var responseData: NSString = NSString(data: urlData!, encoding: NSUTF8StringEncoding)!
                NSLog("Response Data: %@", responseData)
                
                var jsonError: NSError?
                let jsonData: NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as NSDictionary
                
                NSLog("End POST Request Method\n")
                return jsonData
            }
                
            // We got a failure status code from URL: return nil
            else {
                NSLog("Bad Response Status Code. Response data was not received.")
                NSLog("End POST Request Method\n")
                return nil
            }
        }
            
        // We did not get data back from URL: return nil
        else {
            NSLog("No response from URL. Response data was not received.")
            NSLog("End POST Request Method\n")
            return nil
        }
    }
    
}