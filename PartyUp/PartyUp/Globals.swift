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

extension String {
    
    var length: Int {
        get {
            return count(self)
        }
    }
    
    func indexOf(target: String) -> Int {
        var range = self.rangeOfString(target)
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func indexOf(target: String, startIndex: Int) -> Int {
        var startRange = advance(self.startIndex, startIndex)
        var range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(start: startRange, end: self.endIndex))
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(target: String) -> Int {
        var index = -1
        var stepIndex = self.indexOf(target)
        while stepIndex > -1 {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target, startIndex: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    
    func substringWithRange(range:Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self.substringWithRange(start..<end)
    }
    
}