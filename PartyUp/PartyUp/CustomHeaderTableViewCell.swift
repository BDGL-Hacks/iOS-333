//
//  CustomHeaderTableViewCell.swift
//  PartyUp
//
//  Created by Graham Turk on 5/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class CustomHeaderTableViewCell: UITableViewCell {

    
    @IBOutlet weak var headerTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
