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
    
    class func getEventID(event: NSDictionary) -> NSInteger {
        return event["id"] as! NSInteger
    }
    
    class func getEventTitle(event: NSDictionary) -> NSString {
        return event["title"] as! NSString
    }
    
    class func getEventDescription(event: NSDictionary) -> NSString {
        if let description = event["description"] as? NSString {
            return description
        }
        return "--"
    }
    
    class func getEventLocationName(event: NSDictionary) -> NSString {
        return event["location_name"] as! NSString
    }
    
    /* Returns whether the current user is an admin of the event */
    class func getEventIsAdmin(event: NSDictionary) -> Bool {
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userID: NSInteger? = userDefaults.integerForKey("USER_ID")
        if (userID == nil) {
            return false
        } else {
            return (DataManager.getUserID(event["admin"] as! NSDictionary) == userID!)
        }
    }
    
    /* Returns event's date in format: YYYY-MM-DD */
    class func getEventDate(event: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = event["time"] as! NSString
        return extractDate(dateTimeRaw)
    }
    
    /* Returns the day of the event in text format (e.g. "Fri") */
    class func getEventDayText(event: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = event["time"] as! NSString
        return extractDayText(dateTimeRaw)
    }
    
    /* Returns the day of the event in number format (e.g. "01") */
    class func getEventDayNumber(event: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = event["time"] as! NSString
        return extractDayNumber(dateTimeRaw)
    }
    
    /* Returns the event's start time: (h)h:mm [am or pm] */
    class func getEventStartTime(event: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = event["time"] as! NSString
        return extractTime(dateTimeRaw)
    }
    
    class func getEventPrice(event: NSDictionary) -> NSInteger? {
        return event["price"] as! NSInteger?
    }
    
    class func getEventAgeRestriction(event: NSDictionary) -> NSInteger? {
        return event["age_restrictions"] as! NSInteger?
    }
    
    class func getEventInviteList(event: NSDictionary) -> NSArray {
        return event["invite_list"] as! NSArray
    }
    
    class func getEventAttendees(event: NSDictionary) -> NSArray {
        return event["attending_list"] as! NSArray
    }
    
    class func getEventPublic(event: NSDictionary) -> Bool {
        if (event["public"] == nil) {
            return false
        }
        let publicTitle = event["public"] as! NSInteger
        if (publicTitle == 1)
        {
            return true
        }
        return false
    }
    
    // Implement this method (if we eventually choose to)!!!
    //---------------------------------------------------------------
    
    /* Returns the name of the group the user is attending the event with */
    class func getEventGroup(event: NSDictionary) -> NSString? {
        return "Not implemented yet! :p"
    }
    //---------------------------------------------------------------
    
    
   /*--------------------------------------------*
    * Group data extraction methods
    *--------------------------------------------*/
    
    /*
    Group JSON Object:
    {
        id
        title
        members {
            <Users>
        }
        events {
            <Sparse Events>
        }
        time: "YYYY-MM-DD hh:mm:ss+<timezone?>"
    }
    */
    
    class func getGroupID(group: NSDictionary) -> NSInteger {
        return group["id"] as! NSInteger
    }
    
    class func getGroupTitle(group: NSDictionary) -> NSString {
        return group["title"] as! NSString
    }
    
    class func getGroupMembers(group: NSDictionary) -> NSArray {
        return group["members"] as! NSArray
    }
    
    class func getGroupSparseEvents(group: NSDictionary) -> NSArray {
        return group["events"] as! NSArray
    }
    
    class func getGroupChannel(group: NSDictionary) -> NSString {
        return "GroupChat\(getGroupID(group))"
    }
    
    /* Returns the day of the group's events in text format (e.g. "Fri") */
    class func getGroupDayText(group: NSDictionary) -> NSString {
        if (group["time"] == nil) {
            return "DELETE THIS CODE"
        }
        let dateTimeRaw: NSString = group["time"] as! NSString
        return extractDayText(dateTimeRaw)
    }
    
    /* Returns the day of the group's events in number format (e.g. "01") */
    class func getGroupDayNumber(group: NSDictionary) -> NSString {
        if (group["time"] == nil) {
            return "DELETE THIS CODE"
        }
        let dateTimeRaw: NSString = group["time"] as! NSString
        return extractDayNumber(dateTimeRaw)
    }
    
    
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
    
    class func getUserID(user: NSDictionary) -> NSInteger {
        if let userID: NSInteger = user["id"] as? NSInteger {
            return userID
        } else {
            let userIDString: NSString = user["id"] as! NSString
            return userIDString.integerValue
        }
    }
    
    class func getUserFirstName(user: NSDictionary) -> NSString {
        return user["first_name"] as! NSString
    }
    
    class func getUserLastName(user: NSDictionary) -> NSString {
        return user["last_name"] as! NSString
    }
    
    class func getUserFullName(user: NSDictionary) -> NSString {
        return "\(getUserFirstName(user)) \(getUserLastName(user))"
    }
    
    class func getUserUsername(user: NSDictionary) -> NSString {
        return user["username"] as! NSString
    }
    
    
   /*--------------------------------------------*
    * Messages data extraction methods
    *--------------------------------------------*/
    
    /*
    Message JSON Object:
    {
        id
        owner <User>
        message
        time: "YYYY-MM-DD hh:mm:ss+<timezone?>"
    }
    */
    
    class func getMessageID(message: NSDictionary) -> NSInteger {
        return message["id"] as! NSInteger
    }
    
    class func getMessageText(message: NSDictionary) -> NSString {
        return message["message"] as! NSString
    }
    
    class func getMessageOwner(message: NSDictionary) -> NSDictionary {
        return message["owner"] as! NSDictionary
    }
    
    class func getMessageOwnerID(message: NSDictionary) -> NSInteger {
        return getUserID(getMessageOwner(message))
    }
    
    class func getMessageOwnerFullName(message: NSDictionary) -> NSString {
        return getUserFullName(getMessageOwner(message))
    }
    
    class func getMessageDateSent(message: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = message["time"] as! NSString
        return extractDate(dateTimeRaw)
    }
    
    class func getMessageTimeSent(message: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = message["time"] as! NSString
        return extractTime(dateTimeRaw)
    }
    
    class func getMessageDatetimeRaw(message: NSDictionary) -> NSString {
        let dateTimeRaw: NSString = message["time"] as! NSString
        return extractDatetime(dateTimeRaw)
    }
   
    
   /*--------------------------------------------*
    * Ping data extraction methods
    *--------------------------------------------*/
    
    /*
    Ping JSON Object:
    {
        user <User>
        group <group>
        response <Bool>
    }
    */
    
    class func getPingTarget(ping: NSDictionary) -> NSDictionary {
        return ping["user"] as! NSDictionary
    }
    
    class func getPingGroup(ping: NSDictionary) -> NSDictionary {
        return ping["group"] as! NSDictionary
    }
    
    class func getPingResponse(ping: NSDictionary) -> Bool {
        return (ping["response"] as! NSString) == "True"
    }
    
    
   /*--------------------------------------------*
    * Private formatting methods
    *--------------------------------------------*/
    
    /* Accepts a raw datetime string and returns the date (ex: July 4th, 2012) */
    private class func extractDate(dateTimeRaw: NSString) -> NSString {
        let date: NSDate = NSDate(dateString: extractDatetime(dateTimeRaw) as String)
        return getFormattedDateString(date, formatString: "MMMM d, y")
    }
    
    /* Accepts a raw datetime string and returns the day text (ex: "Fri") */
    private class func extractDayText(dateTimeRaw: NSString) -> NSString {
        let date: NSDate = NSDate(dateString: extractDatetime(dateTimeRaw) as String)
        return getFormattedDateString(date, formatString: "EEE")
    }
    
    /* Accepts a raw datetime string and returns the day text (ex: "01") */
    private class func extractDayNumber(dateTimeRaw: NSString) -> NSString {
        let date: NSDate = NSDate(dateString: extractDatetime(dateTimeRaw) as String)
        return getFormattedDateString(date, formatString: "dd")
    }
    
    /* Accepts a raw datetime string and returns the time (ex: 9:05 pm) */
    private class func extractTime(dateTimeRaw: NSString) -> NSString {
        let date: NSDate = NSDate(dateString: extractDatetime(dateTimeRaw) as String)
        return getFormattedDateString(date, formatString: "h:mm a")
    }
    
    
   /*--------------------------------------------*
    * Private formatting helper methods
    *--------------------------------------------*/
    
    /* Accepts a raw datetime string and returns a formatted datetime string */
    private class func extractDatetime(dateTimeRaw: NSString) -> NSString {
        return dateTimeRaw.substringToIndex(10) + " " + dateTimeRaw.substringWithRange(NSRange(11...18))
    }
    
    /* Accepts a date and a format string returns the pretty print output */
    private class func getFormattedDateString(date: NSDate, formatString: String) -> NSString {
        let dateFormatter: NSDateFormatter = getDateFormatter()
        dateFormatter.dateFormat = formatString
        return dateFormatter.stringFromDate(date)
    }
    
}