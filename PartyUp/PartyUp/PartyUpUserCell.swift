//
//  PartyUpUserCell.swift
//  PartyUp
//
//  Created by Graham Turk on 4/11/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class PartyUpUserCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var mySwitch: UISwitch!
    var userIDLabel: NSString?
    var usernameEmail: NSString?
    
    /*--------------------------------------------*
    * Custom Methods
    *--------------------------------------------*/
    
    func loadCell(username: NSString, userID: NSString, userEmail: NSString) {
        usernameLabel.text = username
        mySwitch.on = false
        userIDLabel = userID
        usernameEmail = userEmail
    }
    
    
    /*--------------------------------------------*
    * UITableViewCell Required Methods
    *--------------------------------------------*/
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
