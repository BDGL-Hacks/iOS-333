//
//  CreateGroupFromEventViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/23/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class CreateGroupFromEventViewController: PartyUpViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var eventTitleLabel: UILabel!
    var event: NSDictionary?
    var createGroup = CreateModel()
    var attendeeList: NSArray?
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var attendeeListTableView: UITableView!
    
    func setEventData(event: NSDictionary) {
        self.event = event
    }
    
    func fillAttendeeList(attendeeList: NSArray) {
        self.attendeeList = attendeeList
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attendeeListTableView.delegate = self
        attendeeListTableView.dataSource = self
        
        self.attendeeListTableView.rowHeight = 45
        attendeeListTableView.allowsMultipleSelection = true
        
        loadEventData()
        // Do any additional setup after loading the view.
        
    }
    
    /* Loads the event data into the views */
    func loadEventData() {
        PULog("Loading Event Info page data:\n\(event)")
        
        // Retrieve relevant information from event
        let eventTitle: NSString = DataManager.getEventTitle(event!)
        
        // Put information into corresponding views
        eventTitleLabel.text = eventTitle as String
    }

    
    @IBAction func viewTapped(sender: AnyObject) {
        groupNameTextField.resignFirstResponder()
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventGroupCreationToHome" {
            PULog("Preparing for segue")
            addFriends()
            let destinationVC = segue.destinationViewController as! HomepageViewController
            destinationVC.setActiveView(HomepageViewController.NavView.Groups)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendeeList!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! AddFriendsTableViewCell;
        
        var user: NSDictionary = NSDictionary()
        user = attendeeList![indexPath.row] as! NSDictionary
        
        var firstName: NSString = DataManager.getUserFirstName(user)
        var lastName: NSString = DataManager.getUserLastName(user)
        var usernameEmail: NSString = DataManager.getUserUsername(user)
        var userID: NSString =  "\(DataManager.getUserID(user))"
        
        var fullName = (firstName as String) +  " " + (lastName as String)
        cell.loadCell(fullName, firstName: firstName, lastName: lastName, userID: userID, usernameEmail: usernameEmail)
        cell.setEmailHidden()
        cell.accessoryType = UITableViewCellAccessoryType.None
        return cell

        
    }
    
    /* Called when user selects a cell in the table *
    Sets a checkmark to indiciate selection      */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        PULog("Cell selected: \(indexPath.row)")
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
    }
    
    /* Called when user deselects a cell in the table  *
    Removes the checkmark to indiciate deselection  */
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        PULog("Cell deselected: \(indexPath.row)")
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    func addFriends() {
        
        var friendIDs: [NSString] = [NSString]()
        var friendEmails: [NSString] = [NSString]()
        if let indexPaths = attendeeListTableView.indexPathsForSelectedRows() {
            for var i = 0; i < indexPaths.count; ++i {
                var thisPath = indexPaths[i] as! NSIndexPath
                var cell = attendeeListTableView.cellForRowAtIndexPath(thisPath)
                if let cell = cell as? AddFriendsTableViewCell {
                    friendIDs.append(cell.userID!)
                    friendEmails.append(cell.usernameEmail!)
                }
            }
        }
        
        var groupName: NSString = groupNameTextField.text
        createGroup.groupFirstPage(friendIDs, groupName: groupName, inviteEmails: friendEmails)
        var eventID = "\(DataManager.getEventID(event!))"
        var eventIDList: [NSString] = [eventID]
        createGroup.groupSecondPage(eventIDList)
        
        var backendError: NSString? = createGroup.groupSendToBackend()
        
        /* Not sure if need this code because segue is already bound to the button */
        if (backendError != nil) {
            displayAlert("Group creation Failed", message: backendError!)
        }
        
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
