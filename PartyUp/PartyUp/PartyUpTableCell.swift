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
    * Custom Methods
    *--------------------------------------------*/
    
    func loadCell(#dayText: NSString, dayNumber: NSString, mainText: NSString, subText: NSString) {
        dayTextLabel.text = dayText
        dayNumberLabel.text = dayNumber
        mainTextLabel.text = mainText
        subTextLabel.text = subText
    }
    
    
   /*--------------------------------------------*
    * UITableViewCell Required Methods
    *--------------------------------------------*/
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
