//
//  MainGroupsViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class MainGroupsViewController: PartyUpViewController, UITableViewDelegate, UITableViewDataSource
{
    
   /*--------------------------------------------*
    * Model and instance variables
    *--------------------------------------------*/
    
    let searchGroupsModel: SearchGroupsModel = SearchGroupsModel()
    
    var shouldPerformQueries: Bool = true
    var selectedCellGroupData: NSDictionary = NSDictionary()
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var groupsTableView: PUDynamicTableView!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        groupsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
        self.groupsTableView.sectionHeaderHeight = 53
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (shouldPerformQueries && isLoggedIn()) {
            searchGroupsModel.update()
            shouldPerformQueries = false
            updateViews()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying My Groups page")
    }
    
    /* If we are segueing to GroupChatVC, send the cell's group data beforehand */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "mainGroupsToGroupChat") {
            let navController: UINavigationController = segue.destinationViewController as! UINavigationController
            let groupChatVC: GroupChatViewController = navController.viewControllers[0] as! GroupChatViewController
            groupChatVC.setGroupData(selectedCellGroupData)
        }
    }
    
   /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Updates the views for the tables and their labels */
    func updateViews()
    {
        groupsTableView.reloadData()
        
        if (groupsTableView.numberOfRowsInSection(0) == 0) {
            groupsTableView.hideView()
            placeholderLabel.hidden = false
        }
        else {
            groupsTableView.showView()
            placeholderLabel.hidden = true
        }
    }
    
    
   /*--------------------------------------------*
    * TableView methods
    *--------------------------------------------*/
    
    /* Returns the number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchGroupsModel.getAttendingGroups().count
    }
    
    /* Determines how to populate each cell in the table: *
     * Loads the display and group data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("partyUpTableCell") as! PartyUpTableCell
        
        var group: NSDictionary = searchGroupsModel.getAttendingGroups()[indexPath.row] as! NSDictionary
        
        var dayText: NSString = DataManager.getGroupDayText(group)
        var dayNumber: NSString = DataManager.getGroupDayNumber(group)
        var mainText: NSString = DataManager.getGroupTitle(group)
        
        var subText: String = ""
        var groupEvents: NSArray = DataManager.getGroupSparseEvents(group)
        for event in groupEvents {
            if (subText != "") {
                subText += ", "
            }
            subText += DataManager.getEventTitle(event as! NSDictionary) as! String
        }
        
        cell.loadCell(dayText: dayText, dayNumber: dayNumber, mainText: mainText, subText: subText)
        cell.setCellData(group)
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
        headerCell.contentView.backgroundColor = UIColorFromRGB(0xE6C973)
        headerCell.headerTextLabel.text = "My Groups"
        return headerCell.contentView
    }
    
    /* Determines what to do when a table cell is selected */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell: PartyUpTableCell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpTableCell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let groupTitle = DataManager.getGroupTitle(cell.getCellData())
        PULog("Group Cell Pressed.\nCell Row: \(indexPath.row), Group Name: \(groupTitle)")
        PULog("Transition to Group Chat screen")
        selectedCellGroupData = cell.getCellData()
        self.performSegueWithIdentifier("mainGroupsToGroupChat", sender: self)
    }
    
}
