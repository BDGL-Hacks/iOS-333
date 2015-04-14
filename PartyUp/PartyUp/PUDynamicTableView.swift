//
//  PUDynamicTable.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/11/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit
 
class PUDynamicTableView: UITableView {
    
   /* USAGE:
    * In order for this custom view to work properly, there must be
    * a height constraint specifying a default value (a height of
    * >= 0 is recommended), and have it wired to dynamicHeightConstraint
    * outlet specified below.
    */
    
   /*--------------------------------------------*
    * Constraints
    *--------------------------------------------*/
    
    @IBOutlet weak var dynamicHeightConstraint: NSLayoutConstraint!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    /* Automatically updates table height when data is reloaded */
    override func reloadData() {
        super.reloadData()
        PULog("Dynamic table view data reloaded. Updating view constraints...")
        updateView()
    }
    
    /* Updates the height constraint to match the height of the table's content */
    func updateView() {
        dynamicHeightConstraint.constant = contentSize.height
    }
    
    /* Shows the view by restoring its height constraint */
    func showView() {
        hidden = false
        updateView()
    }
    
    /* Hides the view by setting its height constraint to zero */
    func hideView() {
        hidden = true
        dynamicHeightConstraint.constant = 0
    }
    
}
