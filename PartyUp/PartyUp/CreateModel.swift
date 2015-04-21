//
//  CreateModel.swift
//  PartyUp
//
//  Created by Graham Turk on 4/6/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation


class CreateModel {
    
    enum QueryType {
        case Batch
        case Search
    }
    
    /* Event data */
    var eventTitle: NSString? = nil
    var eventLocation: NSString? = nil
    var dateTime: NSString? = nil
    var friendsList: [NSString] = [NSString]()
    var eventPrice: NSString? = nil
    var eventPublic: NSString? = nil
    var eventAgeRestrictions: NSString? = nil
    
    /* Group data */
    var eventIDs: [NSString] = [NSString]()
    var inviteIDs: [NSString] = [NSString]()
    var groupName: NSString? = nil
    
    // MARK: Event methods
    
    /*-------------------------------*
     * Event Methods 
     *-------------------------------*/
    
    
    func eventFirstPage (title: NSString, location: NSString, dateTime: NSString, eventPublic: NSString) {
        eventTitle = title
        eventLocation = location
        self.dateTime = dateTime
        eventPrice = "10000000"
        self.eventPublic = eventPublic
        eventAgeRestrictions = "0"
    }
    
    func eventSecondPage(friends: [NSString]) {
        
        friendsList = [NSString]() // reinitialize in case someone goes back to first page
        friendsList = friends
    }
    
    func eventSendToBackend() -> NSString? {
      
        // Registration successful: Dismiss Registration view and attempt login
        var backendError: NSString? = PartyUpBackend.instance.backendEventCreation(eventTitle!, location: eventLocation!, ageRestrictions: eventAgeRestrictions!, isPublic: eventPublic!, price: eventPrice!, inviteList: friendsList, dateTime: dateTime!)
        if (backendError == nil)
        {
            return nil
        }
        else {
            return "Event creation failed"
        }
    }
    
    // MARK: Group methods

    /*-------------------------------*
     * Group Methods
     *-------------------------------*/

    func groupFirstPage(inviteIDs: [NSString], groupName: NSString)
    {
        self.inviteIDs = inviteIDs
        self.groupName = groupName
    }
    
    func groupSecondPage(eventIDs: [NSString]) {
        self.eventIDs = eventIDs
    }


    func groupSendToBackend() -> NSString?
    {
        // Registration successful: Dismiss Registration view and attempt login
        var backendError: NSString? = PartyUpBackend.instance.backendGroupCreation(groupName!, eventIDs: eventIDs, inviteList: inviteIDs)
        if (backendError == nil)
        {
            return nil
        }
        else {
            return "Group creation failed"
        }
    }


    /*--------------------------------------------*
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    var batchUsersQueryResults: NSArray = NSArray()
    var searchUsersQueryResults: NSArray = NSArray()
    var selectedUsers: NSArray = NSArray()
    var inviteList: NSArray = NSArray()
    var groupEvents: NSArray = NSArray()
    
    /*--------------------------------------------*
    * Set methods
    *--------------------------------------------*/
    
    /* Queries the backend and updates the model with new *
    * results. queryType specifies what to query for.    *
    * Returns an error message string if update failed.  */
    func update(queryType: QueryType, search: NSString?) -> NSString?
    {
        if (queryType == QueryType.Batch) {
            PULog("Updating batch users...")
            let (errorMessage: NSString?, queryResults: NSArray?) =
            PartyUpBackend.instance.queryBatch()
            if (errorMessage != nil) {
                PULog("Update Failed: \(errorMessage!)")
                return errorMessage!
            } else {
                PULog("Update Success!")
                batchUsersQueryResults = queryResults!
                return nil
            }
        }
        
        else if (queryType == QueryType.Search)
        {
            PULog("Updating search users...")
            let (errorMessage: NSString?, queryResults: NSArray?) =
            PartyUpBackend.instance.queryUsers(search!)
            if (errorMessage != nil) {
                PULog("Update Failed: \(errorMessage!)")
                return errorMessage!
            } else {
                PULog("Update Success!")
                searchUsersQueryResults = queryResults!
                return nil
            }
        }
        else {
            return "Update failed: Invalid query type"
        }
    }
    
    func setSearchUsersQueryResults(results: NSArray) {
        searchUsersQueryResults = results
    }
    
    func setBatchUsersQueryResults(results: NSArray) {
        batchUsersQueryResults = results
    }
    
    
    func setSelectedUsers(selected: NSArray) {
        selectedUsers = selected
    }

    
    func setInviteList(invited: NSArray) {
        inviteList = invited
    }

    /*--------------------------------------------*
    * Get methods
    *--------------------------------------------*/
    
    func getSearchUsers() -> NSArray {
        
        var usersToDisplay: NSMutableArray = NSMutableArray()
        for query in searchUsersQueryResults {
            let queryDict = query as! NSDictionary
            var queryID: NSString = CreateEventModel.getUserID(queryDict)
            var isInQueryList: Bool = false
            for invitee in inviteList {
                let inviteeDict = invitee as! NSDictionary
                var inviteeID: NSString = CreateEventModel.getUserID(inviteeDict)
                if queryID == inviteeID {
                    isInQueryList = true
                    PULog("ID's are equal")
                    break
                }
            }
            if !isInQueryList {
                usersToDisplay.addObject(query)
            }
        }
        // fix this
        return usersToDisplay as NSArray
        // return searchUsersQueryResults
    }
    
    func getBatchUsers() -> NSArray {
        return batchUsersQueryResults
    }
    
    /* Returns the selected friends from search     *
     * Omits users who have already been added to   *
     * the invite list. Made this design decision   *
     * rather than only displaying uninvited guests *
     * in a query because a query could potentially *
       return thousands of names                    */
    func getSelectedUsers() -> NSArray {
        var usersToAdd: NSMutableArray = NSMutableArray()
        for selected in selectedUsers {
            let selectedDict = selected as! NSDictionary
            var selectedID: NSString = CreateEventModel.getUserID(selectedDict)
            var isInAddedList: Bool = false
            for invitee in inviteList {
                let inviteeDict = invitee as! NSDictionary
                var inviteeID: NSString = CreateEventModel.getUserID(inviteeDict)
                if selectedID == inviteeID {
                    isInAddedList = true
                    break
                }
            }
            if !isInAddedList {
                usersToAdd.addObject(selected)
            }
        }
        return usersToAdd as NSArray
    }
    
    func getInvitedList() -> NSArray {
        return inviteList
    }
    
    
    /*--------------------------------------------*
    * Group events methods
    *--------------------------------------------*/
    
    
    
    /*--------------------------------------------*
    * Data extraction methods
    *--------------------------------------------*/
    
    
    class func getUserID(user: NSDictionary) -> NSString {
        var userID: AnyObject? = user["id"]
        return "\(userID)"
        
        // return user["id"] as NSString
    }
    
    class func getUserFirstName(user: NSDictionary) -> NSString {
        return user["first_name"] as! NSString
    }
    
    class func getUserLastName(user: NSDictionary) -> NSString {
        return user["last_name"] as! NSString
    }
    
    class func getUserEmail(user: NSDictionary) -> NSString {
        return user["username"] as! NSString // email?
    }
}