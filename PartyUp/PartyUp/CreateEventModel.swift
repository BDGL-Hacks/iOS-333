//
//  CreateEventModel.swift
//  PartyUp
//
//  Created by Graham Turk on 4/6/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation


class CreateEventModel {
    
    enum QueryType {
        case Batch
        case Search
    }
    
    var eventTitle: NSString?
    var eventLocation: NSString?
    var dateTime: NSString?
    var friendsList: [NSString] = [NSString]()
    var eventPrice: NSString?
    var eventPublic: NSString?
    var eventAgeRestrictions: NSString?
    
    init () {
        eventTitle = nil
        eventLocation = nil
        dateTime = nil
        eventPrice = nil
        eventPublic = nil
        eventAgeRestrictions = nil
    }
    
    func firstPage (title: NSString, location: NSString, dateTime: NSString) {
        eventTitle = title
        eventLocation = location
        self.dateTime = dateTime
        eventPrice = "10000000"
        eventPublic = "True"
        eventAgeRestrictions = "0"
    }
    
    func secondPage(friends: [NSString]) {
        
        friendsList = [NSString]() // reinitialize in case someone goes back to first page
        friendsList = friends
    }
    
    func sendToBackend() -> NSString? {
      
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
    
    /*--------------------------------------------*
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    var batchUsersQueryResults: NSArray = NSArray()
    var searchUsersQueryResults: NSArray = NSArray()
    var selectedFriends: NSArray = NSArray()
    var addedFriends: NSArray = NSArray()
    
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
            PULog("Updating batch users...")
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
    
    
    func setSelectedFriends(friends: NSArray) {
        selectedFriends = friends
    }

    
    func setAddedFriends(friends: NSArray) {
        addedFriends = friends
    }

    /*--------------------------------------------*
    * Get methods
    *--------------------------------------------*/
    
    func getSearchUsers() -> NSArray {
        return searchUsersQueryResults
    }
    
    func getBatchUsers() -> NSArray {
        return batchUsersQueryResults
    }
    
    /* Returns the selected friends from search */
    func getSelectedFriends() -> NSArray {
        var friends: NSMutableArray = NSMutableArray()
        for friend in selectedFriends {
            let friendDict = friend as NSDictionary
            var userOneID: NSString = "9" as NSString // CreateEventModel.getUserIDStr(friendDict)
            var isInAddedList: Bool = false
            for added in addedFriends {
                let addedDict = added as NSDictionary
                var userTwoID: NSString = "11" as NSString // CreateEventModel.getUserIDStr(addedDict)
                if userOneID == userTwoID {
                    isInAddedList = true
                    break
                }
            }
            if !isInAddedList {
                friends.addObject(friend)
            }
        }
        return friends as NSArray
    }
    
    /*--------------------------------------------*
    * Data extraction methods
    *--------------------------------------------*/
    
    /*
    class func getUserIDNum(user: NSDictionary) -> NSString {
        /*var num = user["id"] as? Int
        var numstr = "\(num!)"
        return numstr as NSString
        */
        var num = "10" as NSString
        return num
    }
*/
    
    class func getUserIDStr(user: NSDictionary) -> NSString {
        return user["id"] as NSString
    }
    
    class func getUserFirstName(user: NSDictionary) -> NSString {
        return user["first_name"] as NSString
    }
    
    class func getUserLastName(user: NSDictionary) -> NSString {
        return user["last_name"] as NSString
    }
    
    class func getUserEmail(user: NSDictionary) -> NSString {
        return user["username"] as NSString // email?
    }
}