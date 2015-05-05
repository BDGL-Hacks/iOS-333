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
    
    enum AlertType: NSString {
        case CheckUp     = "Check up:"
        case GroupInvite = "Group Invitation:"
        case EventInvite = "Event Invitation:"
    }
   
    
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
    
    /* Responds to an alert cell accept / reject button being    *
     * pressed. Updates the backend and removes cell from table. */
    func responseButtonPressed(data: NSDictionary, type: AlertType, index: NSInteger, response: Bool)
    {
        if (type == AlertType.CheckUp) {
            // TODO
            PULog("Checkup response button pressed")
        }
        
        // Group Invite responded to: Update backend and delete from table
        else if (type == AlertType.GroupInvite) {
            let errorMsg: NSString? = PartyUpBackend.instance.respondToInvite(getInviteTypeString(type), inviteID: DataManager.getGroupID(data), response: response)
            if (errorMsg == nil) {
                let tempGroupInvitesArray: NSMutableArray = NSMutableArray(array: groupInvites)
                tempGroupInvitesArray.removeObjectAtIndex(index)
                groupInvites = tempGroupInvitesArray as NSArray
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(getErrorNotificationName() as String, object: self)
            }
        }

        // Event Invite responded to: update backend and delete from table
        else if (type == AlertType.EventInvite) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                NSLog("ASYNC Request")
                let errorMsg: NSString? = PartyUpBackend.instance.respondToInvite(self.getInviteTypeString(type), inviteID: DataManager.getEventID(data), response: response)
                dispatch_async(dispatch_get_main_queue()) {
                    NSLog("ASYNC UI Update")
                    if (errorMsg == nil) {
                        let tempEventInvitesArray: NSMutableArray = NSMutableArray(array: self.eventInvites)
                        tempEventInvitesArray.removeObjectAtIndex(index)
                        self.eventInvites = tempEventInvitesArray as NSArray
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName(self.getErrorNotificationName() as String, object: self)
                    }
                }
            }
        }
        
        // Post a notification so AlertsViewController knows to update its views
        NSNotificationCenter.defaultCenter().postNotificationName(getUpdateNotificationName() as String, object: self)
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
    
    func getUpdateNotificationName() -> NSString {
        return "Alert Page Update"
    }
    
    func getErrorNotificationName() -> NSString {
        return "Alert Page Error"
    }
    
    private func getInviteTypeString(type: AlertType) -> NSString {
        if (type == AlertType.GroupInvite) {
            return "group"
        }
        else if (type == AlertType.EventInvite) {
            return "event"
        }
        else {
            return "Invalid AlertType"
        }
    }
    
}