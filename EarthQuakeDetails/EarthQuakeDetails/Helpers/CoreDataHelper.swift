//
//  CoreDataHelper.swift
//  EarthQuakeDetails
//
//  Created by Rohith Raju on 12/16/21.
//  Copyright © 2021 Rohith Raju. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol CoredataDelegate  {
     func saveToCoreDataModel(title: String, place: String, mag: Double, url: String, id: String)
     func retrieveCoreDataModel() -> [EarthQuake]
     func updateCoreDataTable(title: String, place: String, mag: Double, url: String, id: String)
}

class CoredataHelper: CoredataDelegate {
    private var managedObjectContext: NSManagedObjectContext?
    static let shared = CoredataHelper()
    let helper = Helpers()
    
    init() {
       if let appDeleage = UIApplication.shared.delegate as? AppDelegate {
            managedObjectContext = appDeleage.persistentContainer.viewContext
        }
    }
    
    func saveToCoreDataModel(title: String, place: String, mag: Double, url: String, id: String) {
        if let context = managedObjectContext {
            guard let entityDesc = NSEntityDescription.entity(forEntityName: "EarthQuakeEntity", in: context) else { return }
            let earthQuakeModel = NSManagedObject(entity: entityDesc, insertInto: context)
            earthQuakeModel.setValue(id, forKey: "id")
            earthQuakeModel.setValue(title, forKey: "name")
            earthQuakeModel.setValue(place, forKey: "place")
            earthQuakeModel.setValue(url, forKey: "url")
            earthQuakeModel.setValue(mag, forKey: "mag")
            earthQuakeModel.setValue(helper.getCurrentDate(), forKey: "updateDate")
            do {
                try context.save()
                print("saved \(earthQuakeModel)")
            } catch {
                print("save error")
            }
        }
    }
    
    
    func retrieveCoreDataModel() -> [EarthQuake]  {
        var earthQuakes: [EarthQuake] = []
        if let context = managedObjectContext {
            let fetchRequest = NSFetchRequest<EarthQuakeEntity>(entityName: "EarthQuakeEntity")
            do {
                let coredataModels = try context.fetch(fetchRequest)
                for model in coredataModels {
                    if let name = model.name, let place = model.place, let urlString = model.url  {
                        let earthQuake = EarthQuake(place: place, name: name, urlString: urlString, mag: model.mag)
                        earthQuakes.append(earthQuake)
                    }
                }
                
//                DispatchQueue.main.async {
//                    self.earthQuakeTableview.reloadData()
//                    self.showHideLoadingView(hide: true)
//                }
            } catch {
                print("fetch error")
            }
        }
        return earthQuakes
    }
    
    func updateCoreDataTable(title: String, place: String, mag: Double, url: String, id: String) {
        let fetchRequest = NSFetchRequest<EarthQuakeEntity>(entityName: "EarthQuakeEntity")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        if let context = managedObjectContext {
            do {
                let coredataModels = try context.fetch(fetchRequest)
                if coredataModels.count != 0 {
                    //update
                } else {
                    //Insert new data
                    saveToCoreDataModel(title: title, place: place, mag: mag, url: url, id: id)
                }
            }
            catch {
                print("fetch error")
            }
        }
    }
    
    
}
