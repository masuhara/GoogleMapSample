//
//  LinesViewController.swift
//  GoogleMapSample
//
//  Created by Masuhara on 2017/09/15.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit
import Alamofire

import SWXMLHash


class LinesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var stationName: String!
    
    var stationCodes = [String]()
    
    var lines = [Line]()
    
    @IBOutlet var linesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linesTableView.dataSource = self
        linesTableView.delegate = self
        
        linesTableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "LineTableViewCell", bundle: Bundle.main)
        linesTableView.register(nib, forCellReuseIdentifier: "LineCell")
        
        loadLines()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LineCell") as! LineTableViewCell
        cell.lineNameLabel.text = lines[indexPath.row].lineName
        cell.stationNameLabel.text = lines[indexPath.row].stationName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let id = self.restorationIdentifier {
            if id == "SearchLine" {
                // TODO: - toDetail
            } else {
                Place.shared.line = lines[indexPath.row].lineName
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func loadLines() {

        let allStations = loadCSV(filename: "station20170403free")
        
        for station in allStations {
            let splitStationRow = station.components(separatedBy: ",")
            if splitStationRow.count < 3 {
                // print("Station info is something wrong...")
                // return
            } else {
                let name = splitStationRow[2]
                
                if let stationName = stationName {
                    if name.contains(String(stationName.characters.dropLast())) == true {
                        let stationCode = splitStationRow[1]
                        stationCodes.append(stationCode)
                    }
                } else {
                    if let station = Place.shared.station {
                        if name.contains(String(station.characters.dropLast())) == true {
                            let stationCode = splitStationRow[1]
                            stationCodes.append(stationCode)
                        }
                    }
                }
            }
        }
        
        if let code = stationCodes.first {
            let url = "http://www.ekidata.jp/api/g/\(code).xml"
            
            Alamofire.request(url).response{ response in
                let xml = SWXMLHash.parse(response.data!)
                
                for stationInfo in xml["ekidata"]["station_g"].all {
                    print(stationInfo)
                    let line = Line(stationCode: stationInfo["station_cd"].element!.text, stationName: stationInfo["station_name"].element!.text, lineCode: stationInfo["line_cd"].element!.text, lineName: stationInfo["line_name"].element!.text)
                    self.lines.append(line)
                }
                self.linesTableView.reloadData()
            }
        } else {
            print("Station detail not found.")
        }
        
    }
    
    func loadCSV(filename: String) -> [String] {
        var csvArray = [String]()
        let csvBundle = Bundle.main.path(forResource: filename, ofType: "csv")
        do {
            let csvData = try String(contentsOfFile: csvBundle!,
                                     encoding: String.Encoding.utf8)
            csvArray = csvData.components(separatedBy:"\n")
        } catch {
            print("Failed to read \(filename).csv")
        }
        return csvArray
    }
    
}
