//
//  SideMenuViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 5/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

@objc
protocol SideMenuViewControllerDelegate {
    
}

class SideMenuViewController: PartyUpViewController, UITableViewDelegate, UITableViewDataSource {
    
   /*--------------------------------------------*
    * Model and instance variables
    *--------------------------------------------*/
    
    var delegate: SideMenuViewControllerDelegate?
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var sideMenuTableView: UITableView!
    
    
   /*--------------------------------------------*
    * TableView Methods
    *--------------------------------------------*/
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("sideMenuCell", forIndexPath: indexPath) as! PartyUpSideMenuCell
        let cellNumber: Int = indexPath.item
        
        switch cellNumber {
            case 0:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "Groups List")
            case 1:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "Groups Detail")
            case 2:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "My Events")
            case 3:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "Find Events")
            case 4:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "Alerts")
            default:
                PULog("Table Error: Index outside expected range")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        PULog("Yay: \(indexPath.item)")
    }
    
}