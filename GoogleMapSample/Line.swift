//
//  Line.swift
//  GoogleMapSample
//
//  Created by Masuhara on 2017/09/15.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit

struct Line {
    
    var lineCode: String
    var lineName: String
    var stationCode: String
    var stationName: String
    
    init(stationCode: String, stationName: String, lineCode: String, lineName: String) {
        self.lineCode = lineCode
        self.lineName = lineName
        self.stationCode = stationCode
        self.stationName = stationName
    }
    
}
