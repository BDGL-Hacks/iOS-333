//
//  PartyUpBackend.swift
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
    * Backend POST Methods
    *--------------------------------------------*/
    
    /* Performs user authentication on the backend.                    *
     * Returns an error message string if login failed, nil otherwise. */
    func backendLogin(email: NSString, password: NSString, deviceID: String) -> NSString?
    {
        PULog("Attempting to authenticate user...")
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/users/login/"
        var postParams: [String: String] = ["username": email as String, "password": password as String, "deviceID": deviceID as String]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
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
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/users/register/"
        var postParams: [String: String] = ["email": email as String, "first_name": firstName as String, "last_name": lastName as String, "password": password as String]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
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
    
    /*------------------------------------------
    * Group and Event Creation
    *------------------------------------------*/
    
    /* Performs backend event creation.      *
     * Returns an error message string if    *
     * event creation failed, nil otherwise. */
    func backendEventCreation(title: NSString, location: NSString, ageRestrictions: NSString,
        isPublic: NSString, price: NSString, inviteList: [NSString], dateTime: NSString, description: NSString) -> (NSString?, NSString?)
    {
        PULog("Attempting to create an event...")
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString = userDefaults.objectForKey("USERNAME") as! NSString
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/events/create/"
        var postParams: [String: String] = ["title": title as String, "public": isPublic as String, "age_restrictions": ageRestrictions as String, "price": price as String, "location_name": location as String, "time": dateTime as String, "description": description as String]
        
        // user IDs passed as a list of comma-separated values
        var stringOfFriendIDs: String = ""
        var i: Int = 0
        for friend in inviteList {
            if i == 0 {
                stringOfFriendIDs += (friend as String)
            }
            else {
                stringOfFriendIDs += "," + (friend as String)
            }
            i += 1
        }
        postParams["invite_list"] = stringOfFriendIDs
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            // not sure if event id returned as integer or as an NSString
            var eventID: NSInteger? = jsonData.valueForKey("id") as! NSInteger?
            
            // Event creation successful on server side
            if (accepted) {
                PULog("Event Creation Successful!")
                PULog("\(eventID)")
                return (nil, "\(eventID!)" as NSString?)
            }
                
            // Register was unsuccessful on server side
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Event creation Failed: \(errorMessage!)")
                return (errorMessage, nil)
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Event Creation Failed: No JSON data received")
            return ("Failed to connect to server", nil)
        }
    }
    
    /* Performs backend group creation.      *
     * Returns an error message string if    *
     * event creation failed, nil otherwise. */
    func backendGroupCreation(groupName: NSString, eventIDs: [NSString], inviteList: [NSString]) -> NSString?
    {
        PULog("Attempting to create a group...")
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString = userDefaults.objectForKey("USERNAME") as! NSString
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/groups/create"
        var postParams: [String: String] = ["title": groupName as String]
        
        // user and event IDs passed as a list of comma-separated values
        var stringOfUserIDs: String = ""
        var stringOfEventIDs: String = ""
        var i: Int = 0
        for user in inviteList {
            if i == 0 {
                stringOfUserIDs += (user as String)
            }
            else {
                stringOfUserIDs += "," + (user as String)
            }
            i += 1
        }
        
        i = 0
        
        for event in eventIDs {
            if i == 0 {
                stringOfEventIDs += (event as String)
            }
            else {
                stringOfEventIDs += "," + (event as String)
            }
            i += 1
        }
        
        postParams["invite_list"] = stringOfUserIDs
        postParams["event_ids"] = stringOfEventIDs
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Event creation successful on server side
            if (accepted) {
                PULog("Group Creation Successful!")
                return nil
            }
                
            // Register was unsuccessful on server side
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Group creation Failed: \(errorMessage!)")
                return errorMessage
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Group Creation Failed: No JSON data received")
            return "Failed to connect to server"
        }
    }
    
    
   /*------------------------------------------
    * Methods for updating groups and events
    *------------------------------------------*/
    
    /* Adds events to a preexisting group.  *
     * Returns an error message string if    *
     * group update failed, nil otherwise.   */
    func backendUpdateGroup(groupID: NSString, eventIDs: [NSString]) -> NSString? {
        PULog("Attemping to update a group")
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString = userDefaults.objectForKey("USERNAME") as! NSString
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/groups/addevent"
        var postParams: [String: String] = ["group": groupID as String]
        
        var stringOfEventIDs: String = ""
        var i: Int = 0
        
        // event IDs passed as a list of comma-separated values
        for event in eventIDs {
            if i == 0 {
                stringOfEventIDs += (event as String)
            }
            else {
                stringOfEventIDs += "," + (event as String)
            }
            i += 1
        }
        
        postParams["eventIDs"] = stringOfEventIDs
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Event creation successful on server side
            if (accepted) {
                PULog("Group Update Successful!")
                return nil
            }
                
            // Register was unsuccessful on server side
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Group update Failed: \(errorMessage!)")
                return errorMessage
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Group Update Failed: No JSON data received")
            return "Failed to connect to server"
        }
    }
    
    /* Invite friends to a preexisting event. *
     * Returns an error message string if       *
     * invite update failed, nil otherwise.     */
    func backendEventAddFriends(eventID: NSString, userIDs: [NSString]) -> NSString? {
        PULog("Attemping to add friends to an event")
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString = userDefaults.objectForKey("USERNAME") as! NSString
        
        /* Check API call */
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/events/invite/"
        var postParams: [String: String] = ["event": eventID as String]
        
        var stringOfUserIDs: String = ""
        var i: Int = 0
        
        for user in userIDs {
            if i == 0 {
                stringOfUserIDs += (user as String)
            }
            else {
                stringOfUserIDs += "," + (user as String)
            }
            i += 1
        }
        
        postParams["userIDs"] = stringOfUserIDs
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Event creation successful on server side
            if (accepted) {
                PULog("Event add friends successful!")
                return nil
            }
                
            // Register was unsuccessful on server side
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Event add friends Failed: \(errorMessage!)")
                return errorMessage
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Event add friends failed: No JSON data received")
            return "Failed to connect to server"
        }
    }
    
    /* Invite friends to a preexisting group.  *
     * Returns an error message string if       *
     * invite update failed, nil otherwise.     */
    func backendGroupAddFriends(groupID: NSString, userIDs: [NSString]) -> NSString? {
        PULog("Attemping to add friends to a group")
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString = userDefaults.objectForKey("USERNAME") as! NSString
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/groups/invite/"
        var postParams: [String: String] = ["group": groupID as String]
        
        var stringOfUserIDs: String = ""
        var i: Int = 0
        
        // user IDs passed as a list of comma-separated values
        for user in userIDs {
            if i == 0 {
                stringOfUserIDs += (user as String)
            }
            else {
                stringOfUserIDs += "," + (user as String)
            }
            i += 1
        }
        
        postParams["userIDs"] = stringOfUserIDs
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Event creation successful on server side
            if (accepted) {
                PULog("Group add friends successful!")
                return nil
            }
                
            // Register was unsuccessful on server side
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Group add friends Failed: \(errorMessage!)")
                return errorMessage
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Group add friends failed: No JSON data received")
            return "Failed to connect to server"
        }
        
    }
    
    /* Respond to a group or event invite: *
     * Returns an error message string if  *
     * response failed, nil otherwise.     */
    func respondToInvite(inviteType: NSString, inviteID: NSInteger, response: Bool) -> NSString?
    {
        PULog("Responding to invitation...")
        
        let postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/invites/respond"
        let postParams: [String: String] = ["obj_type": inviteType as String, "obj_id": "\(inviteID)", "accept": "\(response)"]
        
        let postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Message was sent successfully
            if (accepted) {
                PULog("Response sent successfully!")
                return nil
            }
                
            // Message was not sent
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received"
                }
                PULog("Message failed to send: \(errorMessage!)")
                return errorMessage
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Authentication Failed: No JSON data received")
            return "Failed to connect to server"
        }
    }
    
    /* Respond to a check-up ping:         *
     * Returns an error message string if  *
     * response failed, nil otherwise.     */
    func respondToPing(groupID: NSInteger, response: Bool) -> NSString?
    {
        PULog("Responding to ping...")
        
        let postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/groups/ping/respond"
        let postParams: [String: String] = ["group": "\(groupID)", "response": "\(response)"]
        
        let postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Message was sent successfully
            if (accepted) {
                PULog("Response sent successfully!")
                return nil
            }
                
            // Message was not sent
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received"
                }
                PULog("Message failed to send: \(errorMessage!)")
                return errorMessage
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Authentication Failed: No JSON data received")
            return "Failed to connect to server"
        }
    }
    
    /* Posts a group chat message on the backend. *
     * Returns an error message string if message *
     * posting failed, nil otherwise.             */
    func postGroupChatMessage(groupID: NSInteger, message: NSString) -> NSString?
    {
        PULog("Attempting to post group chat message...")
        
        let postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/groups/messages/post"
        let postParams: [String: String] = ["groupid": "\(groupID)", "message": message as String]
        
        let postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Message was sent successfully
            if (accepted) {
                PULog("Message sent successfully!")
                return nil
            }
                
            // Message was not sent
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received"
                }
                PULog("Message failed to send: \(errorMessage!)")
                return errorMessage
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Authentication Failed: No JSON data received")
            return "Failed to connect to server"
        }
    }
    
    
   /*--------------------------------------------*
    * Backend GET Methods
    *--------------------------------------------*/
    
    /* Queries backend for groups the current user belongs or *
     * has been invited to. Returns a tuple: an error message *
     * if something went wrong, and query results as an       *
     * NSArray if successful.                                 */
    func queryUserGroups() -> (NSString?, NSArray?)
    {
        PULog("Querying for user's groups...")
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString? = userDefaults.objectForKey("USERNAME") as! NSString?
        let types: NSString = "attending"
        
        if (username == nil) {
            PULog("Query Failed: User is not logged in")
            return ("User is not logged in.", nil)
        }
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/groups/get"
        var postParams: [String: String] = ["username": username! as String, "type": types as String]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Query successful: return JSON data as dictionary
            if (accepted) {
                PULog("Query Successful!")
                let results: NSArray? = jsonData.valueForKey("attending") as! NSArray?
                PULog("Query data: \(results!)")
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
    
    /* Queries backend for the most recent, or next ten messages *
     * in the group chat. If the messageID is provided, the 10   *
     * previous messages are queried. Returns a tuple: an error  *
     * message string is something went wrong, and the JSON data *
     * as an NSArray if it was successful.                       */
    func queryGroupMessages(#groupID: NSInteger, messageID: NSInteger? = nil) -> (NSString?, NSInteger?, NSArray?)
    {
        if (messageID == nil) {
            PULog("Querying for most recent group messages")
        } else {
            PULog("Querying for previous group messages")
        }
        
        let postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/groups/messages/get"
        
        var postParams: [String: String]
        if (messageID == nil) {
            postParams = ["groupid": "\(groupID)"]
        }
        else {
            postParams = ["groupid": "\(groupID)", "messageid": "\(messageID!)"]
        }
        
        let postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            var userID: NSInteger? = jsonData.valueForKey("userID") as! NSInteger?
            var results: NSArray? = jsonData.valueForKey("results") as! NSArray?
            
            // Query successful: return JSON data as an array
            if (accepted) {
                PULog("Query Sucessful!")
                PULog("Query Data: \(results!)")
                return (nil, userID!, results!)
            }
                
            // Query failed: return error message
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Query Failed: (errorMessage!)")
                return (errorMessage, nil, nil)
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Query Failed: No JSON data received")
            return ("Failed to connect to server", nil, nil)
        }
    }
    
    /* Queries backend for events and groups the user has   *
     * been invited to. Returns a tuple: an error message   *
     * string if somthing went wrong, group invite query    *
     * results as an NSArray and event invite query results *
     * as an NSArray if successful.                         */
    func queryUserInvitations() -> (NSString?, NSArray?, NSArray?)
    {
        PULog("Querying for user's invitations...")
        
        var groupInvitationsArray: NSArray?
        var eventInvitationsArray: NSArray?
        
        // Query for group invitations
        PULog("Querying group invitations")
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/groups/get/"
        var postParams: [String: String] = ["type": "invited"]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Query successful: set group invitations array
            if (accepted) {
                PULog("Query Successful!")
                groupInvitationsArray = jsonData.valueForKey("invited") as! NSArray?
                PULog("Query data: \(groupInvitationsArray!)")
            }
                
            // Query failed: return error message
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Query Failed: \(errorMessage!)")
                return (errorMessage, nil, nil)
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Query Failed: No JSON data received")
            return ("Failed to connect to server", nil, nil)
        }
        
        // Query for event invitations
        PULog("Querying event invitations")
        
        postURL = "http://\(UBUNTU_SERVER_IP)/api/events/get/"
        postParams = ["type": "invited"]
        
        postData = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Query successful: set group invitations array
            if (accepted) {
                PULog("Query Successful!")
                eventInvitationsArray = jsonData.valueForKey("invited") as! NSArray?
                PULog("Query data: \(eventInvitationsArray!)")
                return (nil, groupInvitationsArray, eventInvitationsArray)
            }
                
            // Query failed: return error message
            else {
                if (errorMessage == nil) {
                    errorMessage = "No error message received from server"
                }
                PULog("Query Failed: \(errorMessage!)")
                return (errorMessage, nil, nil)
            }
        }
            
        // We did not receive JSON data back
        else {
            PULog("Query Failed: No JSON data received")
            return ("Failed to connect to server", nil, nil)
        }
    }
    
    /* Queries backend for events the current user owns,  *
     * or is attending. Returns a tuple: an error message *
     * string if something went      *
     * wrong, and query results as an NSArray if successful. */
    func queryUserEvents() -> (NSString?, NSArray?)
    {
        PULog("Querying for user's events...")
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString? = userDefaults.objectForKey("USERNAME") as! NSString?
        let types: NSString = "attending"
        
        if (username == nil) {
            PULog("Query Failed: User is not logged in")
            return ("User is not logged in.", nil)
        }
        
        PULog("Got here!")
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/events/get/"
        var postParams: [String: String] = ["username": username! as String, "type": types as String]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            
            // Query successful: return JSON data as dictionary
            if (accepted) {
                PULog("Query Successful!")
                let results: NSArray? = jsonData.valueForKey("attending") as! NSArray?
                PULog("Query data: \(results!)")
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
     * went wrong, and the JSON data as NSArray if it was     *
     * successful.                                            */
    func queryFindEvents(title: NSString? = nil, description: NSString? = nil, isPublic: Bool? = nil,
        date: NSString? = nil,        time: NSString? = nil,      age: NSInteger? = nil,
        price: NSInteger? = nil) -> (NSString?, NSArray?)
    {
        PULog("Querying for local events...")
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/events/search/"
        
        // Populate query parameter list with whatever arguments were provided
        var postParams: [String: String] = Dictionary<String, String>()
        if (title != nil) {
            postParams["title"] = title! as String
        }
        if (description != nil) {
            postParams["description"] = description! as String
        }
        if (isPublic != nil) {
            postParams["public"] = "\(isPublic!)"
        }
        if (date != nil) {
            postParams["date"] = date! as String
        }
        if (time != nil) {
            postParams["time"] = time! as String
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
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            let results: NSArray? = jsonData.valueForKey("results") as! NSArray?
            
            // Query successful: return JSON data as an array
            if (accepted) {
                PULog("Query Successful!")
                PULog("Query data: \(results!)")
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
    
    /* Queries the backend for an event by its unique ID. *
    *  Returns a tuple: an error message string if        *
    *  something went wrong, and query results as         *
    *  dictionary if successful.                          */
    func queryEventSearchByID(eventID: NSString?) -> (NSString?, NSDictionary?)
    {
        PULog("Trying to retreive an event by its ID ...");
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString? = userDefaults.objectForKey("USERNAME") as! NSString?
        
        if (username == nil) {
            PULog("Query Failed: User is not logged in")
            return ("User is not logged in.", nil)
        }
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/events/getid/"
        var postParams: [String: String] = ["event": eventID! as String]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            PULog("Accepted? \(accepted)")
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            /* make sure backend sends back "users" as key */
            let result: NSDictionary? = jsonData.valueForKey("event") as! NSDictionary?
            
            // Query successful: return JSON data as dictionary
            if (accepted) {
                PULog("Query Successful!")
                PULog("Query data: \(result)")
                return (nil, result!)
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
    
    /* Queries the backend for a group by its unique ID. *
     * Returns a tuple: an error message string if       *
     * something went wrong, and query results as        *
     * dictionary if successful.                         */
    func queryGroupSearchByID(groupID: NSString?) -> (NSString?, NSDictionary?)
    {
        PULog("Trying to retreive an group by its ID ...");
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString? = userDefaults.objectForKey("USERNAME") as! NSString?
        
        if (username == nil) {
            PULog("Query Failed: User is not logged in")
            return ("User is not logged in.", nil)
        }
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/groups/getid/"
        var postParams: [String: String] = ["id": groupID! as String]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            PULog("Accepted? \(accepted)")
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            /* make sure backend sends back "users" as key */
            let result: NSDictionary? = jsonData.valueForKey("group") as! NSDictionary?
            
            // Query successful: return JSON data as dictionary
            if (accepted) {
                PULog("Query Successful!")
                PULog("Query data: \(result)")
                return (nil, result!)
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
    
    /* Queries backend for the user's user object. Returns a *
     * tuple: an error message if something went wrong, and  *
     * the userID as an NSDictionary if successful.          */
    func queryUserInfo() -> (NSString?, NSDictionary?)
    {
        PULog("Querying for user's information...")
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString? = userDefaults.objectForKey("USERNAME") as! NSString?
        
        if (username == nil) {
            PULog("Query Failed: User is not logged in")
            return ("User is not logged in.", nil)
        }
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/users/search/"
        var postParams: [String: String] = [ "search": username! as String]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            let resultArray: NSArray? = jsonData.valueForKey("results") as! NSArray?
            
            // Query successful: return JSON data as dictionary
            if (accepted) {
                PULog("Query Successful!")
                let results: NSDictionary = resultArray![0] as! NSDictionary
                PULog("Query data: \(results)")
                return (nil, results)
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
    
    /* Queries backend for the user's pings. Returns a       *
     * tuple: an error message if something went wrong, and  *
     * the user's pings as an NSArray if successful.         */
    func queryUserPings() -> (NSString?, NSArray?)
    {
        PULog("Querying for user's pings...")
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/users/ping/get"
        var postParams: [String: String] = ["a": "b"]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            let results: NSArray? = jsonData.valueForKey("pings") as! NSArray?
            
            // Query successful: return JSON data as dictionary
            if (accepted) {
                PULog("Query Successful!")
                PULog("Query data: \(results!)")
                return (nil, results)
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
    
    /* Queries backend for users by search query. Query can be   *
     * first name, last name, email, or user ID.                 *
     * Returns a tuple: an error message string if something     *
     * went wrong, and query results as dictionary if successful.*/
    func queryUsers(search: NSString) -> (NSString?, NSArray?)
    {
        PULog("Querying for users to populate table in add freinds ...");
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString? = userDefaults.objectForKey("USERNAME") as! NSString?
        
        if (username == nil) {
            PULog("Query Failed: User is not logged in")
            return ("User is not logged in.", nil)
        }
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/users/search/"
        var postParams: [String: String] = ["username": username! as String, "search": search as String]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            /* make sure backend sends back "users" as key */
            let results: NSArray? = jsonData.valueForKey("results") as! NSArray?
            
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
    
    /* Queries backend for a batch of 10 random users.    *
     * Returns a tuple: an error message string if        *
     * something went wrong, and a batch of users as      *
     * an NS dictionary if successful.                    */
    func queryBatch() -> (NSString?, NSArray?)
    {
        PULog("Querying a random batch  ...");
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let username: NSString? = userDefaults.objectForKey("USERNAME") as! NSString?
        
        if (username == nil) {
            PULog("Query Failed: User is not logged in")
            return ("User is not logged in.", nil)
        }
        
        var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/users/batch/"
        var postParams: [String: String] = ["username": username! as String]
        
        var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)
        
        // We received JSON data back: process it
        if (postData != nil)
        {
            let jsonData: NSDictionary = postData!
            let accepted: Bool = jsonData.valueForKey("accepted") as! Bool
            var errorMessage: NSString? = jsonData.valueForKey("error") as! NSString?
            /* make sure backend sends back "users" as key */
            let results: NSArray? = jsonData.valueForKey("results") as! NSArray?
            
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
        
        var requestURL: NSURL = NSURL(string: url as String)!
        var requestErr: NSError?
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        
        var requestString: NSMutableString = ""
        for (key, value) in params {
            for eachValue in value.componentsSeparatedByString("||") {
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
            let httpResponse = response as! NSHTTPURLResponse
            PULog("Response Status Code: \(httpResponse.statusCode)")
            
            // We got a success status code from URL: return JSON data
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300)
            {
                var responseData: NSString = NSString(data: urlData!, encoding: NSUTF8StringEncoding)!
                PULog("Response Data: \(responseData)")
                
                var jsonError: NSError?
                let jsonData: NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as! NSDictionary
                
                PULog("End POST Request Method\n")
                return jsonData
            }
                
            // We got a failure status code from URL: return nil
            else {
                PULog("Bad Response Status Code. Response data is invalid.")
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