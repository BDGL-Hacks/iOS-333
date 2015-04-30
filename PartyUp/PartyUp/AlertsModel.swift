//
//  AlertsModel.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/30/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation

/* Singleton PartyUpBackend Instance */
private let _AlertsModelInstance = AlertsModel()

class AlertsModel {
    
   /*--------------------------------------------*
    * Singleton instance method
    *--------------------------------------------*/
    
    class var instance: AlertsModel {
        return _AlertsModelInstance
    }
    
    
   /*--------------------------------------------*
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    var checkUpQueryResults: NSArray = NSArray()
    var groupInvites: NSArray = NSArray()
    var eventInvites: NSArray = NSArray()
   
    
   /*--------------------------------------------*
    * Set methods
    *--------------------------------------------*/
    
    /* Queries the backend and updates the model  *
     * with new results. Returns an error message *
     * string if update failed.                   */
    func update() -> NSString?
    {
        PULog("Updating alerts...")
        let (errorMessage: NSString?, groupInviteResults: NSArray?, eventInviteResults: NSArray?) = PartyUpBackend.instance.queryUserInvitations()
        if (errorMessage != nil) {
            PULog("Update Failed: \(errorMessage!)")
            return errorMessage!
        } else {
            PULog("Update Success!")
            groupInvites = groupInviteResults!
            eventInvites = eventInviteResults!
            return nil
        }
    }
    
    func setGroupInvites(results: NSArray) {
        groupInvites = results
    }
    
    func setEventInvites(results: NSArray) {
        eventInvites = results
    }
    
    
   /*--------------------------------------------*
    * Get methods
    *--------------------------------------------*/
    
    func getGroupInvites() -> NSArray {
        return groupInvites
    }
    
    func getEventInvites() -> NSArray {
        return eventInvites
    }
    
}