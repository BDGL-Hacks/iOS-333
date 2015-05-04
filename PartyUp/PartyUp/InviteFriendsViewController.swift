//
//  InviteFriendsViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 5/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class InviteFriendsViewController: PartyUpViewController, UITableViewDataSource, UITableViewDelegate {

    
    
    @IBOutlet weak var invitedFriendsTableView: UITableView!
    var updateEvent: CreateModel = CreateModel()
    var invitedFriends: NSMutableArray? = NSMutableArray()
    var event: NSDictionary?
    var group: NSDictionary?
    var isEvent: Bool = false
    var isEventOwner: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        invitedFriendsTableView.delegate = self
        invitedFriendsTableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    func setEventData(event: NSDictionary) {
        self.event = event
    }
   
    func setGroupOrEvent(isEvent: Bool) {
        self.isEvent = isEvent
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
    
    /* Button to return to fist event creation page */
    @IBAction func backToFirst(sender: UIBarButtonItem) {
        PULog("Going back to group or event info page")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* Prepare for segues */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "inviteFriendsToAddFriends" {
            PULog("Preparing for segue")
            let destinationVC = segue.destinationViewController as! AddFriendsViewController
            destinationVC.create = self.updateEvent
            destinationVC.previousViewController = self
            destinationVC.isEvent = true
        }
        else if segue.identifier == "inviteFriendsToHome" {
            PULog("Preparing for segue")
            finalizeInvites()
            let destinationVC = segue.destinationViewController as! HomepageViewController
            
            if isEvent {
                destinationVC.setActiveView(.MyEvents)
            }
            else {
                destinationVC.setActiveView(.GroupsList)
            }
            
        }
    }
    
    /* User finalizes choices and creates event */
    func finalizeInvites() {
        PULog("Invite people pressed")
        /* Iterate through friends list and send it to the backend */
        var eventID = "\(DataManager.getEventID(event!))"
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
            var backendError: NSString? =  updateEvent.inviteFriendsToEvent(eventID, userIDs: friendIDs)
        
            if (backendError != nil) {
                displayAlert("Event Update Failed", message: backendError!)
            }
        }
            /*
        else {
            var backendError: NSString? = update.inviteFriendsToGroup(groupID, userIDs: friendIDs)
            
            if (backendError != nil) {
                displayAlert("Group Update Failed", message: backendError!)
            }
            
        }
        */
        
    }

        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! AddFriendsTableViewCell
        
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
    
    /* Called by next page to update the table based on
    user additions */
    func updateAddedFriends() {
        var friendsToAdd: NSArray = updateEvent.getSelectedUsers()
        invitedFriends!.addObjectsFromArray(friendsToAdd as [AnyObject])
        updateEvent.setInviteList(invitedFriends! as NSArray)
        invitedFriendsTableView.reloadData()
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
