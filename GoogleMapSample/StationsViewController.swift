//
//  StationsViewController.swift
//  GoogleMapSample
//
//  Created by Masuhara on 2017/09/15.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class StationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var location: CLLocationCoordinate2D!
    
    var stations = [Station]()
    
    @IBOutlet var stationsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stationsTableView.dataSource = self
        stationsTableView.delegate = self
        
        let nib = UINib(nibName: "StationTableViewCell", bundle: Bundle.main)
        stationsTableView.register(nib, forCellReuseIdentifier: "StationCell")
        
        stationsTableView.tableFooterView = UIView()
        
        loadNearByStations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = stationsTableView.indexPathForSelectedRow!
        let linesViewController = segue.destination as! LinesViewController
        linesViewController.stationName = stations[indexPath.row].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell") as! StationTableViewCell
        cell.nameLabel.text = stations[indexPath.row].name
        cell.traveltimeLabel.text = stations[indexPath.row].traveltime
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "toLines", sender: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadNearByStations() {
        let url = "http://map.simpleapi.net/stationapi?x=\(location.longitude)&y=\(location.latitude)&output=json"

        Alamofire.request(url).responseJSON { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                for stationInfo in json.arrayValue {
                    var station = Station(name: stationInfo["name"].string!)
                    station.traveltime = stationInfo["traveltime"].string!
                    self.stations.append(station)
                }
                self.stationsTableView.reloadData()
            }
        }
    }

}
