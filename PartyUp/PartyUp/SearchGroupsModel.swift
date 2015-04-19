//
//  SearchGroupsModel.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/14/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation

class SearchGroupsModel
{
   /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var groupsQueryResults: NSDictionary = NSDictionary()
    
    
   /*--------------------------------------------*
    * Set methods
    *--------------------------------------------*/
    
    /* Queries the backend and updates the model with new          *
     * results. Returns an error message string if update failed.  */
    func update() -> NSString?
    {
        PULog("Updating User Groups...")
        let (errorMessage: NSString?, queryResults: NSDictionary?) =
            PartyUpBackend.instance.queryUserGroups()
        if (errorMessage != nil) {
            PULog("Updated Failed: \(errorMessage!)")
            return errorMessage!
        } else {
            PULog("Update Success!")
            groupsQueryResults = queryResults!
            return nil
        }
    }
    
    func setGroupsQueryResults(results: NSDictionary) {
        groupsQueryResults = results
    }
    
   /*--------------------------------------------*
    * Get methods
    *--------------------------------------------*/
    
    func getAttendingGroups() -> NSArray {
        let resultArray: NSArray? = groupsQueryResults["attending"] as! NSArray?
        if (resultArray == nil) {
            return NSArray()
        }
        else {
            return resultArray!
        }
        
    }
    
    func getInvitedGroups() -> NSArray {
        let resultArray: NSArray? = groupsQueryResults["invited"] as! NSArray?
        if (resultArray == nil) {
            return NSArray()
        }
        else {
            return resultArray!
        }
    }
}
