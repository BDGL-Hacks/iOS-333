//
//  DataManager.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/12/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation

class DataManager {
    
   /* This is a helper class intended to aid and standardize *
    * the extraction of information from queried JSON data.  *
    * Most methods accept an NSDictionary (or an NSArray of  *
    * them) representing an event, group, etc. and return    *
    * some content of them in an easily managable format.    */
    
    
   /*--------------------------------------------*
    * Event data extraction methods
    *--------------------------------------------*/
    
    /*
    Event JSON Object:
    {
        description
        price
        location_name
        title
        admin {
            <User>
        }
        age_restrictions
        invite_list [
            <User>
        ]
        time: "YYYY-MM-DD hh:mm:ss+<timezone?>"
        date_created
        public: bool
    }
    */
    
    class func getEventTitle(event: NSDictionary) -> NSString {
        return event["title"] as NSString
    }
    
    class func getEventDescription(event: NSDictionary) -> NSString {
        return event["description"] as NSString
    }
    
    class func getEventLocationName(event: NSDictionary) -> NSString {
        return event["location_name"] as NSString
    }
    
    /* Returns event's date in format: YYYY-MM-DD */
    class func getEventDate(event: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = event["time"] as NSString
        return extractDate(dateTimeRaw)
    }
    
    /* Returns the day of the event in text format (e.g. "Fri") */
    class func getEventDayText(event: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = event["time"] as NSString
        return extractDayText(dateTimeRaw)
    }
    
    /* Returns the day of the event in number format (e.g. "01") */
    class func getEventDayNumber(event: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = event["time"] as NSString
        return extractDayNumber(dateTimeRaw)
    }
    
    /* Returns the event's start time: (h)h:mm [am or pm] */
    class func getEventStartTime(event: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = event["time"] as NSString
        return extractTime(dateTimeRaw)
    }
    
    class func getEventPrice(event: NSDictionary) -> NSInteger? {
        return event["price"] as NSInteger?
    }
    
    class func getEventAgeRestriction(event: NSDictionary) -> NSInteger? {
        return event["age_restrictions"] as NSInteger?
    }
    
    class func getEventInviteList(event: NSDictionary) -> NSArray {
        return event["invite_list"] as NSArray
    }
    
    // TODO: ACTUALLY WRITE THESE METHODS!!!
    //---------------------------------------------------------------
    class func getEventAttendees(event: NSDictionary) -> NSArray {
        return event["invite_list"] as NSArray
    }
    
    /* Returns the name of the group the user is attending the event with */
    class func getEventGroup(event: NSDictionary) -> NSString? {
        return "Not implemented yet! :p"
    }
    //---------------------------------------------------------------
    
    
   /*--------------------------------------------*
    * Group data extraction methods
    *--------------------------------------------*/
    
    
    
   /*--------------------------------------------*
    * User data extraction methods
    *--------------------------------------------*/
    
    /*
    User JSON Object:
    {
        id
        username
        first_name
        last_name
    }
    */
    
    class func getUserFirstName(user: NSDictionary) -> NSString {
        return user["first_name"] as NSString
    }
    
    class func getUserLastName(user: NSDictionary) -> NSString {
        return user["last_name"] as NSString
    }
    
    class func getUserFullName(user: NSDictionary) -> NSString {
        return "\(getUserFirstName(user)) \(getUserLastName(user))"
    }
    
    class func getUserUsername(user: NSDictionary) -> NSString {
        return user["username"] as NSString
    }
    
    class func getUserID(user: NSDictionary) -> NSInteger {
        return user["id"] as NSInteger
    }
    
    
   /*--------------------------------------------*
    * Private formatting methods
    *--------------------------------------------*/
    
    // TODO: ACTUALLY WRITE THESE METHODS!!!
    //---------------------------------------------------------------
    
    /* Accepts a raw datetime string and returns the date (ex: July 4th, 2012) */
    private class func extractDate(dateTimeRaw: NSString) -> NSString {
        return dateTimeRaw.substringToIndex(10)
    }
    
    /* Accepts a raw datetime string and returns the day text (ex: "Fri") */
    private class func extractDayText(dateTimeRaw: NSString) -> NSString {
        return "Fri"
    }
    
    /* Accepts a raw datetime string and returns the day text (ex: "01") */
    private class func extractDayNumber(dateTimeRaw: NSString) -> NSString {
        return "00"
    }
    
    /* Accepts a raw datetime string and returns the time (ex: 9:05 pm) */
    private class func extractTime(dateTimeRaw: NSString) -> NSString {
        return dateTimeRaw.substringWithRange(NSRange(11...15))
    }
    //---------------------------------------------------------------
    
}