//
//  URLRequest+Json.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation
extension URLRequest {
    func convertToLogJson() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["URL"] = self.url?.absoluteString ?? ""
        jsonDict["Http Method"] = self.httpMethod?.description ?? ""
        jsonDict["Headers"] = self.allHTTPHeaderFields?["Authorization"] ?? ""
        
        if let body = self.httpBody,
           let dataDictionary = try? JSONSerialization.jsonObject(with: body, options: []) {
            jsonDict["Body"] = "\(dataDictionary)"
        }
        return jsonDict
    }
}
