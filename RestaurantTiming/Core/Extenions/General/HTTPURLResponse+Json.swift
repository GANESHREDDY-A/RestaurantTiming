//
//  HTTPURLResponse+Json.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation

extension HTTPURLResponse {
    func convertToLogJson() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["StatusCode"] = self.statusCode
        return jsonDict
    }
}
