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

private let DEBUG_MODE: Bool = false


/*--------------------------------------------*
 * OBJECTS
 *--------------------------------------------*/

private let _dateFormatter: NSDateFormatter = NSDateFormatter()
private let _calendarInstance: NSCalendar = NSCalendar.currentCalendar()


/*--------------------------------------------*
 * METHODS
 *--------------------------------------------*/

/* Logs debugging info without NSLog's clutter.      *
 * While string formatting is supported, this method *
 * performs more predictably using the \() version.  */
func PULog(format: NSString, args: AnyObject...) {
    if (DEBUG_MODE) {
        println(NSString(format: format, args))
    }
}

/* Returns the date formatter */
func getDateFormatter() -> NSDateFormatter {
    return _dateFormatter
}

/* Returns the current calendar */
func getCalendar() -> NSCalendar {
    return _calendarInstance
}

/* Convert a color in hex to a UIColor */
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}


/*--------------------------------------------*
 * EXTENSIONS
 *--------------------------------------------*/

extension NSDate
{
    convenience init(dateString:String) {
        _dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        _dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date: NSDate? = _dateFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate: date!)
    }
}
