//
//  PartyUpTableCell.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/9/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class PartyUpTableCell: UITableViewCell {
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var dayTextLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var subTextLabel: UILabel!
   
    
   /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var data: NSDictionary = NSDictionary()
    
    
   /*--------------------------------------------*
    * Custom Methods
    *--------------------------------------------*/
    
    /* Set the information to be displayed on the cell:  *
     * dayText should be a three-letter day (e.g. 'Fri') *
     * dayNumber should be a two digit day (e.g. '01')   *
     * mainText and subText is the text to be displayed. */
    func loadCell(#dayText: NSString, dayNumber: NSString, mainText: NSString, subText: NSString) {
        dayTextLabel.text = dayText as String
        dayNumberLabel.text = dayNumber as String
        mainTextLabel.text = mainText as String
        subTextLabel.text = subText as String
    }
    
    /* Set the NSDictionary object associated with the cell */
    func setCellData(data: NSDictionary) {
        self.data = data
    }
    
    /* Retrieve the NSDictionary object associated with the cell */
    func getCellData() -> NSDictionary {
        return data
    }
    
    
   /*--------------------------------------------*
    * UITableViewCell Required Methods
    *--------------------------------------------*/
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
