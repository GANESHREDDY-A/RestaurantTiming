//
//  File.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation

protocol LocationRepositoryProtocol {
    func getLocationData(completion: @escaping Result<LocationData>)
}
