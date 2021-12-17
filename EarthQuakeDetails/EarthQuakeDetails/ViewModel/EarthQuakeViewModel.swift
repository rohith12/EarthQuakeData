//
//  EarthQuakeViewModel.swift
//  EarthQuakeDetails
//
//  Created by Rohith Raju on 11/4/21.
//  Copyright © 2021 Rohith Raju. All rights reserved.
//

import Foundation

class EarthQuakeViewModel {
    var webService: ServiceHelper
    var coreDataService: CoredataHelper
    
    public var earthQuakes: [EarthQuake] = [] {
        didSet {
            self.tableViewReloadVMClosure?()
        }
    }
    
    var tableViewReloadVMClosure: (() -> Void)?
    var fetchErrorData: ((ServiceError) -> Void)?
    
    init(service: ServiceHelper, coredata: CoredataHelper) {
        webService = service
        coreDataService = coredata
    }
    
    func getEarthQuakeDetails() {
        webService.requestForEarthQuakeData { [weak self] (result) in
            switch result {
            case .success(let model):
                self?.convertToModel(model: model)
            case .failure(let error):
                self?.earthQuakes = self?.coreDataService.retrieveCoreDataModel() ?? []
                self?.fetchErrorData?(error)
            }
        }
    }
    
    private func convertToModel(model: EarthQuakeResponse) {
        var earthQuakeArr: [EarthQuake] = []
        if let features = model.features {
            for feature in features {
                if let title = feature.properties?.title, let place = feature.properties?.place, let urlString = feature.properties?.url, let mag = feature.properties?.mag {
                    let earthQuake = EarthQuake(place: place, name: title, urlString: urlString, mag: mag)
                    coreDataService.updateCoreDataTable(title: title, place: place, mag: mag, url: urlString, id: feature.id)
                    earthQuakeArr.append(earthQuake)
                }
                earthQuakes = earthQuakeArr
            }

        }
    }
}
