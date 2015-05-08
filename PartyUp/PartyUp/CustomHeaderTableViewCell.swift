//
//  CustomHeaderTableViewCell.swift
//  PartyUp
//
//  Created by Graham Turk on 5/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class CustomHeaderTableViewCell: UITableViewCell {

    /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var headerTextLabel: UILabel!
    
    /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func hideButton() {
        addFriendsButton.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
