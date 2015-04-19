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
        let resultArray: NSArray? = userEventsQueryResults["created"] as! NSArray?
        if (resultArray == nil) {
            return NSArray()
        }
        else {
            return resultArray!
        }
        
    }
    
    func getAttendingEvents() -> NSArray {
        
        // TODO: Delete this, fake data
        var fakeArray: [NSDictionary] = [
            ["title": "Fake Event", "location_name": "I don't know", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Look, Another Event!", "location_name": "Still don't.", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "GAAAGH!", "location_name": "URGH", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Derping", "location_name": "derpy-perp", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Derping", "location_name": "derpy-perp", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Derping", "location_name": "derpy-perp", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Derping", "location_name": "derpy-perp", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Derping", "location_name": "derpy-perp", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Derping", "location_name": "derpy-perp", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Derping", "location_name": "derpy-perp", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Fake Data", "location_name": "Insert location here", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []]
        ]
        return NSArray(array: fakeArray)
        
        /*
        let resultArray: NSArray? = userEventsQueryResults["attending"] as NSArray?
        if (resultArray == nil) {
            return NSArray()
        }
        else {
            return resultArray!
        }
        */
    }
    
    func getInvitedEvents() -> NSArray {
        
        // TODO: Delete this, fake data
        var fakeArray: [NSDictionary] = [
            ["title": "Fake Event", "location_name": "I don't know", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Look, Another Event!", "location_name": "Still don't.", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "GAAAGH!", "location_name": "URGH", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list": [],
                "attending_list": []],
            ["title": "Fake Data", "location_name": "Insert location here", "time": "2015-04-12 09:00:00",
                "description": "A bad description", "location_name": "Princeton, NJ", "invite_list":
                [
                    ["username": "username", "first_name": "First", "last_name": "Last", "id": 2],
                    ["username": "username", "first_name": "First", "last_name": "Last", "id": 2],
                    ["username": "username", "first_name": "First", "last_name": "Last", "id": 2],
                    ["username": "username", "first_name": "First", "last_name": "Last", "id": 2],
                    ["username": "username", "first_name": "First", "last_name": "Last", "id": 2],
                    ["username": "username", "first_name": "First", "last_name": "Last", "id": 2],
                    ["username": "username", "first_name": "First", "last_name": "Last", "id": 2],
                    ["username": "username", "first_name": "First", "last_name": "Last", "id": 2]
                ],
                "attending_list": []
            ]
        ]
        return NSArray(array: fakeArray)
        
        /*
        let resultArray: NSArray? = userEventsQueryResults["invited"] as NSArray?
        if (resultArray == nil) {
            return NSArray()
        }
        else {
            return resultArray!
        }
        */
    }
    
    func getNearbyEvents() -> NSArray {
        return findEventsQueryResults
    }
    
}