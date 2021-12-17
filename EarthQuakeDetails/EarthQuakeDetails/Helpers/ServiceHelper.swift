//
//  ServiceHelper.swift
//  EarthQuakeDetails
//
//  Created by Rohith Raju on 4/2/21.
//  Copyright © 2021 Rohith Raju. All rights reserved.
//

import Foundation

protocol ServiceProtocol {
    func requestForEarthQuakeData( handler: @escaping (Result<EarthQuakeResponse, ServiceError>) -> Void)
}

enum ServiceError: Error {
    case urlNotFound
    case decodingError
    case networkRequestFailed
}

class ServiceHelper: ServiceProtocol {
    static let shared = ServiceHelper()
    let baseURL = "https://earthquake.usgs.gov/fdsnws/event/1/query"
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    let helper = Helpers()

    func requestForEarthQuakeData( handler: @escaping (Result<EarthQuakeResponse, ServiceError>) -> Void) {
        if var baseURL = URLComponents(string: baseURL) {
            baseURL.query = "format=geojson&starttime=\(helper.getCurrentDate())"
            guard let url = baseURL.url else {
                handler(.failure(.urlNotFound))
                return
            }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("error: decoding: \(error)")
                    handler(.failure(.networkRequestFailed))
                } else if let earthQuakedata = data, let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do {
                        let earthQuake = try JSONDecoder().decode(EarthQuakeResponse.self, from: earthQuakedata)
                        handler(.success(earthQuake))
                    } catch {
                        print("error: decoding: \(error)")
                        handler(.failure(.decodingError))
                    }
                }
            }
            dataTask?.resume()
        }
    }
}
