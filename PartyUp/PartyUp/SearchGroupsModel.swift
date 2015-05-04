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
    
    var groupsQueryResults: NSArray = NSArray()
    
    
   /*--------------------------------------------*
    * Set methods
    *--------------------------------------------*/
    
    /* Queries the backend and updates the model with new          *
     * results. Returns an error message string if update failed.  */
    func update() -> NSString?
    {
        PULog("Updating User Groups...")
        let (errorMessage: NSString?, queryResults: NSArray?) =
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
    
    func setGroupsQueryResults(results: NSArray) {
        groupsQueryResults = results
    }
    
    
   /*--------------------------------------------*
    * Get methods
    *--------------------------------------------*/
    
    func getAttendingGroups() -> NSArray {
        return groupsQueryResults
    }

}
