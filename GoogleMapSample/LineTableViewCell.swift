//
//  LineTableViewCell.swift
//  GoogleMapSample
//
//  Created by Masuhara on 2017/09/15.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit

class LineTableViewCell: UITableViewCell {
    
    @IBOutlet var stationNameLabel: UILabel!
    
    @IBOutlet var lineNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
