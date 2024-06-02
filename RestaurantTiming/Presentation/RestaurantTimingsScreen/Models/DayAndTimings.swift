//
//  DayAndTimings.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation
// MARK: - DayandTimings
struct DayAndTimings: Codable {
    var dayOfWeek, startLocalTime, endLocalTime: String

    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case startLocalTime = "start_local_time"
        case endLocalTime = "end_local_time"
    }
    mutating func updateEndLocalTime(_ time: String) {
        self.endLocalTime = time
    }
}


struct DayTimings: Codable, Identifiable {
    var id: String {
        dayOfWeek
    }
    var weekDay:Int {
        return dayOfWeek.getDayOfWeekIndex()
    }
    let dayOfWeek:String
    var time: [String]

    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case time = "time"
    }
}


