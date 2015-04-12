//
//  SearchEventsModel.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/7/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation

class SearchEventsModel
{
   /*--------------------------------------------*
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    var userEventsQueryResults: NSDictionary = NSDictionary()
    var findEventsQueryResults: NSArray = NSArray()
    
    enum QueryType {
        case User
        case Find
        case Current
    }
    
    
   /*--------------------------------------------*
    * Set methods
    *--------------------------------------------*/
    
    /* Queries the backend and updates the model with new *
     * results. queryType specifies what to query for.    *
     * Returns an error message string if update failed.  */
    func update(queryType: QueryType) -> NSString?
    {
        if (queryType == QueryType.User) {
            PULog("Updating User Events...")
            let (errorMessage: NSString?, queryResults: NSDictionary?) =
                PartyUpBackend.instance.queryUserEvents()
            if (errorMessage != nil) {
                PULog("Update Failed: \(errorMessage!)")
                return errorMessage!
            } else {
                PULog("Update Success!")
                userEventsQueryResults = queryResults!
                return nil
            }
        }
        else if (queryType == QueryType.Find) {
            PULog("Updating Nearby Events...")
            let (errorMessage: NSString?, queryResults: NSArray?) =
                PartyUpBackend.instance.queryFindEvents()
            if (errorMessage != nil) {
                PULog("Update Failed: \(errorMessage!)")
                return errorMessage!
            } else {
                PULog("Update Success!")
                findEventsQueryResults = queryResults!
                return nil
            }
        }
        else {
            return "Update Failed: Invalid query type"
        }
    }
    
    func setUserEventsQueryResults(results: NSDictionary) {
        userEventsQueryResults = results
    }
    
    func setFindEventsQueryResults(results: NSArray) {
        findEventsQueryResults = results
    }
    
    
   /*--------------------------------------------*
    * Get methods
    *--------------------------------------------*/
    
    func getCreatedEvents() -> NSArray {
        
        // TODO: Delete this, fake data
        var fakeArray: [NSDictionary] = [
            ["title": "Fake Event", "location_name": "I don't know"],
            ["title": "Look, Another Event!", "location_name": "Still don't."],
            ["title": "GAAAGH!", "location_name": "URGH"],
            ["title": "Derping", "location_name": "derpy-perp"],
            ["title": "Derping", "location_name": "derpy-perp"],
            ["title": "Derping", "location_name": "derpy-perp"],
            ["title": "Derping", "location_name": "derpy-perp"],
            ["title": "Derping", "location_name": "derpy-perp"],
            ["title": "Derping", "location_name": "derpy-perp"],
            ["title": "Derping", "location_name": "derpy-perp"],
            ["title": "Fake Data", "location_name": "Insert location here"]
        ]
        return NSArray(array: fakeArray)
        
        /*
        let resultArray: NSArray? = userEventsQueryResults["created"] as NSArray?
        if (resultArray == nil) {
            return NSArray()
        }
        else {
            return resultArray!
        }
        */
    }
    
    func getAttendingEvents() -> NSArray {
        let resultArray: NSArray? = userEventsQueryResults["attending"] as NSArray?
        if (resultArray == nil) {
            return NSArray()
        }
        else {
            return resultArray!
        }
    }
    
    func getInvitedEvents() -> NSArray {
        let resultArray: NSArray? = userEventsQueryResults["invited"] as NSArray?
        if (resultArray == nil) {
            return NSArray()
        }
        else {
            return resultArray!
        }
    }
    
    func getNearbyEvents() -> NSArray {
        return findEventsQueryResults
    }
    
    
   /*--------------------------------------------*
    * Data extraction methods
    *--------------------------------------------*/
    
    class func getEventTitle(event: NSDictionary) -> NSString {
        return event["title"] as NSString
    }
    
    class func getEventLocationName(event: NSDictionary) -> NSString {
        return event["location_name"] as NSString
    }
    
    
    // TODO: ACTUALLY WRITE THESE METHODS!!!
    class func getEventDayText(event: NSDictionary) -> NSString {
        return "Fri"
    }
    
    class func getEventDayNumber(event: NSDictionary) -> NSString {
        return "00"
    }
}

/*
Returns:
{
accepted: bool
results:
[
description
price
location_name
title
admin {
username
first_name
last_name
id
}
age_restrictions
invite_list
[
<Users - same as admin>
]
time: "YYYY-MM-DD hh:mm:ss+<timezone?>"
date_created
public: bool
]
}
*/