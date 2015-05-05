//
//  GroupInfoViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 5/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class GroupInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate
 {

    @IBOutlet weak var groupEventsTableView: PUDynamicTableView!
    @IBOutlet weak var groupMembersTableView: PUDynamicTableView!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var groupEvents: NSArray = NSArray()
    var groupMembers: NSArray = NSArray()
    
    var selectedCellEventData: NSDictionary = NSDictionary()
    var group: NSDictionary = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        groupEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "eventCellPrototype")
        groupMembersTableView.rowHeight = 45
        groupMembersTableView.sectionHeaderHeight = 65
        groupEventsTableView.sectionHeaderHeight = 65
        
        navBar.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        groupEventsTableView.reloadData()
        groupMembersTableView.reloadData()
        groupEvents = DataManager.getGroupMembers(group)
        groupEvents = DataManager.getGroupSparseEvents(group)
       
        let groupName: NSString = DataManager.getGroupTitle(group)
        groupNameLabel.text = groupName as String
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "groupInfoToEventInfo") {
            let eventInfoVC: EventInfoViewController = segue.destinationViewController
                as! EventInfoViewController
            eventInfoVC.setEventData(event: selectedCellEventData)
            eventInfoVC.setFromGroupInfo(true)
        }
        else if (segue.identifier == "groupInfoToAddEvents") {
            let addEventsVC: CreateGroup2ViewController = segue.destinationViewController as! CreateGroup2ViewController
            addEventsVC.setGroupData(group)
            addEventsVC.setIsFromGroupInfo(true)
        }
        
        else if (segue.identifier == "groupInfoToInviteFriends") {
            let inviteFriendsVC: InviteFriendsViewController = segue.destinationViewController as! InviteFriendsViewController
            inviteFriendsVC.setGroupData(group)
            inviteFriendsVC.setGroupOrEvent(false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying group info page")
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /* Set the group data */
    func setGroupData(#group: NSDictionary) {
        self.group = group
    }
    
    func setGroupData(#groupID: NSString) {
        let (errorMessage: NSString?, queryResult: NSDictionary?) =
        PartyUpBackend.instance.queryGroupSearchByID(groupID)
        if (errorMessage != nil) {
            PULog("Get event by ID failed: \(errorMessage!)")
        } else {
            PULog("Update Success!")
        }
        self.group = queryResult!
    }
    
    /*--------------------------------------------*
    * TableView methods
    *--------------------------------------------*/
    
    /* Returns the number of sections in the table */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /* Returns the number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == groupEventsTableView) {
            return groupEvents.count
        }
        else if (tableView == groupMembersTableView) {
            return groupMembers.count
        }
        else {
            PULog("Table view specified was not recognized")
            return 0
        }
    }
    
    /* Determines how to populate each cell in the table: *
    * Loads the display and event data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (tableView == groupEventsTableView) {
            var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("eventCellPrototype") as! PartyUpTableCell
        
            var event: NSDictionary = NSDictionary()
            event = groupEvents[indexPath.row] as! NSDictionary
            var dayText: NSString = DataManager.getEventDayText(event)
            var dayNumber: NSString = DataManager.getEventDayNumber(event)
            var mainText: NSString = DataManager.getEventTitle(event)
        
            var subText = DataManager.getEventLocationName(event)
            cell.loadCell(dayText: dayText, dayNumber: dayNumber, mainText: mainText, subText: subText)
            cell.setCellData(event)
            cell.hideCheckmark()
            return cell
        }
        else {
            var cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! AddFriendsTableViewCell
            
            var user: NSDictionary = NSDictionary()
            user = groupMembers[indexPath.row] as! NSDictionary
            
            var firstName: NSString = DataManager.getUserFirstName(user)
            var lastName: NSString = DataManager.getUserLastName(user)
            var usernameEmail: NSString = DataManager.getUserUsername(user)
            var userID: NSString =  "\(DataManager.getUserID(user))"
            
            var fullName = (firstName as String) +  " " + (lastName as String)
            cell.loadCell(fullName, usernameEmail: usernameEmail)
            cell.setCellData(user)
            cell.setEmailHidden()
            cell.accessoryType = UITableViewCellAccessoryType.None
            return cell
        }
        
    }
    
    /* Populate the section headers of each table */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (tableView == groupEventsTableView) {
            let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
            headerCell.headerTextLabel.text = "Events";
            headerCell.backgroundColor = UIColorFromRGB(0xFFFFFF)
            headerCell.headerTextLabel.textColor = UIColorFromRGB(0x80C8B5)
            headerCell.contentView.layer.borderColor = UIColorFromRGB(0x80C8B5).CGColor
            headerCell.contentView.layer.borderWidth = 2.0
            return headerCell
        }
        else {
            let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
            headerCell.headerTextLabel.text = "Members";
            headerCell.backgroundColor = UIColorFromRGB(0xFFFFFF)
            headerCell.headerTextLabel.textColor = UIColorFromRGB(0x80C8B5)
            headerCell.contentView.layer.borderColor = UIColorFromRGB(0x80C8B5).CGColor
            headerCell.contentView.layer.borderWidth = 2.0
            return headerCell
        }
    }
    
    /* Determines what to do when a table cell is selected */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (tableView == groupEventsTableView) {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpTableCell
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                let eventName: NSString = DataManager.getEventTitle(cell.getCellData())
                PULog("Event Cell Pressed.\nCell Row: \(indexPath.row), Event Name: \(eventName)")
                PULog("Transitioning to Event Info screen")
                selectedCellEventData = cell.getCellData()
                self.performSegueWithIdentifier("groupInfoToEventInfo", sender: self)
        }
        else if (tableView == groupEventsTableView) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    /* Segue to add events page if user presses header of event table */
    @IBAction func addEventPressed(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("groupInfoToAddEvents", sender: self)
    }
    
    /* Segue to invite friends page if user presses header of members table */
    @IBAction func addMemberPressed(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("groupInfoToInviteFriends", sender: self)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
