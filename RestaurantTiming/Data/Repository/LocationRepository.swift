//
//  LocationRepository.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation

struct LocationRepository: LocationRepositoryProtocol {
    
    private let httpClient: HttpClient
    
    init(httpClient: HttpClient = HttpClient()) {
        self.httpClient = httpClient
    }
    
    func getLocationData(completion: @escaping Result<LocationData>) {
        return httpClient.get(type: LocationData.self,
                              endpoint: LocationEndpoint.location,
                              completion: { (location, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let location = location else {
                DispatchQueue.main.async {
                    completion(.failure(AppError.emptyData))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(location))
            }
            return
        })
    }
}

