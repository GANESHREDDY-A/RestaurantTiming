//
//  HttpClient.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Combine
import Foundation

// MARK: ApiResult result & Result Block
enum ApiResult<Value> {
    case success(Value)
    case failure(AppError?)
}
typealias Result<Value> = ((ApiResult<Value>) -> Void)

// MARK: ViewModel result State
enum ResultState<Value> {
    case initalState
    case loading
    case fetchedResult(response: Value)
    case failedToLoad(message: String)
}

extension ResultState: Hashable {
    static func == (lhs: ResultState<Value>, rhs: ResultState<Value>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .initalState: hasher.combine(-1)
        case .loading: hasher.combine(-2)
        case .fetchedResult: hasher.combine(-3)
        case .failedToLoad: hasher.combine(-3)
        }
    }
}

protocol HttpClientProtocol: AnyObject {
    typealias Headers = [String: Any]?
    typealias RequestBody = [String: Any]?
    func getData(url: URL, headers: Headers, completion: @escaping (_ data: Data?, _ error: AppError?) -> Void)
    func get<T>(type: T.Type, endpoint: BaseAPIEndpoint, canWaitForSync: Bool, completion: @escaping ( _ t: T?, _ error: AppError?) -> Void) where T: Decodable
    func post<T>(type: T.Type, endpoint: BaseAPIEndpoint, completion: @escaping ( _ t: T?, _ error: AppError?) -> Void) where T: Decodable
}

final class HttpClient: HttpClientProtocol {
    func getData(url: URL, headers: Headers, completion: @escaping ( _ data: Data?, _ error: AppError?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        if let headers = headers {
            headers.forEach { (key: String, value: Any) in
                if let value = value as? String {
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
        }
        URLSession.shared.dataTask(with: urlRequest) { responseData, response, error in
            completion(responseData, AppError.serverError(error?.localizedDescription ?? "", (response as? HTTPURLResponse)?.statusCode))
        }.resume()
    }

    func get<T>(type: T.Type,
                endpoint: BaseAPIEndpoint,
                canWaitForSync: Bool = false,
                completion: @escaping ( _ t: T?, _ error: AppError?) -> Void) where T: Decodable {
            getDataFromServer(type: type, endpoint: endpoint, completion: completion)
    }

    func getDataFromServer<T>(type: T.Type, endpoint: BaseAPIEndpoint, completion: @escaping ( _ t: T?, _ error: AppError?) -> Void) where T: Decodable {
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.httpMethod = HttpMethod.get.rawValue
        if let headers = endpoint.headers {
            headers.forEach { (key: String, value: Any) in
                if let value = value as? String {
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
        }
      
        URLSession.shared.dataTask(with: urlRequest) { responseData, response, error in
            var responseDict = (response as? HTTPURLResponse)?.convertToLogJson() ?? [:]
            guard let responseData = responseData, !responseData.isEmpty, error == nil else {
                completion(nil, AppError.successWithEmptyData)
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: responseData)
                responseDict["Data"] = String(describing: decodedResponse)
                DispatchQueue.main.async {
                    completion(decodedResponse, nil)
                }
            } catch {
                completion(nil, AppError.unableToDecodeResponseJSON)
            }
        }.resume()
    }
    
    func post<T>(type: T.Type, endpoint: BaseAPIEndpoint,
                 completion: @escaping ( _ t: T?, _ error: AppError?) -> Void) where T: Decodable {
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.httpMethod = HttpMethod.post.rawValue
        if let headers = endpoint.headers {
            headers.forEach { (key: String, value: Any) in
                if let value = value as? String {
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
        }
        if let payload = endpoint.payload {
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(payload)
                urlRequest.httpBody = jsonData
            } catch {
                completion(nil, AppError.unableToDecodeRequestJSON)
            }
        }
        URLSession.shared.dataTask(with: urlRequest) { responseData, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 && endpoint.path != "/Login" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        
                    })
                    return
                } else if httpResponse.statusCode == 500 {
                    do {
                        if let responseData = responseData,
                            let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                            let errorString = json["desc"] as? String ?? AppError.unableToDecodeResponseJSON.errorDescription
                            completion(nil, AppError.serverError(errorString ?? "",
                                                                 httpResponse.statusCode))
                        }
                    } catch {
                        completion(nil, AppError.unableToDecodeResponseJSON)
                    }
                    return

                } else if httpResponse.statusCode == 400 {
                    completion(nil, AppError.invalidInput)
                    return
                }
            }
            let responseDict = (response as? HTTPURLResponse)?.convertToLogJson() ?? [:]

            guard let responseData = responseData, !responseData.isEmpty, error == nil else {
                if let serverError = error {
                    completion(nil, AppError.serverError(serverError.localizedDescription, (response as? HTTPURLResponse)?.statusCode))
                } else if let emptyResponse = EmptyResponseModel() as? T {
                    completion(emptyResponse, nil)
                } else {
                    completion(nil, AppError.successWithEmptyData)
                }
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: responseData)
                completion(decodedResponse, nil)
            } catch let error {
                completion(nil, AppError.unableToDecodeResponseJSON)
            }
        }.resume()
    }

    func postFormData<T>(urlRequest: URLRequest, type: T.Type, endpoint: BaseAPIEndpoint, completion: @escaping ( _ t: T?, _ error: AppError?) -> Void) where T: Decodable {
        var urlRequest = urlRequest
       // urlRequest.httpMethod = HttpMethod.post.rawValue
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        if let headers = endpoint.headers {
            headers.forEach { (key: String, value: Any) in
                if let value = value as? String {
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
        }
        
        URLSession.shared.dataTask(with: urlRequest) { responseData, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            var responseDict = (response as? HTTPURLResponse)?.convertToLogJson() ?? [:]
            guard let responseData = responseData, !responseData.isEmpty, error == nil else {
                if let serverError = error {
                    completion(nil, AppError.serverError(serverError.localizedDescription, statusCode))
                } else if let emptyResponse = EmptyResponseModel() as? T {
                    completion(emptyResponse, nil)
                } else {
                    completion(nil, AppError.successWithEmptyData)
                }
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: responseData)
                responseDict["Data"] = String(describing: decodedResponse)
               
                completion(decodedResponse, nil)
            } catch {
                completion(nil, AppError.unableToDecodeResponseJSON)
            }
        }.resume()
    }

    private func readLocalFile(forName name: String) -> Data? {
        do {
            let bundlePath = Bundle.main.path(forResource: name,
                                              ofType: "json")
            if let bundlePath = bundlePath, let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }

        return nil
    }

    func getFromLocalJSON<T>(type: T.Type, fileName: String, completion: @escaping ( _ t: T?, _ error: AppError?) -> Void) where T: Decodable {
        let responseData = readLocalFile(forName: fileName)
        guard let responseData = responseData else {
            completion(nil, AppError.invalidResponse)
            return
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {

            }
            let decodedResponse = try JSONDecoder().decode(T.self, from: responseData)
            completion(decodedResponse, nil)
        } catch {
            completion(nil, AppError.unableToDecodeResponseJSON)
        }
    }

    func postForTEST<T>(type: T.Type, endpoint: URLRequest, completion: @escaping ( _ t: T?, _ error: AppError?) -> Void) where T: Decodable {
                
        URLSession.shared.dataTask(with: endpoint) { responseData, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            guard let responseData = responseData, error == nil else {
                if let serverError = error {
                    completion(nil, AppError.serverError(serverError.localizedDescription, statusCode))
                } else {
                    completion(nil, AppError.invalidResponse)
                }
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {

                }
                let decodedResponse = try JSONDecoder().decode(T.self, from: responseData)
                completion(decodedResponse, nil)
            } catch {
                completion(nil, AppError.unableToDecodeResponseJSON)
            }
        }.resume()
    }
}

