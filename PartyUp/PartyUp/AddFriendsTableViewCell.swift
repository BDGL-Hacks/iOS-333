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
    @IBOutlet weak var emailLabel: UILabel!
    
    /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var data: NSDictionary = NSDictionary()
    
    /*--------------------------------------------*
    * Instance methods
    *--------------------------------------------*/
    
    /* Load the cell data */
    func loadCell(fullName: NSString, usernameEmail: NSString) {
        self.nameLabel.text = fullName as String
        self.emailLabel.text = usernameEmail as String
    }
    
    /* Hide email label (for use in create group from event) */
    func setEmailHidden() {
        emailLabel.hidden = true
    }
    
    /* Set the NSDictionary object associated with the cell */
    func setCellData(data: NSDictionary) {
        self.data = data
    }
    
    /* Retrieve the NSDictionary object associated with the cell */
    func getCellData() -> NSDictionary {
        return data
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
