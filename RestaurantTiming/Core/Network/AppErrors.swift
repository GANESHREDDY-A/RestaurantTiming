//
//  AppErrors.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation

enum AppError: Error, Equatable {
    case invalidBody
    case invalidEndpoint
    case invalidURL
    case emptyData
    case successWithEmptyData
    case unableToDecodeRequestJSON
    case unableToDecodeResponseJSON
    case invalidResponse
    case statusCode(Int)
    case serverError(String, Int?)
    case noInternetConnecttion
    case uploadMediaToS3Failed
    case downloadMediaToS3Failed
    case deleteMediaFromS3Failed
    case invalidInput
}

extension AppError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .invalidBody:
            return "Inavld Data"
        case .invalidURL:
            return "Unable to reach network"
        case .serverError(let message, _):
            return message
        case .unableToDecodeResponseJSON:
            return "Unable to decode response"
        case .uploadMediaToS3Failed:
            return "Unable to upload media to s3"
        case .invalidInput:
            return "Invalid Input submiitted"
        default:
            return "Unknown error"
        }
    }
    
    var statusCode: Int? {
        switch self {
        case .serverError(_, let statusCode):
            return statusCode
        default:
            return nil
        }
    }
}

