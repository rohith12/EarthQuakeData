//
//  EarthQuakeViewController.swift
//  EarthQuakeDetails
//
//  Created by Rohith Raju on 4/1/21.
//  Copyright © 2021 Rohith Raju. All rights reserved.
//

import UIKit
import CoreData

class EarthQuakeViewController: UIViewController {
    private let serviceHelper = ServiceHelper.shared
    @IBOutlet weak var earthQuakeTableview: UITableView!
    private var earthQuakes: [EarthQuake] = []
    private var managedObjectContext: NSManagedObjectContext?
    private var displayURL = ""
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupInitialData()
    }
    
    private func setupInitialData() {
        if let appDeleage = UIApplication.shared.delegate as? AppDelegate {
            managedObjectContext = appDeleage.persistentContainer.viewContext
        }
        showHideLoadingView(hide: false)
        retriveDataForEarthQuake()
    }
    
    private func setupUI() {
        earthQuakeTableview.register(UINib(nibName: "EarthQuakeCell", bundle: nil), forCellReuseIdentifier: "earthCell")
    }
    
    private func showAlertView(message: Error) {
        let alert = UIAlertController(title: "Error", message: message.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayDetails"
        {
            if let destinationVC = segue.destination as? DetailsViewController {
                destinationVC.urlString = displayURL
            }
        }
    }
    
    private func showHideLoadingView(hide: Bool) {
        self.loadingView.isHidden = hide
        (hide == true) ? self.activityIndicator.stopAnimating() : self.activityIndicator.startAnimating()
    }
}

extension EarthQuakeViewController {
    //MARK: DataSource manager methods
    private func retriveDataForEarthQuake() {
        serviceHelper.requestForEarthQuakeData { [weak self] (result) in
            guard let weakSelf = self else {
                return
            }
            switch result {
            case .success(let model):
                weakSelf.convertToModel(model: model)
            case .failure(let error):
                switch true {
                case (error as NSError).code == NSURLErrorNotConnectedToInternet:
                    weakSelf.retrieveCoreDataModel()
                default:
                    DispatchQueue.main.async {
                        weakSelf.showHideLoadingView(hide: true)
                        weakSelf.showAlertView(message: error)
                    }
                }
            }
        }
    }
    
    private func convertToModel(model: EarthQuakeResponse) {
        if let features = model.features {
            for feature in features {
                if let title = feature.properties?.title, let place = feature.properties?.place, let urlString = feature.properties?.url, let mag = feature.properties?.mag {
                    let earthQuake = EarthQuake(place: place, name: title, urlString: urlString, mag: mag)
                    updateCoreDataTable(title: title, place: place, mag: mag, url: urlString, id: feature.id)
                    earthQuakes.append(earthQuake)
                }
            }
            DispatchQueue.main.async {
                self.earthQuakeTableview.reloadData()
                self.showHideLoadingView(hide: true)
            }
        }
    }
    
}

extension EarthQuakeViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: TabelView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return earthQuakes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = earthQuakeTableview.dequeueReusableCell(withIdentifier: "earthCell", for: indexPath) as? EarthQuakeCell  else {
            return UITableViewCell()
        }
        let quakeModel = earthQuakes[indexPath.row]
        cell.setupCell(quakeModel: quakeModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = earthQuakes[indexPath.row]
        displayURL = model.urlString
        self.performSegue(withIdentifier: "displayDetails", sender: self)
    }
}

extension EarthQuakeViewController {
    //MARK: Core Data Helpers
    func saveToCoreDataModel(title: String, place: String, mag: Double, url: String, id: String) {
        if let context = managedObjectContext {
            guard let entityDesc = NSEntityDescription.entity(forEntityName: "EarthQuakeEntity", in: context) else { return }
            let earthQuakeModel = NSManagedObject(entity: entityDesc, insertInto: context)
            earthQuakeModel.setValue(id, forKey: "id")
            earthQuakeModel.setValue(title, forKey: "name")
            earthQuakeModel.setValue(place, forKey: "place")
            earthQuakeModel.setValue(url, forKey: "url")
            earthQuakeModel.setValue(mag, forKey: "mag")
            earthQuakeModel.setValue(serviceHelper.getCurrentDate(), forKey: "updateDate")
            do {
                try context.save()
                print("saved \(earthQuakeModel)")
            } catch {
                print("save error")
            }
        }
    }
    
    
    func retrieveCoreDataModel()  {
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
                DispatchQueue.main.async {
                    self.earthQuakeTableview.reloadData()
                    self.showHideLoadingView(hide: true)
                }
            } catch {
                print("fetch error")
            }
        }
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
