//
//  PartyUpAlertCell.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/30/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class PartyUpAlertCell: UITableViewCell
{
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    
   /*--------------------------------------------*
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    var data: NSDictionary = NSDictionary()
    var type: AlertType = AlertType.CheckUp
    var index: NSInteger = -1
    
    enum AlertType: NSString {
        case CheckUp     = "Check up:"
        case GroupInvite = "Group Invitation:"
        case EventInvite = "Event Invitation:"
    }
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    /* Responds to the accept button being pressed.  *
     * Sends the cell's information to alerts model. */
    func acceptButtonPressed() {
        AlertsModel.instance.acceptButtonPressed(data, type: type, index: index)
    }
    
    /* Responds to the reject button being pressed.  *
     * Sends the cell's information to alerts model. */
    func rejectButtonPressed() {
        AlertsModel.instance.rejectButtonPressed(data, type: type, index: index)
    }
    
    
   /*--------------------------------------------*
    * Set and Get Methods
    *--------------------------------------------*/
    
    /* Set the NSDictionary object and alert type associated with   *
     * the cell, along with the content label text to be displayed. */
    func loadCell(data: NSDictionary, type: AlertType, contentText: NSString, index: NSInteger) {
        self.data = data
        self.type = type
        self.index = index
        typeLabel.text = type.rawValue as String
        contentLabel.text = contentText as String
    }
    
    /* Retrieve the NSDictionary object associated with the cell */
    func getCellData() -> NSDictionary {
        return data
    }
    
    /* Retrieve the Alert Type associated with the cell */
    func getCellType() -> AlertType {
        return type
    }
    
    
   /*--------------------------------------------*
    * UITableViewCell Required Methods
    *--------------------------------------------*/
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}