//
//  SideMenuViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 5/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

protocol SideMenuViewControllerDelegate {
    func setActiveView(newActiveView: NavView)
    func logout()
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
        return 8
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("sideMenuCell", forIndexPath: indexPath) as! PartyUpSideMenuCell
        let cellNumber: Int = indexPath.item
        
        switch cellNumber {
            case 0:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "My Groups")
            case 1:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "Groups Detail")
            case 2:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "Create Group")
            case 3:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "My Events")
            case 4:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "Search Events")
            case 5:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "Create Event")
            case 6:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "Notifications")
            case 7:
                cell.loadCell("PartyUp_icon_2x_placeholder.png", labelText: "Logout")
            default:
                PULog("Table Error: Index outside expected range")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell: PartyUpSideMenuCell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpSideMenuCell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let labelText: NSString = cell.getLabelText()
        PULog("Cell at row \(indexPath.item) pressed. Label: \(labelText)")
        
        if (labelText == "My Groups") {
            delegate!.setActiveView(.GroupsList)
        }
        else if (labelText == "Groups Detail") {
            delegate!.setActiveView(.GroupsDetail)
        }
        else if (labelText == "Create Group") {
            
        }
        else if (labelText == "My Events") {
            delegate!.setActiveView(.MyEvents)
        }
        else if (labelText == "Search Events") {
            delegate!.setActiveView(.SearchEvents)
        }
        else if (labelText == "Create Event") {
            
        }
        else if (labelText == "Notifications") {
            delegate!.setActiveView(.Alerts)
        }
        else if (labelText == "Logout") {
            delegate!.logout()
        }
    }
    
}