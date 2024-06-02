//
//  LocationEndpoint.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation

enum LocationEndpoint: BaseAPIEndpoint {
    case location

    var path: String {
        switch self {
        case .location:
            return "\(APIConstants.locationEndPoint)"
        }
    }

    var headers: [String: Any]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
