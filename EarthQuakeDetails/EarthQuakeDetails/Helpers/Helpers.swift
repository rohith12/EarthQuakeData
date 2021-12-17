//
//  Helpers.swift
//  EarthQuakeDetails
//
//  Created by Rohith Raju on 12/16/21.
//  Copyright © 2021 Rohith Raju. All rights reserved.
//

import Foundation

class Helpers  {
    
    init() {
        
    }

    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
