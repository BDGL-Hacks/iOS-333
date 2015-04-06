//
//  Globals.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/5/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation


/* Logs debugging info without NSLog's clutter.      *
 * While string formatting is supported, this method *
 * performs more predictably using the \() version.  */
func PULog(format: NSString, args: AnyObject...) {
    println(NSString(format: format, args))
}
