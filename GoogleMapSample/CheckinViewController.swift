//
//  CheckinViewController.swift
//  GoogleMapSample
//
//  Created by Masuhara on 2017/09/15.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker

class CheckinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSAutocompleteResultsViewControllerDelegate {
    
    var newPlace = Place.shared
    
    var locationManager: CLLocationManager!
    
    var placesClient: GMSPlacesClient!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    
    var searchController: UISearchController?
    
    var resultView: UITextView?
    
    @IBOutlet var inputTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTableView.dataSource = self
        inputTableView.delegate = self
        
        inputTableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "InputTableViewCell", bundle: Bundle.main)
        inputTableView.register(nib, forCellReuseIdentifier: "InputCell")
        
        setUpSearchController()
        
        placesClient = GMSPlacesClient.shared()
        
        loadCurrentLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newPlace.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell") as! InputTableViewCell
        cell.titleLabel.text = newPlace.titles[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.inputLabel.text = newPlace.name ?? "未設定"
        case 1:
            cell.inputLabel.text = newPlace.station ?? "未設定"
        case 2:
            cell.inputLabel.text = newPlace.line ?? "未設定"
        case 3:
            cell.inputLabel.text = newPlace.direction ?? "未設定"
        case 4:
            cell.inputLabel.text = newPlace.exit ?? "未設定"
        case 5:
            cell.inputLabel.text = newPlace.trainNumber ?? "未設定"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            searchController?.searchBar.becomeFirstResponder()
        case 1:
            print("")
        case 2:
            print("")
        case 3:
            print("")
        case 4:
            print("")
        case 5:
            print("")
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - GMSAutocompleteResultsViewControllerDelegate
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        newPlace.name = place.name
        inputTableView.reloadData()
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    // MARK: - Private
    func loadCurrentLocation() {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print(error.code)
                switch error.code {
                case -11:
                    self.locationManager = CLLocationManager()
                    self.locationManager.requestAlwaysAuthorization()
                default :
                    print(error.localizedDescription)
                    break
                }
                return
            } else {
                if let placeLikelihoodList = placeLikelihoodList {
                    
                    let place = placeLikelihoodList.likelihoods.first?.place
                    if let place = place {
                        print(place.name)
                        print(place.formattedAddress!.components(separatedBy: ", ")
                            .joined(separator: "\n"))
                        
                    }
                }
            }
        })
    }
    
    func setUpSearchController() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
    }
}
