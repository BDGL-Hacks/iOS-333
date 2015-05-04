//
//  PartyUpSideMenuCell.swift
//  PartyUp
//
//  Created by Lance Goodridge on 5/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class PartyUpSideMenuCell: UITableViewCell
{
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!

    func loadCell(imageName: NSString, labelText: NSString) {
        self.cellImageView = UIImageView(image: UIImage(named: imageName as String))
        self.cellLabel.text = labelText as String
    }
    
    func getLabelText() -> NSString {
        return cellLabel.text! as NSString
    }
}