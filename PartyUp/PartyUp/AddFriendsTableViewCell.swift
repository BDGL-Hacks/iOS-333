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
    
    
    func loadCell(name: NSString, first: NSString?, last: NSString, id: NSString, email: NSString) {
        nameLabel.text = name
        firstName = first
        lastName = last
        userID = id
        usernameEmail = email
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
