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
    private let coreDataHelper = CoredataHelper.shared
    @IBOutlet weak var earthQuakeTableview: UITableView!
    private var earthQuakes: [EarthQuake] = []
    private var managedObjectContext: NSManagedObjectContext?
    private var displayURL = ""
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var vmEarthQuake: EarthQuakeViewModel = {
        return  EarthQuakeViewModel(service: self.serviceHelper, coredata: self.coreDataHelper)
    }()
    
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
        vmEarthQuake.tableViewReloadVMClosure = {[weak self] in
            DispatchQueue.main.async {
                self?.earthQuakeTableview.reloadData()
                self?.showHideLoadingView(hide: true)
            }
        }
        
        vmEarthQuake.fetchErrorData = {(error: ServiceError) in
            switch error {
            case .urlNotFound, .decodingError:
                DispatchQueue.main.async {
                    self.showHideLoadingView(hide: true)
                    self.showAlertView(message: error)
                }
            case .networkRequestFailed:
               DispatchQueue.main.async {
                   self.showHideLoadingView(hide: true)
                   self.showAlertView(message: error)
               }
            }
        }
        vmEarthQuake.getEarthQuakeDetails()
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

extension EarthQuakeViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: TabelView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vmEarthQuake.earthQuakes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = earthQuakeTableview.dequeueReusableCell(withIdentifier: "earthCell", for: indexPath) as? EarthQuakeCell  else {
            return UITableViewCell()
        }
        let quakeModel =  vmEarthQuake.earthQuakes[indexPath.row]
        cell.setupCell(quakeModel: quakeModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = vmEarthQuake.earthQuakes[indexPath.row]
        displayURL = model.urlString
        self.performSegue(withIdentifier: "displayDetails", sender: self)
    }
}
