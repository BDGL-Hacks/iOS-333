//
//  InviteFriendsViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 5/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class InviteFriendsViewController: PartyUpViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate {

    enum PrevType {
        case EventInfo
        case GroupInfo
        case GroupDetail
    }
    
    /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var invitedFriendsTableView: UITableView!
    
    /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var update: CreateModel = CreateModel()
    var invitedFriends: NSMutableArray? = NSMutableArray()
    var event: NSDictionary?
    var group: NSDictionary?
    var isEvent: Bool = false
    var isCreatedEvent: Bool = false
    var previousViewController: AnyObject?
    var prevType = PrevType.EventInfo
    
    /*--------------------------------------------*
    * Setter methods called by previous controller
    *--------------------------------------------*/
    
    func setEventData(event: NSDictionary) {
        self.event = event
    }
    
    func setGroupData(group: NSDictionary) {
        self.group = group
    }
    
    func setGroupOrEvent(isEvent: Bool) {
        self.isEvent = isEvent
    }
    
    func setCreatedEvent(isCreatedEvent: Bool) {
        self.isCreatedEvent = isCreatedEvent
    }
    
    /* Set type of previous view controller */
    func setPrev(typeOfPrev: PrevType) {
        self.prevType = typeOfPrev
    }

    
    /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        invitedFriendsTableView.delegate = self
        invitedFriendsTableView.dataSource = self
        
        navBar.delegate = self
        
        self.invitedFriendsTableView.rowHeight = 65
        self.invitedFriendsTableView.sectionHeaderHeight = 65
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (isLoggedIn()) {
            invitedFriendsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying invite friends to group or event page")
    }
    
    /* Set position for top navigation bar */
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    /* Segue back to previous page if user confirms invites */
    @IBAction func checkmarkPressed(sender: UIBarButtonItem) {
        switch prevType {
        case .EventInfo:
            PULog("Preparing for segue")
            finalizeInvites()
            let prevVC = previousViewController as! EventInfoViewController
            var eventID = "\(DataManager.getEventID(event!))"
            prevVC.setEventData(eventID: eventID)
            self.dismissViewControllerAnimated(true, completion: nil)
        case .GroupInfo:
            PULog("Preparing for segue")
            finalizeInvites()
            let prevVC = previousViewController as! GroupInfoViewController
            var groupID = "\(DataManager.getGroupID(group!))"
            prevVC.setGroupData(groupID: groupID)
            self.dismissViewControllerAnimated(true, completion: nil)
        case .GroupDetail:
            PULog("Preparing for segue")
        
        default:
            PULog("Invalid case")
        }
    }
    
    
    /* Button to return to fist event creation page */
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        PULog("Going back to group or event info page")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* Prepare for segues */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "inviteFriendsToAddFriends") {
            PULog("Preparing for segue")
            let destinationVC = segue.destinationViewController as! AddFriendsViewController
            destinationVC.create = self.update
            destinationVC.previousViewController = self
            destinationVC.setPrev(AddFriendsViewController.PrevType.InviteFriends)
        }
        /*
        else if segue.identifier == "inviteFriendsToEventInfo" {
            PULog("Preparing for segue")
            finalizeInvites()
            let destinationVC = segue.destinationViewController as! EventInfoViewController
            var eventID = "\(DataManager.getEventID(event!))"
            destinationVC.setEventData(eventID: eventID)
            //destinationVC.setIsCreatedEvent(isCreatedEvent)
        }
        else if segue.identifier == "inviteFriendsToGroupInfo" {
            PULog("Preparing for segue")
            finalizeInvites()
            let destinationVC = segue.destinationViewController as! GroupInfoViewController
            var groupID = "\(DataManager.getGroupID(group!))"
            destinationVC.setGroupData(groupID: groupID)
        }
        */

    }
    
    /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* User finalizes choices and creates event */
    func finalizeInvites() {
        PULog("Invite people pressed")
        /* Iterate through friends list and send it to the backend */
        var friendIDs: [NSString] = [NSString]()
        for var j = 0; j < invitedFriendsTableView.numberOfSections(); ++j {
            for var i = 0; i < invitedFriendsTableView.numberOfRowsInSection(j); ++i {
                
                var indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: j)
                var cell = invitedFriendsTableView.cellForRowAtIndexPath(indexPath) as? AddFriendsTableViewCell
                let userID = "\(DataManager.getUserID(cell!.getCellData()))"
                
                friendIDs.append(userID)
            }
        }
        
        
        /* Send to backend */
        
        if isEvent {
            var eventID = "\(DataManager.getEventID(event!))"
            var backendError: NSString? =  update.inviteFriendsToEvent(eventID, userIDs: friendIDs)
        
            if (backendError != nil) {
                displayAlert("Event Update Failed", message: backendError!)
            }
        }
        else {
            var groupID = "\(DataManager.getGroupID(group!))"
            var backendError: NSString? = update.inviteFriendsToGroup(groupID, userIDs: friendIDs)
            
            if (backendError != nil) {
                displayAlert("Group Update Failed", message: backendError!)
            }
        }
    }
    
    /* Called by next page to update the table based on
    user additions */
    func updateAddedFriends() {
        var friendsToAdd: NSArray = update.getSelectedUsers()
        invitedFriends!.addObjectsFromArray(friendsToAdd as [AnyObject])
        update.setInviteList(invitedFriends! as NSArray)
        invitedFriendsTableView.reloadData()
    }
    
    /*--------------------------------------------*
    * TableView methods
    *--------------------------------------------*/
        
    /* Return the number of sections in the table */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /* Return the number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitedFriends!.count
    }
    
    /* Determines how to populate each cell in the table: *
    * Loads the display into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! AddFriendsTableViewCell
        
        var user: NSDictionary = NSDictionary()
        user = invitedFriends![indexPath.row] as! NSDictionary
        
        var firstName: NSString = DataManager.getUserFirstName(user)
        var lastName: NSString = DataManager.getUserLastName(user)
        var usernameEmail: NSString = DataManager.getUserUsername(user)
        var userID: NSString =  "\(DataManager.getUserID(user))"
        var fullName = DataManager.getUserFullName(user)
        
        cell.loadCell(fullName, usernameEmail: usernameEmail)
        cell.setCellData(user)
        
        cell.accessoryType = UITableViewCellAccessoryType.None
        return cell
    }
    
    /* Determines format and content for a header cell */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
        headerCell.headerTextLabel.text = "Friends to invite (swipe to delete)"
        headerCell.backgroundColor = UIColorFromRGB(0xFFFFFF)
        headerCell.contentView.backgroundColor = UIColorFromRGB(0xFFFFFF)
        headerCell.headerTextLabel.textColor = UIColorFromRGB(0x80C8B5)
        headerCell.contentView.layer.borderColor = UIColorFromRGB(0x80C8B5).CGColor
        headerCell.contentView.layer.borderWidth = 2.0
        return headerCell.contentView
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            invitedFriends!.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
