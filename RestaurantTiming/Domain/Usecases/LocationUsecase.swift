//
//  File.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation

struct LocationUsecase {

    let locationRepository: LocationRepositoryProtocol

    init(locationRepository: LocationRepositoryProtocol) {
        self.locationRepository = locationRepository
    }

    func fetchLocationData(completion: @escaping Result<LocationData>) {
            locationRepository.getLocationData(completion: completion)
    }
}

