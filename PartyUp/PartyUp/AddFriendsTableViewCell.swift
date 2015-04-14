//
//  AddFriendsTableViewCell.swift
//  PartyUp
//
//  Created by Graham Turk on 4/12/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class AddFriendsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    var firstName: NSString?
    var lastName: NSString?
    var userID: NSString?
    var usernameEmail: NSString?
    
    
    func loadCell(fullName: NSString, firstName: NSString?, lastName: NSString, userID: NSString, usernameEmail: NSString) {
        self.nameLabel.text = fullName
        self.firstName = firstName
        self.lastName = lastName
        self.userID = userID
        self.usernameEmail = usernameEmail
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