//
//  Station.swift
//  GoogleMapSample
//
//  Created by Masuhara on 2017/09/15.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit
import CoreLocation

struct Station {
    
    var name: String
    var traveltime: String?
    var location: CLLocationCoordinate2D?
    
    init(name: String) {
        self.name = name
    }
    
}
