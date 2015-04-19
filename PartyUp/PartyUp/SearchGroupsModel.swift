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
        
        // TODO: Delete this, fake data
        var fakeArray: [NSDictionary] = [
            ["id": "2", "title": "MAH GROUP", "time": "2015-04-12 09:00:00",
                "members": [], "events": []],
            ["id": "1457095834", "title": "blargh", "time": "2015-04-12 08:00:00",
                "members": [], "events": []],
            ["id": "57893042", "title": "blargh", "time": "2015-04-12 08:00:00",
                "members": [], "events": [["title": "herp"], ["title": "derp"], ["title": "herp"], ["title": "derp"], ["title": "herp"], ["title": "derp"]]],
            ["id": "43241234", "title": "blargh", "time": "2015-04-12 08:00:00",
                "members": [], "events": [["title": "herp"], ["title": "derp"], ["title": "herp"]]],
            ["id": "49234244", "title": "blargh", "time": "2015-04-12 08:00:00",
                "members": [], "events": [["title": "herp"], ["title": "derp"], ["title": "herp"]]],
            ["id": "1285745", "title": "blargh", "time": "2015-04-12 08:00:00",
                "members": [], "events": [["title": "herp"], ["title": "derp"], ["title": "herp"]]],
            ["id": "75890627", "title": "blargh", "time": "2015-04-12 08:00:00",
                "members": [], "events": [["title": "herp"], ["title": "derp"], ["title": "herp"]]],
            ["id": "320547234", "title": "I don't even...", "time": "2015-04-12 08:00:00",
                "members": [], "events": [["title": "What"], ["title": "the"], ["title": "*?"]]],
        ]
        return NSArray(array: fakeArray)
        
        /*
        let resultArray: NSArray? = groupsQueryResults["attending"] as! NSArray?
        if (resultArray == nil) {
            return NSArray()
        }
        else {
            return resultArray!
        }
        */
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
