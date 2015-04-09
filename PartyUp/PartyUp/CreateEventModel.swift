//
//  CreateEventModel.swift
//  PartyUp
//
//  Created by Graham Turk on 4/6/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation


class CreateEventModel {
    
    var eventTitle: NSString?
    var eventLocation: NSString?
    var dateTime: NSString?
    var friendsList: [NSString] = [NSString]()
    var eventPrice: NSString?
    var eventPublic: NSString?
    var eventAgeRestrictions: NSString?
    
    init () {
        eventTitle = nil
        eventLocation = nil
        dateTime = nil
        eventPrice = nil
        eventPublic = nil
        eventAgeRestrictions = nil
    }
    
    func firstPage (title: NSString, location: NSString, dateTime: NSString) {
        eventTitle = title
        eventLocation = location
        self.dateTime = dateTime
    }
    
    func secondPage (friends: [NSString]) {
        
        friendsList = [NSString]() // reinitialize in case someone goes back to first page
        for friend in friends {
            friendsList.append(friend)
        }
    }
    
    func sendToBackend() -> NSString? {
      
        // Registration successful: Dismiss Registration view and attempt login
        var backendError: NSString? = PartyUpBackend.instance.backendEventCreation(eventTitle!, location: eventLocation!, ageRestrictions: eventAgeRestrictions!, isPublic: eventPublic!, price: eventPrice!, inviteList: friendsList)
        if (backendError == nil)
        {
            return nil
        }
        else {
            return "Event creation failed"
        }
    }
    
    
    
}