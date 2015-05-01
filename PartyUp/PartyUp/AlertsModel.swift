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
    * Action methods
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
    
    /* Responds to an alert cell 'accept' being pressed. *
     * Updates the backend and removes cell from table.  */
    func acceptButtonPressed(data: NSDictionary, type: PartyUpAlertCell.AlertType, index: NSInteger)
    {
        
    }
    
    /* Responds to an alert cell 'reject' being pressed. *
     * Updates the backend and removes cell from table.  */
    func rejectButtonPressed(data: NSDictionary, type: PartyUpAlertCell.AlertType, index: NSInteger)
    {
        
    }
   
    
   /*--------------------------------------------*
    * Set methods
    *--------------------------------------------*/
    
    func setGroupInvites(results: NSArray) {
        groupInvites = results
    }
    
    func setEventInvites(results: NSArray) {
        eventInvites = results
    }
    
    
   /*--------------------------------------------*
    * Get methods
    *--------------------------------------------*/
    
    // ---  TODO  ---
    func getCheckUpAlerts() -> NSArray {
        return NSArray()
    }
    // ---        ---
    
    func getGroupInvites() -> NSArray {
        return groupInvites
    }
    
    func getEventInvites() -> NSArray {
        return eventInvites
    }
    
}