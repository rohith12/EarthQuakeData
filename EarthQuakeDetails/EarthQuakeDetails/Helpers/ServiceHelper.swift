//
//  ServiceHelper.swift
//  EarthQuakeDetails
//
//  Created by Rohith Raju on 4/2/21.
//  Copyright © 2021 Rohith Raju. All rights reserved.
//

import Foundation

class ServiceHelper {
    static let shared = ServiceHelper()
    let baseURL = "https://earthquake.usgs.gov/fdsnws/event/1/query"
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func requestForEarthQuakeData( success: @escaping (EarthQuakeResponse) -> Void, failure: @escaping (Error) -> Void ) {
        if var baseURL = URLComponents(string: baseURL) {
            baseURL.query = "format=geojson&starttime=\(getCurrentDate())"
            guard let url = baseURL.url else {
                return
            }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                if let error = error {
                    failure(error)
                } else if let earthQuakedata = data, let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do {
                        let earthQuake = try JSONDecoder().decode(EarthQuakeResponse.self, from: earthQuakedata)
                        success(earthQuake)
                    } catch {
                        failure(error)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

