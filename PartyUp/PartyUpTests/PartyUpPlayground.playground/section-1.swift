// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

/* Returns whether the string matches the regex */
func stringMatchesRegex(string: NSString, regex: NSString, caseInsensitive: Bool = false) -> Bool
{
    var regexOptions: NSRegularExpressionOptions
    if caseInsensitive {
        regexOptions = nil
    } else {
        regexOptions = .CaseInsensitive
    }
    var error: NSError?
    
    let regularExpression: NSRegularExpression = NSRegularExpression(pattern: regex, options: regexOptions, error: &error)!
    let numMatches: Int = regularExpression.numberOfMatchesInString(string, options: nil, range: NSMakeRange(0, string.length))
    
    return numMatches > 0
}

stringMatchesRegex("anceë.", "\\A\\p{L}+\\z")
stringMatchesRegex("", "\\A\\z")