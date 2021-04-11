//
//  EarthQuakeCell.swift
//  EarthQuakeDetails
//
//  Created by Rohith Raju on 4/3/21.
//  Copyright © 2021 Rohith Raju. All rights reserved.
//

import UIKit

class EarthQuakeCell: UITableViewCell {
    @IBOutlet weak var titleEarthQuake: UILabel!
    @IBOutlet weak var magEarthQuake: UILabel!
    @IBOutlet weak var placeEarthQuake: UILabel!
    
    func setupCell(quakeModel: EarthQuake) {
        self.titleEarthQuake.text = "Name: \(quakeModel.name)"
        self.placeEarthQuake.text = "Place: \(quakeModel.place)"
        self.magEarthQuake.text = "Mag: \(quakeModel.mag)"
    }
}
