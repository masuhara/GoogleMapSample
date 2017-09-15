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
import NCMB
import SVProgressHUD

class CheckinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSAutocompleteResultsViewControllerDelegate {
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        inputTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == "toInput" {
                let inputViewController = segue.destination as! InputViewController
                let indexPath = inputTableView.indexPathForSelectedRow
                if let row = indexPath?.row {
                    switch row {
                    case 3:
                        inputViewController.selectedIndex = indexPath?.row
                    case 4:
                        inputViewController.selectedIndex = indexPath?.row
                    case 5:
                        inputViewController.selectedIndex = indexPath?.row
                    default:
                        break
                    }
                }
            }
        }
        
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Place.shared.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell") as! InputTableViewCell
        cell.titleLabel.text = Place.shared.titles[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.inputLabel.text = Place.shared.name ?? "未設定"
        case 1:
            cell.inputLabel.text = Place.shared.station ?? "未設定"
        case 2:
            cell.inputLabel.text = Place.shared.line ?? "未設定"
        case 3:
            cell.inputLabel.text = Place.shared.exit ?? "未設定"
        case 4:
            cell.inputLabel.text = Place.shared.direction ?? "未設定"
        case 5:
            cell.inputLabel.text = Place.shared.trainNumber ?? "未設定"
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
            self.performSegue(withIdentifier: "toStations", sender: nil)
        case 2:
            self.performSegue(withIdentifier: "toLines", sender: nil)
        case 3:
            self.performSegue(withIdentifier: "toInput", sender: nil)
        case 4:
            self.performSegue(withIdentifier: "toInput", sender: nil)
        case 5:
            self.performSegue(withIdentifier: "toInput", sender: nil)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - GMSAutocompleteResultsViewControllerDelegate
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        Place.shared.name = place.name
        Place.shared.location = place.coordinate
        
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
    
    @IBAction func checkin() {
        SVProgressHUD.show(withStatus: "保存中...")
        let object = NCMBObject(className: "Place")
        object?.setObject(Place.shared.name, forKey: "name")
        object?.setObject(Place.shared.station, forKey: "station")
        object?.setObject(Place.shared.line, forKey: "line")
        object?.setObject(Place.shared.exit, forKey: "exit")
        object?.setObject(Place.shared.direction, forKey: "direction")
        object?.setObject(Place.shared.trainNumber, forKey: "trainNumber")
        object?.setObject(Place.shared.location?.longitude, forKey: "longitude")
        object?.setObject(Place.shared.location?.latitude, forKey: "latitude")
        object?.saveInBackground({ (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                SVProgressHUD.showSuccess(withStatus: "Success")
                Place.shared.name = nil
                Place.shared.station = nil
                Place.shared.line = nil
                Place.shared.exit = nil
                Place.shared.direction = nil
                Place.shared.trainNumber = nil
                Place.shared.location = nil
                self.inputTableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    SVProgressHUD.dismiss()
                    self.tabBarController?.selectedIndex = 0
                }
                
            }
        })
    }
}
