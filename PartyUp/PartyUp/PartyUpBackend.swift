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
    
    /* title, public?, age_restrictions, price, invite-list */
    
    /*--------------------------------------------*
    * Backend Interfacing Methods
    *--------------------------------------------*/
    
    /* Performs event creation      *
    * Returns an error message string if registration *
    * failed, nil otherwise.                          */
    func backendEventCreation(title: NSString, location: NSString, ageRestrictions: NSString,
        isPublic: NSString, price: NSString, inviteList: [NSString]) -> NSString?
    {
        PULog("Attempting to create an event...")
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/users/events/create"
        var postParams: [String: String] = ["title": title, "public": isPublic, "age_restrictions": ageRestrictions, "price": price]
        
        var stringOfFriends: String = ""
        var i: Int = 0
        for friend in inviteList {
            if i == 0 {
                stringOfFriends += friend
            }
            else {
                stringOfFriends += "," + friend
            }
            i += 1
        }
        postParams["invite_list"] = stringOfFriends
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as NSString?
            
            // Event creation successful on server side
            if (accepted) {
                PULog("Event Creation Successful!")
                return nil
            }
                
                // Register was unsuccessful on server side
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Event creation Failed: \(errorMessage!)")
                return errorMessage
            }
        }
            
            // We did not receive JSON data back
        else {
            PULog("Event Creation Failed: No JSON data received")
            return "Failed to connect to server"
        }
    }
    
    
    /* Performs user authentication on the backend.                    *
     * Returns an error message string if login failed, nil otherwise. */
    func backendLogin(email: NSString, password: NSString) -> NSString?
    {
        PULog("Attempting to authenticate user...")
        
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
                PULog("Authentication Successful!")
                return nil
            }
                
            // Authentication was unsucessful on server side
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Authentication Failed: \(errorMessage!)")
                return errorMessage
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Authentication Failed: No JSON data received")
            return "Failed to connect to server"
        }
    }
    
    /* Performs user registration on the backend.      *
     * Returns an error message string if registration *
     * failed, nil otherwise.                          */
    func backendRegister(firstName: NSString, lastName: NSString,
        email: NSString, password: NSString) -> NSString?
    {
        PULog("Attempting to register new user...")
        
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
                PULog("Register Successful!")
                return nil
            }
                
            // Register was unsuccessful on server side
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Register Failed: \(errorMessage!)")
                return errorMessage
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Register Failed: No JSON data received")
            return "Failed to connect to server"
        }
    }
    
    /* Queries backend for events the current user owns,   *
     * is attending, or has been invited to. Returns a     *
     * tuple: an error message string if something went    *
     * wrong, and query results as NSArray if successful.  */
    func queryUserEvents() -> (NSString?, NSArray?)
    {
        PULog("Querying for user's events...");
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString = userDefaults.objectForKey("USERNAME") as NSString
        let types: NSString = "created invited attending"
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/users/get/"
        var postParams: [String: String] = ["username": username, "type": types]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as NSString?
            let results: NSArray? = jsonData.valueForKey("results") as NSArray?
            
            // Query successful: return JSON data as dictionary
            if (accepted) {
                PULog("Query Successful!")
                PULog("Query data: \(results)")
                return (nil, results!)
            }
                
            // Query failed: return error message
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Query Failed: \(errorMessage!)")
                return (errorMessage, nil)
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Query Failed: No JSON data received")
            return ("Failed to connect to server", nil)
        }
    }
    
    /* Queries backend for a general search of nearby events. *
     * Returns a tuple: an error message string if something  *
     * went wrong, or the JSON data as NSArray if it was      *
     * successful.                                            */
    func queryFindEvents(title: NSString? = nil, description: NSString? = nil, isPublic: Bool? = nil,
                          date: NSString? = nil,        time: NSString? = nil,      age: NSInteger? = nil,
                         price: NSInteger? = nil) -> (NSString?, NSArray?)
    {
        PULog("Querying for local events...")
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/users/search/"
        
        // Populate query parameter list with whatever arguments were provided
        var postParams: [String: String] = Dictionary<String, String>()
        if (title != nil) {
            postParams["title"] = title!
        }
        if (description != nil) {
            postParams["description"] = description!
        }
        if (isPublic != nil) {
            postParams["public"] = "\(isPublic!)"
        }
        if (date != nil) {
            postParams["date"] = date!
        }
        if (time != nil) {
            postParams["time"] = time!
        }
        if (age != nil) {
            postParams["age"] = "\(age!)"
        }
        if (price != nil) {
            postParams["price"] = "\(price!)"
        }
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as NSString?
            let results: NSArray? = jsonData.valueForKey("results") as NSArray?
            
            // Query successful: return JSON data as dictionary
            if (accepted) {
                PULog("Query Successful!")
                PULog("Query data: \(results)")
                return (nil, results!)
            }
                
            // Query failed: return error message
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Query Failed: \(errorMessage!)")
                return (errorMessage, nil)
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Query Failed: No JSON data received")
            return ("Failed to connect to server", nil)
        }
    }
    

   /*--------------------------------------------*
    * Backend Helper Methods
    *--------------------------------------------*/
    
    /* Sends POST Request to url with provided parameters.             *
     * Returns JSON data as NSDictionary if successful, nil otherwise. */
    func sendPostRequest(params: Dictionary<String, String>, url: NSString) -> NSDictionary?
    {
        PULog("\nSending POST Request:")
        PULog("URL: \(url)")
        PULog("Params Dictionary: \(params)")
        
        var requestURL: NSURL = NSURL(string: url)!
        var requestErr: NSError?
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        
        var requestString: NSMutableString = ""
        for (key, value) in params {
            for eachValue in value.componentsSeparatedByString(" ") {
                requestString.appendString("&\(key)=\(eachValue)")
            }
        }
        if (requestString.length > 0) {
            requestString = NSMutableString(string: requestString.substringFromIndex(1))
        }
        
        PULog("Request Data String: \(requestString)")
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
            PULog("Response Status Code: \(httpResponse.statusCode)")
            
            // We got a success status code from URL: return JSON data
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300)
            {
                var responseData: NSString = NSString(data: urlData!, encoding: NSUTF8StringEncoding)!
                PULog("Response Data: \(responseData)")
                
                var jsonError: NSError?
                let jsonData: NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as NSDictionary
                
                PULog("End POST Request Method\n")
                return jsonData
            }
                
            // We got a failure status code from URL: return nil
            else {
                PULog("Bad Response Status Code. Response data was not received.")
                PULog("End POST Request Method\n")
                return nil
            }
        }
            
        // We did not get data back from URL: return nil
        else {
            PULog("No response from URL. Response data was not received.")
            PULog("End POST Request Method\n")
            return nil
        }
    }
    
}