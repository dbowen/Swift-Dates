//
//  SwiftDates.swift
//
//  Created by Derek Bowen on 6/4/14.
//  Copyright (c) 2014 Derek Bowen. All rights reserved.
//

import Foundation

extension Int {
    var years: NSDateComponents {
        let components = NSDateComponents()
            components.year = self
            return components
    }
    
    var months: NSDateComponents {
        let components = NSDateComponents()
            components.month = self
            return components
    }
    
    var weeks: NSDateComponents {
        let components = NSDateComponents()
            components.day = 7 * self
            return components
    }
    
    var days: NSDateComponents {
        let components = NSDateComponents()
            components.day = self
            return components
    }
    
    var hours: NSDateComponents {
        let components = NSDateComponents()
            components.hour = self
            return components
    }
    
    var minutes: NSDateComponents {
        let components = NSDateComponents()
            components.minute = self
            return components
    }
    
    var seconds: NSDateComponents {
        let components = NSDateComponents()
            components.second = self
            return components
    }
}

extension NSDateComponents {
    var ago: NSDate {
        let calendar = NSCalendar.currentCalendar()
            return calendar.dateByAddingComponents(-self, toDate: NSDate.date(), options: nil)
    }
    
    var fromNow: NSDate {
        let calendar = NSCalendar.currentCalendar()
            return calendar.dateByAddingComponents(self, toDate: NSDate.date(), options: nil)
    }
}

prefix operator - {}
prefix func - (components: NSDateComponents) -> NSDateComponents {
    let result = NSDateComponents()
    if components.year != Int(NSUndefinedDateComponent) { result.year = -components.year }
    if components.month != Int(NSUndefinedDateComponent) { result.month = -components.month }
    if components.day != Int(NSUndefinedDateComponent) { result.day = -components.day }
    if components.hour != Int(NSUndefinedDateComponent) { result.hour = -components.hour }
    if components.minute != Int(NSUndefinedDateComponent) { result.minute = -components.minute }
    if components.second != Int(NSUndefinedDateComponent) { result.second = -components.second }
    return result
}

func combineComponents(left: NSDateComponents, right: NSDateComponents, subtract: Bool) -> NSDateComponents {
    let realRight = (subtract) ? -right : right
    
    let result = NSDateComponents()
    result.year = ((left.year != Int(NSUndefinedDateComponent)) ? left.year : 0) + ((realRight.year != Int(NSUndefinedDateComponent)) ? realRight.year : 0)
    result.month = ((left.month != Int(NSUndefinedDateComponent)) ? left.month : 0) + ((realRight.month != Int(NSUndefinedDateComponent)) ? realRight.month : 0)
    result.day = ((left.day != Int(NSUndefinedDateComponent)) ? left.day : 0) + ((realRight.day != Int(NSUndefinedDateComponent)) ? realRight.day : 0)
    result.hour = ((left.hour != Int(NSUndefinedDateComponent)) ? left.hour : 0) + ((realRight.hour != Int(NSUndefinedDateComponent)) ? realRight.hour : 0)
    result.minute = ((left.minute != Int(NSUndefinedDateComponent)) ? left.minute : 0) + ((realRight.minute != Int(NSUndefinedDateComponent)) ? realRight.minute : 0)
    result.second = ((left.year != Int(NSUndefinedDateComponent)) ? left.second : 0) + ((realRight.second != Int(NSUndefinedDateComponent)) ? realRight.second : 0)
    
    return result
}

infix operator - {}
func - (left: NSDateComponents, right: NSDateComponents) -> NSDateComponents {
    return combineComponents(left, right, true)
}

infix operator + {}
func + (left: NSDateComponents, right: NSDateComponents) -> NSDateComponents {
    return combineComponents(left, right, false)
}

extension NSDate {
    // MARK: Date Comparisons
    
    func isEqualToDateIgnoringTime(date: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let selfComponents = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: self)
        let otherComponents = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: date)
        
        return selfComponents == otherComponents
    }
    
    func isToday() -> Bool {
        return self.isEqualToDateIgnoringTime(NSDate.date())
    }
    
    func isYesterday() -> Bool {
        return self.isEqualToDateIgnoringTime(1.days.ago)
    }
    
    func isTomorrow() -> Bool {
        return self.isEqualToDateIgnoringTime(1.days.fromNow)
    }
    
    
    // MARK: Words
    
    func distanceOfTimeInWordsToNow() -> String {
        return distanceOfTimeInWordsFromDate(NSDate.date())
    }
    
    func distanceOfTimeInWordsFromDate(fromDate: NSDate) -> String {
        let distanceInSeconds: Int = Int(abs(self.timeIntervalSince1970 - fromDate.timeIntervalSince1970))
        let distanceInMinutes: Int = Int(round(Double(distanceInSeconds) / 60.0))
        
        switch distanceInMinutes {
        case 0...1:
            switch distanceInSeconds {
            case 0...4:
                return "less than 5 seconds"
            case 5...9:
                return "less than 10 seconds"
            case 10...19:
                return "less than 20 seconds"
            case 20...39:
                return "less than 40 seconds"
            case 40...59:
                return "less than 1 minute"
            default:
                return "1 minute"
            }
        case 2...45:
            return "\(distanceInMinutes) minutes"
        case 45...90:
            return "about 1 hour"
            // 90 mins up to 24 hours
        case 90...1440:
            return "about \(Int(round(Double(distanceInMinutes) / 60.0))) hours"
            // 24 hours up to 42 hours
        case 1440...2520:
            return "1 day"
            // 42 hours up to 30 days
        case 2520...43200:
            return "\(Int(round(Double(distanceInMinutes) / 1440.0))) days"
            // 30 days up to 60 days
        case 43200...86400:
            return "about \(Int(round(Double(distanceInMinutes) / 43200.0))) months"
            // 60 days up to 365 days
        case 86400...525600:
            return "\(Int(round(Double(distanceInMinutes) / 43200.0))) months"
        default:
            let remainder: Int = distanceInMinutes % 525600
            let distanceInYears: Int = distanceInMinutes / 525600
            let yearSuffix = (distanceInYears == 1) ? "" : "s"
            
            if remainder < 131400 {
                return "about \(distanceInYears) year\(yearSuffix)"
            }
            else if remainder < 394200 {
                return "over \(distanceInYears) year\(yearSuffix)"
            }
            else {
                return "almost \(distanceInYears + 1) year\(yearSuffix)"
            }
        }
    }
}