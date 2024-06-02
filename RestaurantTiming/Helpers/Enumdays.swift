//
//  Enumdays.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation

enum EnumDays: Int, CustomStringConvertible {
    case SUNDAY = 1
    case MONDAY = 2
    case TUESDAY = 3
    case WEDNESDAY = 4
    case THURSDAY = 5
    case FRIDAY = 6
    case SATURDAY = 7
    
    var description: String {
        switch self {
        case .MONDAY:
            return "Monday"
        case .TUESDAY:
            return "Tuesday"
        case .WEDNESDAY:
            return "Wednesday"
        case .THURSDAY:
            return "Thursday"
        case .FRIDAY:
            return "Friday"
        case .SATURDAY:
            return "Saturday"
        case .SUNDAY:
            return "Sunday"
        }
    }
    
    var shortName: String {
        switch self {
        case .MONDAY:
            return "MON"
        case .TUESDAY:
            return "TUE"
        case .WEDNESDAY:
            return "WED"
        case .THURSDAY:
            return "THU"
        case .FRIDAY:
            return "FRI"
        case .SATURDAY:
            return "SAT"
        case .SUNDAY:
            return "SUN"
        }
    }
    
    var nextDay: Self {
        switch self {
        case .MONDAY:
            return .TUESDAY
        case .TUESDAY:
            return .WEDNESDAY
        case .WEDNESDAY:
            return .THURSDAY
        case .THURSDAY:
            return .FRIDAY
        case .FRIDAY:
            return .SUNDAY
        case .SATURDAY:
            return .SUNDAY
        case .SUNDAY:
            return .MONDAY
        }
    }
    
    var previousDay: Self {
        switch self {
        case .MONDAY:
            return .SUNDAY
        case .TUESDAY:
            return .MONDAY
        case .WEDNESDAY:
            return .TUESDAY
        case .THURSDAY:
            return .WEDNESDAY
        case .FRIDAY:
            return .THURSDAY
        case .SATURDAY:
            return .FRIDAY
        case .SUNDAY:
            return .SATURDAY
        }
    }
}


