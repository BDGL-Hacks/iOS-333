//
//  Globals.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/5/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation


/*--------------------------------------------*
 * OBJECTS
 *--------------------------------------------*/

private let _dateFormatter = NSDateFormatter()


/*--------------------------------------------*
 * METHODS
 *--------------------------------------------*/

/* Logs debugging info without NSLog's clutter.      *
 * While string formatting is supported, this method *
 * performs more predictably using the \() version.  */
func PULog(format: NSString, args: AnyObject...) {
    println(NSString(format: format, args))
}


/*--------------------------------------------*
 * EXTENSIONS
 *--------------------------------------------*/

extension NSDate
{
    convenience init(dateString:String) {
        _dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        _dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date = _dateFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:date!)
    }
}
