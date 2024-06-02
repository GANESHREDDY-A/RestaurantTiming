//
//  LocationData.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation
// MARK: - LocationData
struct LocationData: Codable {
    let locationName: String
    let hours: [DayAndTimings]

    enum CodingKeys: String, CodingKey {
        case locationName = "location_name"
        case hours
    }
}

