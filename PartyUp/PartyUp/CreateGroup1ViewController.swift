//
//  CreateGroup1ViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/17/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class CreateGroup1ViewController: PartyUpViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    
    let createGroup: CreateModel = CreateModel()
    var groupMembers: NSMutableArray? = NSMutableArray()
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupMembersTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    /* Set up table and fetch data from create model */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.delegate = self
        
        groupMembersTableView.delegate = self
        groupMembersTableView.dataSource = self
        
        self.groupMembersTableView.sectionHeaderHeight = 53
        
        // possibly take out (using so that names remain when go back to this page)
        groupMembers?.addObjectsFromArray(createGroup.getInvitedList() as [AnyObject])

        // Do any additional setup after loading the view.
    }
    
    
    /* only insert if necessary to scroll up */
    /* var activeTextField: UITextField? {
        get {
            if (groupNameTextField.isFirstResponder()) {
                return eventTitleTextField
            }
            return nil
        }
        set {
            
        }
    }
    */

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (isLoggedIn()) {
            groupMembersTableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying Create Group 1 page")
    }
    
    /* Dismiss keyboard if view is tapped */
    @IBAction func viewTapped(sender: AnyObject) {
        groupNameTextField.resignFirstResponder()
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    /* Dismiss the view */
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        PULog("Going back to groups home page")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /* Prepare for segues */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "createGroup1ToAddFriends" {
            PULog("Preparing for segue")
            let destinationVC = segue.destinationViewController as! AddFriendsViewController
            destinationVC.create = self.createGroup
            destinationVC.previousViewController = self
            destinationVC.setPrev(AddFriendsViewController.PrevType.CreateGroup1)
        }
        else if segue.identifier == "createGroup1ToCreateGroup2" {
            PULog("Preparing for segue")
            addFriends()
            let destinationVC = segue.destinationViewController as! CreateGroup2ViewController
            destinationVC.createGroup = self.createGroup
        }
    }
    
    /* Iterate through friends in table and send emails to create
       group model object. */
    func addFriends() {
        PULog("Next page group pressed")
        /* Iterate through friends list and send it to the backend */
        var friendIDs: [NSString] = [NSString]()
        var friendEmails: [NSString] = [NSString]()
        for var j = 0; j < groupMembersTableView.numberOfSections(); ++j {
            for var i = 0; i < groupMembersTableView.numberOfRowsInSection(j); ++i {
                
                var indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: j)
                var cell = groupMembersTableView.cellForRowAtIndexPath(indexPath) as? AddFriendsTableViewCell
                let user = cell!.getCellData()
                let userID = "\(DataManager.getUserID(user))"
                let usernameEmail = DataManager.getUserUsername(user)
                
                friendIDs.append(userID)
                friendEmails.append(usernameEmail)
            }
        }
    
        
        /* Check that friends list was actually populated */
        /*for friend in friendIDs {
            PULog("\(friend)")
        }*/
        
        /* Send to backend */
        
        var groupName: NSString = groupNameTextField.text
        createGroup.groupFirstPage(friendIDs, groupName: groupName, inviteEmails: friendEmails)
    }
    
    // MARK: Table methods
    
    /* Return number of sections in the table */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /* Return number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers!.count
    }
    
    /* Determines how to populate each cell in the table: *
    * Loads the display into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! AddFriendsTableViewCell;
        
        var user: NSDictionary = NSDictionary()
        user = groupMembers![indexPath.row] as! NSDictionary
        
        var firstName: NSString = DataManager.getUserFirstName(user)
        var lastName: NSString = DataManager.getUserLastName(user)
        var usernameEmail: NSString = DataManager.getUserUsername(user)
        var userID: NSString =  "\(DataManager.getUserID(user))"
        
        var fullName = (firstName as String) +  " " + (lastName as String)
        cell.loadCell(fullName, usernameEmail: usernameEmail)
        cell.setCellData(user)
        
        cell.accessoryType = UITableViewCellAccessoryType.None
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
        headerCell.contentView.backgroundColor = UIColorFromRGB(0xE6C973)
        headerCell.headerTextLabel.text = "Added Friends (swipe to delete)";
        return headerCell.contentView
    }

    
    /* Called by AddFriendsViewController in order to update
       the table based on user additions */
    func updateAddedFriends() {
        var friendsToAdd: NSArray = createGroup.getSelectedUsers()
        groupMembers?.addObjectsFromArray(friendsToAdd as [AnyObject])
        createGroup.setInviteList(groupMembers! as NSArray)
        groupMembersTableView.reloadData()
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            groupMembers!.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    
    
    /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Validates the form fields.         *
    * Returns an error message string    *
    * if form is invalid, nil otherwise. */
    func validateForm() -> NSString?
    {
        var groupName: NSString = groupNameTextField.text
        
        if (groupName == "") {
            return "Event title is required."
        }
        return nil
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
