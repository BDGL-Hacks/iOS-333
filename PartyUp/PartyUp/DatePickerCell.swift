//
//  DatePickerCell.swift
//  PartyUp
//
//  Created by Graham Turk on 4/30/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell {

    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    init(style: UITableViewCellStyle?, reuseIdentifier: String) {
        super.init(style: style!, reuseIdentifier: reuseIdentifier)
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder)
    {
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
