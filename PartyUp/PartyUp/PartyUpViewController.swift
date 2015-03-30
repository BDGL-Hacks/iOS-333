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
    * Global Constants
    *--------------------------------------------*/
    
    let UBUNTU_SERVER_IP = "52.4.3.6"
    let DAVID_LINODE_SERVER_IP = "23.239.14.40:8000"
    
    
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
    * Global Backend Interfacing Methods
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
        let requestData: NSData = requestString.dataUsingEncoding(NSASCIIStringEncoding)!
        
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

