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
                PULog("Update Failed: \(errorMessage)")
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
                PULog("Update Failed: \(errorMessage)")
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
        return userEventsQueryResults["created"] as NSArray
    }
    
    func getAttendingEvents() -> NSArray {
        return userEventsQueryResults["attending"] as NSArray
    }
    
    func getInvitedEvents() -> NSArray {
        return userEventsQueryResults["invited"] as NSArray
    }
    
    func getNearbyEvents() -> NSArray {
        return findEventsQueryResults
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