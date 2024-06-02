//
//  BaseAPIEndpoint.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation

protocol BaseAPIEndpoint {
    var host: String? { get }
    var basePath: String { get }
    var httpMethod: HttpMethod { get }
    var path: String { get }
    var headers: [String: Any]? { get }
    var payload: Codable? { get }
    var queryParameters: [URLQueryItem]? { get }
}

extension BaseAPIEndpoint {

    var httpMethod: HttpMethod {
        return .get
    }

    var payload: Codable? {
        return nil
    }

    var scheme: String {
        return "https"
    }

    // host or base url
    var host: String? {
        return APIConstants.apiHost
    }

    var basePath: String {
        APIConstants.apiPath ?? ""
    }

    var url: URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = basePath + path
        components.queryItems = queryParameters

        guard let url = components.url else {
            preconditionFailure("Invalid Componenets \(components)")
        }
        return url
    }

    var headers: [String: Any]? {
        return nil
    }

    var queryParameters: [URLQueryItem]? {
        return nil
    }
}
