//
//  BindEventToGroupViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 5/1/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class BindEventToGroupViewController: PartyUpViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {

    
    /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var groupsTableView: UITableView!
    
    /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var searchGroupsModel: SearchGroupsModel = SearchGroupsModel()
    var attendingQueryResults: NSArray? = NSArray()
    var shouldPerformQueries: Bool = true
    var selectedCellEventData: NSDictionary = NSDictionary()
    var previousViewController: CreateGroup2ViewController?
    var updateGroup: CreateModel = CreateModel()
    var event: NSDictionary?
    var selectedGroupData: NSDictionary? = nil
    
    
    /*---------------------------------------------*
    * Setter methods called by previous view       *
    * controller when segueing to this one         *
    *----------------------------------------------*/
    
    /* Called by previous view controller to initialize event */
    func setEventData(event: NSDictionary) {
        self.event = event
    }
    
    /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupsTableView.delegate = self
        groupsTableView.dataSource = self
        
        navBar.delegate = self
        
        self.groupsTableView.rowHeight = 65
        self.groupsTableView.sectionHeaderHeight = 65
        
        groupsTableView.allowsMultipleSelection = false
        
        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        groupsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "groupCellPrototype")
        
        loadEventData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (shouldPerformQueries && isLoggedIn()) {
            searchGroupsModel.update()
            
            attendingQueryResults = searchGroupsModel.getAttendingGroups()
            
            shouldPerformQueries = false
            groupsTableView.reloadData()
        
        }
    }
    
    /* Set position for top navigation bar */
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    /* Loads the event data into the views */
    func loadEventData() {
        let eventTitle: NSString = DataManager.getEventTitle(event!)
        eventTitleLabel.text = eventTitle as String
    }
    
    /* User taps checkmark to confirm choice; dismiss view */
    @IBAction func checkmarkPressed(sender: UIBarButtonItem) {
        if selectedGroupIsNil() == true {
            displayAlert("Error", message: "Must select a group")
        }
        else {
            self.performSegueWithIdentifier("bindGroupToHome", sender: self)
        }
    }
    
    /* Dismiss the view when user taps X button */
    @IBAction func xButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    /* Prepare for segue back to home page */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bindGroupToHome" {
            PULog("Preparing for segue")
            addEventToGroup()
        }
    }
    
    /*--------------------------------------------*
    * TableView methods
    *--------------------------------------------*/
    
    /* Return number of sections in the table */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /* Return number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendingQueryResults!.count
    }
    
    /* Determines how to populate each cell in the table: *
    * Loads the display and event data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // PULog("In tableView reload method")
        var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("groupCellPrototype") as! PartyUpTableCell
        
        var group: NSDictionary = NSDictionary()
        group = attendingQueryResults![indexPath.row] as! NSDictionary
        
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
        cell.hideCheckmark()
        return cell
    }
    
    /* Determines format and content for a header cell */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
        headerCell.headerTextLabel.text = "Select one of your existing groups"
        headerCell.backgroundColor = UIColorFromRGB(0xFFFFFF)
        headerCell.contentView.backgroundColor = UIColorFromRGB(0xFFFFFF)
        headerCell.headerTextLabel.textColor = UIColorFromRGB(0x80C8B5)
        headerCell.contentView.layer.borderColor = UIColorFromRGB(0x80C8B5).CGColor
        headerCell.contentView.layer.borderWidth = 2.0
        return headerCell
    }

    
    /* Called when user selects a cell in the table *
    Sets a checkmark to indiciate selection      */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        PULog("Cell selected: \(indexPath.row)")
        let cell: PartyUpTableCell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpTableCell
        selectedGroupData = cell.getCellData()
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
    }
    
    
    /* Called when user deselects a cell in the table  *
    Removes the checkmark to indiciate deselection  */
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        PULog("Cell deselected: \(indexPath.row)")
        let cell: PartyUpTableCell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpTableCell
        selectedGroupData = nil
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Iterate through selected friends and create a group for this event */
    func addEventToGroup() {
        
        var selectedGroupID: NSString = "\(DataManager.getGroupID(selectedGroupData!))"
        var eventID = "\(DataManager.getEventID(event!))"
        var eventIDList: [NSString] = [eventID]
        var backendError: NSString? =  updateGroup.addEventsToGroup(selectedGroupID, eventIDs: eventIDList)
    
        if (backendError != nil) {
            displayAlert("Group Update Failed", message: backendError!)
        }
        
    }
    
    func selectedGroupIsNil() -> Bool {
        return selectedGroupData == nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
