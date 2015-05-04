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
    
    @IBOutlet weak var invitedGroupsLabel: UILabel!
    @IBOutlet weak var myGroupsLabel: UILabel!
    
    @IBOutlet weak var invitedGroupsTableView: PUDynamicTableView!
    @IBOutlet weak var myGroupsTableView: PUDynamicTableView!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        invitedGroupsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
        myGroupsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
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
        invitedGroupsTableView.reloadData()
        myGroupsTableView.reloadData()
        
        var isInvitedGroupsTableEmpty: Bool = false
        var isMyGroupsTableEmpty: Bool = false
        
        if (invitedGroupsTableView.numberOfRowsInSection(0) == 0) {
            isInvitedGroupsTableEmpty = true
            invitedGroupsTableView.hideView()
        } else {
            invitedGroupsTableView.showView()
        }
        
        if (myGroupsTableView.numberOfRowsInSection(0) == 0) {
            isMyGroupsTableEmpty = true
            myGroupsTableView.hideView()
        } else {
            myGroupsTableView.showView()
        }
        
        if (isInvitedGroupsTableEmpty && isMyGroupsTableEmpty) {
            invitedGroupsLabel.hidden = true
            myGroupsLabel.hidden = true
            placeholderLabel.hidden = false
        } else {
            invitedGroupsLabel.hidden = false
            myGroupsLabel.hidden = false
            placeholderLabel.hidden = true
        }
    }
    
    
   /*--------------------------------------------*
    * TableView methods
    *--------------------------------------------*/
    
    /* Returns the number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == invitedGroupsTableView) {
            return searchGroupsModel.getInvitedGroups().count
        }
        else if (tableView == myGroupsTableView) {
            return searchGroupsModel.getAttendingGroups().count
        }
        else {
            PULog("Table view specified was not recognized")
            return 0
        }
    }
    
    /* Determines how to populate each cell in the table: *
     * Loads the display and group data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("partyUpTableCell") as! PartyUpTableCell
        
        var group: NSDictionary = NSDictionary()
        if (tableView == invitedGroupsTableView) {
            group = searchGroupsModel.getInvitedGroups()[indexPath.row] as! NSDictionary
        }
        else if (tableView == myGroupsTableView) {
            group = searchGroupsModel.getAttendingGroups()[indexPath.row] as! NSDictionary
        }
        
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
