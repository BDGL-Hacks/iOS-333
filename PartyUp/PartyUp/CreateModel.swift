//
//  CreateModel.swift
//  PartyUp
//
//  Created by Graham Turk on 4/6/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation


class CreateModel {
    
    enum QueryType {
        case Batch
        case Search
    }
    
    /* Event data */
    var eventTitle: NSString? = nil
    var eventLocation: NSString? = nil
    var dateTime: NSString? = nil
    var friendsList: [NSString] = [NSString]()
    var eventPrice: NSString? = nil
    var eventPublic: NSString? = nil
    var eventAgeRestrictions: NSString? = nil
    var eventDescription: NSString? = nil
    
    /* Group data */
    var eventIDs: [NSString] = [NSString]()
    var inviteIDs: [NSString] = [NSString]()
    var inviteEmails: [NSString] = [NSString]()
    var groupName: NSString? = nil
    
    // MARK: Event methods
    
    /*-------------------------------------*
    * Event Methods
    *-------------------------------------*/
    
    
    func eventFirstPage (title: NSString, location: NSString, dateTime: NSString, eventPublic: NSString, eventDescription: NSString) {
        eventTitle = title
        eventLocation = location
        self.dateTime = dateTime
        eventPrice = "10000000"
        self.eventPublic = eventPublic
        eventAgeRestrictions = "0"
        self.eventDescription = eventDescription
        
    }
    
    func eventSecondPage(friends: [NSString]) {
        
        friendsList = [NSString]() // reinitialize in case someone goes back to first page
        friendsList = friends
    }
    
    func eventSendToBackend() -> (NSString?, NSString?) {
      
        // Registration successful: Dismiss Registration view and attempt login
        let (backendError: NSString?, eventID: NSString?) = PartyUpBackend.instance.backendEventCreation(eventTitle!, location: eventLocation!, ageRestrictions: eventAgeRestrictions!, isPublic: eventPublic!, price: eventPrice!, inviteList: friendsList, dateTime: dateTime!, description: eventDescription!)
        if (backendError == nil) {
            return (nil, eventID)
        }
        else {
            return ("Event creation failed", nil)
        }
    }
    
    /*-------------------------------------------*/
    
    // MARK: Group methods

    /*-------------------------------------*
     * Group Methods
     *-------------------------------------*/

    func groupFirstPage(inviteIDs: [NSString], groupName: NSString, inviteEmails: [NSString])
    {
        self.inviteIDs = inviteIDs
        self.inviteEmails = inviteEmails
        self.groupName = groupName
    }
    
    func groupSecondPage(eventIDs: [NSString]) {
        self.eventIDs = eventIDs
    }
    
    func getInviteIDs() -> [NSString] {
        return inviteIDs
    }


    func groupSendToBackend() -> NSString?
    {
        // Registration successful: Dismiss Registration view and attempt login
        var backendError: NSString? = PartyUpBackend.instance.backendGroupCreation(groupName!, eventIDs: eventIDs, inviteList: inviteEmails)
        if (backendError == nil)
        {
            return nil
        }
        else {
            return "Group creation failed"
        }
    }

    /*-------------------------------------------*/
    
    /* Call backend function to update group with newly added events */
    func addEventsToGroup(groupID: NSString, eventIDs: [NSString]) -> NSString?
    {
        var backendError: NSString? = PartyUpBackend.instance.backendUpdateGroup(groupID, eventIDs: eventIDs)
        if (backendError == nil) {
            return nil
        }
        else {
            return "Group update failed"
        }
    }
    
    
    func inviteFriendsToEvent(eventID: NSString, userIDs: [NSString]) -> NSString? {
        var backendError: NSString? = PartyUpBackend.instance.backendEventAddFriends(eventID, userIDs: userIDs)
        if backendError == nil {
            return nil
        }
        else {
            return "Add friends to event failed"
        }
    }
    
    func inviteFriendsToGroup(groupID: NSString, userIDs: [NSString]) -> NSString? {
        var backendError: NSString? = PartyUpBackend.instance.backendGroupAddFriends(groupID, userIDs: userIDs)
        if backendError == nil {
            return nil
        }
        else {
            return "Add friends to group failed"
        }
    }
    

    // MARK: Users
    
    /*--------------------------------------------*
     * Users Instance variables and Declarations
     *--------------------------------------------*/
    
    var batchUsersQueryResults: NSArray = NSArray()
    var searchUsersQueryResults: NSArray = NSArray()
    var selectedUsers: NSArray = NSArray()
    var inviteList: NSArray = NSArray()
    
    /*--------------------------------------------*
     * Set methods
     *--------------------------------------------*/
    
    /* Queries the backend and updates the model with new *
    * results. queryType specifies what to query for.    *
    * Returns an error message string if update failed.  */
    func update(queryType: QueryType, search: NSString?) -> NSString?
    {
        if (queryType == QueryType.Batch) {
            PULog("Updating batch users...")
            let (errorMessage: NSString?, queryResults: NSArray?) =
            PartyUpBackend.instance.queryBatch()
            if (errorMessage != nil) {
                PULog("Update Failed: \(errorMessage!)")
                return errorMessage!
            } else {
                PULog("Update Success!")
                batchUsersQueryResults = queryResults!
                return nil
            }
        }
        
        else if (queryType == QueryType.Search)
        {
            PULog("Updating search users...")
            let (errorMessage: NSString?, queryResults: NSArray?) =
            PartyUpBackend.instance.queryUsers(search!)
            if (errorMessage != nil) {
                PULog("Update Failed: \(errorMessage!)")
                return errorMessage!
            } else {
                PULog("Update Success!")
                searchUsersQueryResults = queryResults!
                return nil
            }
        }
        else {
            return "Update failed: Invalid query type"
        }
    }
    
    func setSearchUsersQueryResults(results: NSArray) {
        searchUsersQueryResults = results
    }
    
    func setBatchUsersQueryResults(results: NSArray) {
        batchUsersQueryResults = results
    }
    
    
    func setSelectedUsers(selected: NSArray) {
        selectedUsers = selected
    }

    
    func setInviteList(invited: NSArray) {
        inviteList = invited
    }

    /*--------------------------------------------*
     * Get methods
     *--------------------------------------------*/
    
    func getSearchUsers() -> NSArray {
        var usersToDisplay: NSMutableArray = NSMutableArray()
        for query in searchUsersQueryResults {
            let queryDict = query as! NSDictionary
            var queryID: NSString = "\(DataManager.getUserID(queryDict))"
            var isInQueryList: Bool = false
            for invitee in inviteList {
                let inviteeDict = invitee as! NSDictionary
                var inviteeID: NSString = "\(DataManager.getUserID(inviteeDict))"
                if queryID == inviteeID {
                    isInQueryList = true
                    PULog("ID's are equal")
                    break
                }
            }
            if !isInQueryList {
                usersToDisplay.addObject(query)
            }
        }
        // fix this
        return usersToDisplay as NSArray
        // return searchUsersQueryResults
    }
    
    func getBatchUsers() -> NSArray {
        return batchUsersQueryResults
    }
    
    /* Returns the selected friends from search     *
     * Omits users who have already been added to   *
     * the invite list. Made this design decision   *
     * rather than only displaying uninvited guests *
     * in a query because a query could potentially *
       return thousands of names                    */
    func getSelectedUsers() -> NSArray {
        var usersToAdd: NSMutableArray = NSMutableArray()
        for selected in selectedUsers {
            let selectedDict = selected as! NSDictionary
            var selectedID: NSString = "\(DataManager.getUserID(selectedDict))"
            var isInAddedList: Bool = false
            for invitee in inviteList {
                let inviteeDict = invitee as! NSDictionary
                var inviteeID: NSString = "\(DataManager.getUserID(inviteeDict))"
                if selectedID == inviteeID {
                    isInAddedList = true
                    break
                }
            }
            if !isInAddedList {
                usersToAdd.addObject(selected)
            }
        }
        return usersToAdd as NSArray
    }
    
    func getInvitedList() -> NSArray {
        return inviteList
    }
    
    /*-------------------------------------------*/
    
    
    // MARK: Events
    
    /*--------------------------------------------*
    * Group instance variables and declarations
    *--------------------------------------------*/
    var groupEvents: NSArray = NSArray()
    var ownedQueryResults: NSArray = NSArray()
    var invitedQueryResults: NSArray = NSArray()
    var attendingQueryResults: NSArray = NSArray()
    var findQueryResults: NSArray = NSArray()
    var selectedEvents: NSArray = NSArray()
    var newlyCreatedEvents: NSArray = NSArray()
    
    /*--------------------------------------------*
    * Set methods
    *--------------------------------------------*/
    func setGroupEvents(events: NSArray) {
        groupEvents = events
    }
    
    func setOwnedQueryResults(results: NSArray) {
        ownedQueryResults = results
    }
    
    func setInvitedQueryResults(results: NSArray) {
        invitedQueryResults = results
    }
    
    func setAttendingQueryResults(results: NSArray) {
        attendingQueryResults = results
    }
    
    func setFindQueryResults(results: NSArray) {
        findQueryResults = results
    }
    
    func setSelectedEvents(selected: NSArray) {
        selectedEvents = selected
    }
    
    func updateNewlyCreatedEvents(search: NSString?) -> NSString? {
        PULog("Updating newly created events...")
        let (errorMessage: NSString?, queryResult: NSDictionary?) =
        PartyUpBackend.instance.queryEventSearchByID(search!)
        if (errorMessage != nil) {
            PULog("Update Failed: \(errorMessage!)")
            return errorMessage!
        } else {
            PULog("Update Success!")
            setNewlyCreatedEvents(queryResult!)
            return nil
        }
    }
    
    func setNewlyCreatedEvents(newAddition: NSDictionary) {
        var newEvents: NSMutableArray = NSMutableArray()
        newEvents.addObject(newAddition)
        newlyCreatedEvents = newEvents as NSArray
    }
    
    
    /*--------------------------------------------*
    * Get methods
    *--------------------------------------------*/

    func getGroupEvents() -> NSArray {
        return groupEvents
    }
    
    func getOwnedQueryResults() -> NSArray {
        return getEventsQueryResults(ownedQueryResults)
    }
    
    func getInvitedQueryResults() -> NSArray {
        return getEventsQueryResults(invitedQueryResults)
    }
    
    func getAttendingQueryResults() -> NSArray {
        return getEventsQueryResults(attendingQueryResults)
    }
    
    func getFindQueryResults() -> NSArray {
        return getEventsQueryResults(findQueryResults)
    }
    
    /* Private helper function to cross-reference events to 
     * display with events already added to the events list */
    private func getEventsQueryResults(queryResults: NSArray) -> NSArray {
        var eventsToDisplay: NSMutableArray = NSMutableArray()
        for query in queryResults {
            let queryDict = query as! NSDictionary
            var queryID: NSInteger = DataManager.getEventID(queryDict)
            var isInQueryList: Bool = false
            for event in groupEvents {
                let eventDict = event as! NSDictionary
                var eventID: NSInteger = DataManager.getEventID(eventDict)
                if queryID == eventID {
                    isInQueryList = true
                    PULog("ID's are equal")
                    break
                }
            }
            if !isInQueryList {
                eventsToDisplay.addObject(query)
            }
        }
        // fix this
        return eventsToDisplay as NSArray
    }
    
    func getSelectedEvents() -> NSArray {
        return selectedEvents
    }
    
    func getNewlyCreatedEvents() -> NSArray {
        return newlyCreatedEvents
    }
    
    
    /*--------------------------------------------*
    * Data extraction methods
    *--------------------------------------------*/
    
    class func getUserID(user: NSDictionary) -> NSString {
        var userID: AnyObject? = user["id"]
        return "\(userID)"
        
        // return user["id"] as NSString
    }
    
    class func getUserFirstName(user: NSDictionary) -> NSString {
        return user["first_name"] as! NSString
    }
    
    class func getUserLastName(user: NSDictionary) -> NSString {
        return user["last_name"] as! NSString
    }
    
    class func getUserEmail(user: NSDictionary) -> NSString {
        return user["username"] as! NSString // email?
    }
}