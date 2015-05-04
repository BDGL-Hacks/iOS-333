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
    
    var userEventsQueryResults: NSArray = NSArray()
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
            let (errorMessage: NSString?, queryResults: NSArray?) =
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
    
    func setUserEventsQueryResults(results: NSArray) {
        userEventsQueryResults = results
    }
    
    func setFindEventsQueryResults(results: NSArray) {
        findEventsQueryResults = results
    }
    
    
   /*--------------------------------------------*
    * Get methods
    *--------------------------------------------*/
    
    func getAttendingEvents() -> NSArray {
        return userEventsQueryResults
    }
    
    func getNearbyEvents() -> NSArray {
        return findEventsQueryResults
    }
    
}