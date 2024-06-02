//
//  HttpMethod.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation

enum HttpMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

enum HttpResponseStatusCodes: Int {
    case internalServerError = 500
    case gatewayTimeout = 504
    case serviceUnavailable = 503
}
