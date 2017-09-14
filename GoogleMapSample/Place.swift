//
//  Place.swift
//  GoogleMapSample
//
//  Created by Masuhara on 2017/09/15.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit

struct Place {
    
    let titles = ["場所", "最寄り駅", "路線", "方面", "最寄り出口", "出口付近車両"]
    
    static let shared = Place()
    
    var name: String?
    var station: String?
    var line: String?
    var direction: String?
    var exit: String?
    var trainNumber: String?
    
}
