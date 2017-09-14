//
//  MapViewController.swift
//  GoogleMapSample
//
//  Created by Masuhara on 2017/09/15.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class MapViewController: UIViewController, GMSAutocompleteResultsViewControllerDelegate, GMSMapViewDelegate {
    
    let zoomRate: Float = 16.0
    
    var locationManager: CLLocationManager!
    
    var lastLocation: CLLocationCoordinate2D?
    
    var searchedLocation: CLLocationCoordinate2D!
    
    var placesClient: GMSPlacesClient!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    
    var searchController: UISearchController?
    
    var resultView: UITextView?
    
    @IBOutlet var mapView: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setUpSearchController()
        
        placesClient = GMSPlacesClient.shared()
        
        loadLastLocation()
        
        loadCurrentLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let stationsViewController = segue.destination as! StationsViewController
        stationsViewController.location = searchedLocation
    }
    
    // MARK: - GMSAutocompleteResultsViewControllerDelegate
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        searchedLocation = place.coordinate
        
        self.mapView.animate(toZoom: 16.0)
        self.mapView.animate(toLocation: place.coordinate)
        createMarker(position: place.coordinate, name: place.name)
        
        let actionSheet = UIAlertController(title: place.name, message: "この場所の最寄り駅を探しますか？", preferredStyle: .actionSheet)
        let searchAction = UIAlertAction(title: "検索", style: .default) { (action) in
            self.performSegue(withIdentifier: "toStations", sender: nil)
        }
        let checkinAction = UIAlertAction(title: "チェックイン", style: .default) { (action) in
            
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(searchAction)
        actionSheet.addAction(checkinAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
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
    
    // MARK: - MapDelegate
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let actionSheet = UIAlertController(title: marker.snippet, message: "この場所の最寄り駅を検索しますか？", preferredStyle: .actionSheet)
        let searchAction = UIAlertAction(title: "検索", style: .default) { (action) in
            self.searchedLocation = marker.position
            self.performSegue(withIdentifier: "toStations", sender: nil)
        }
        
        let checkinAction = UIAlertAction(title: "チェックイン", style: .default) { (action) in
            
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(searchAction)
        actionSheet.addAction(checkinAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Private
    func createMarker(position: CLLocationCoordinate2D, name: String?) {
        let marker = GMSMarker()
        marker.position = position
        if let name = name {
            marker.snippet = name
        }
        // marker.icon = UIImage(named: "")
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.map = self.mapView
    }
    
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
                        
                        self.mapView.animate(toZoom: 16.0)
                        self.mapView.animate(toLocation: place.coordinate)
                        
                        self.createMarker(position: place.coordinate, name: place.name)
                        
                        self.saveLastLocation(location: place.coordinate)
                    }
                }
            }
        })
    }
    
    func loadLastLocation() {
        if let lastLocationInfo = UserDefaults.standard.dictionary(forKey: "lastLocation") {
            let latitude = lastLocationInfo["latitude"] as! CLLocationDegrees
            let longitude = lastLocationInfo["longitude"] as! CLLocationDegrees
            lastLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            if let lastLocation = lastLocation {
                self.mapView.animate(toZoom: zoomRate)
                self.mapView.animate(toLocation: lastLocation)
            }
        }
    }
    
    func saveLastLocation(location: CLLocationCoordinate2D) {
        
        let lastLocationInfo = ["latitude": Double(location.latitude),
                                "longitude": Double(location.longitude)]
        
        let ud = UserDefaults.standard
        ud.set(lastLocationInfo, forKey: "lastLocation")
        ud.synchronize()
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

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
