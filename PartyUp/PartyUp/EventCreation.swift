//
//  EventCreation.swift
//  PartyUp
//
//  Created by Graham Turk on 4/6/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation


class EventCreation {
    
    var eventFields: [NSString]
    
    init ()
    {
        eventFields = []
    }
    
    func firstPage (title: NSString, location: NSString, dateTime: NSString) {
        eventFields.append(title)
        eventFields.append(location)
        eventFields.append(dateTime)
    }
    
    
    
}