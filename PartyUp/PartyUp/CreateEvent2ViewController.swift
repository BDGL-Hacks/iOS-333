//
//  CreateEventTwoViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/6/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class CreateEvent2ViewController: PartyUpViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate  {
    
    /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var addedFriendsTableView: UITableView!
    
    /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var createEvent: CreateModel?
    var addedFriends: NSMutableArray? = NSMutableArray()
    
    /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    /* Set up table and fetch data from create model */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addedFriendsTableView.delegate = self
        addedFriendsTableView.dataSource = self
        navBar.delegate = self
        
        self.addedFriendsTableView.sectionHeaderHeight = 65
        self.addedFriendsTableView.rowHeight = 65
        
        
        addedFriends?.addObjectsFromArray(createEvent!.getInvitedList() as [AnyObject])

        // Do any additional setup after loading the view.
    }

    /* Reload the table view */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (isLoggedIn()) {
            addedFriendsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying create event 2 page")
    }
    
    /* Set position of top navigation bar */
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }

    /* Button to return to fist event creation page */
    @IBAction func backToFirst(sender: UIBarButtonItem) {
        PULog("Going back to first event page")
        var inviteList = addedFriends! as NSArray
        createEvent?.setInviteList(inviteList)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* User taps confirm button to create event */
    @IBAction func finishButtonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("eventCreationTwoToHome", sender: self)
    }
    
    /* Prepare for segues */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "createTwoToAddFriends" {
            PULog("Preparing for segue")
            let destinationVC = segue.destinationViewController as! AddFriendsViewController
            destinationVC.create = self.createEvent
            destinationVC.previousViewController = self
            destinationVC.setPrev(AddFriendsViewController.PrevType.CreateEvent2)
        }
        else if segue.identifier == "eventCreationTwoToHome" {
            PULog("Preparing for segue")
            finalizeEvent()
        }
    }
    
    /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Finalize invite choices and creates event */
    func finalizeEvent() {
        PULog("Finalize event pressed")
        /* Iterate through friends list and send it to the backend */
        var friendIDs: [NSString] = [NSString]()
        for var j = 0; j < addedFriendsTableView.numberOfSections(); ++j {
            for var i = 0; i < addedFriendsTableView.numberOfRowsInSection(j); ++i {
                
                var indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: j)
                var cell = addedFriendsTableView.cellForRowAtIndexPath(indexPath) as? AddFriendsTableViewCell
                let userID = "\(DataManager.getUserID(cell!.getCellData()))"
                
                friendIDs.append(userID)
            }
        }
        
        /* Check that friends list was actually populated */
        for friend in friendIDs {
            PULog("\(friend)")
        }
        
        // Send to backend
        createEvent?.eventSecondPage(friendIDs)
        
        let (backendError: NSString?, eventID: NSString?) = createEvent!.eventSendToBackend()
        
        /* Not sure if need this code because segue is already bound to the button */
        if (backendError != nil)
        {
            displayAlert("Event creation Failed", message: backendError!)
        }
    }
    
    /* Called by next page to update the table based on
    user additions */
    func updateAddedFriends() {
        var friendsToAdd: NSArray = createEvent!.getSelectedUsers()
        addedFriends?.addObjectsFromArray(friendsToAdd as [AnyObject])
        createEvent?.setInviteList(addedFriends! as NSArray)
        addedFriendsTableView.reloadData()
    }
    
    
    /*----------------------------------------*
    * Table view methods                     *
    *----------------------------------------*/
    
    /* Return the number of sections in the table */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /* Return the number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedFriends!.count
    }
    
    /* Determines how to populate each cell in the table: *
    * Loads the display into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! AddFriendsTableViewCell
        
        var user: NSDictionary = NSDictionary()
        user = addedFriends![indexPath.row] as! NSDictionary
        
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
        headerCell.headerTextLabel.text = "Added Friends (swipe to delete)";
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
            addedFriends!.removeObjectAtIndex(indexPath.row)
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
