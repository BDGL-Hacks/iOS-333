//
//  CreateEventTwoViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/6/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class CreateEvent2ViewController: PartyUpViewController, UITableViewDataSource, UITableViewDelegate  {

    var create: CreateEventModel?
    
    
    
    @IBOutlet weak var addedFriendsTableView: UITableView!
    var addedFriends: NSMutableArray? = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addedFriendsTableView.delegate = self
        addedFriendsTableView.dataSource = self

        // Do any additional setup after loading the view.
    }

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

    /* Button to return to fist event creation page */
    @IBAction func backToFirst(sender: UIButton) {
        PULog("Going back to first event page")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "createTwoToAddFriends" {
            PULog("Preparing for segue")
            let destinationVC = segue.destinationViewController as AddFriendsViewController
            destinationVC.create = self.create
            destinationVC.previousViewController = self
        }
    }
    
    
    /* User finalizes choices and creates event */
    @IBAction func createEvent(sender: UIButton) {
        
        PULog("Finalize event pressed")
        /* Iterate through friends list and send it to the backend */
        var friendEmails: [NSString] = [NSString]()
        for var j = 0; j < addedFriendsTableView.numberOfSections(); ++j {
            for var i = 0; i < addedFriendsTableView.numberOfRowsInSection(j); ++i {
                
                var indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: j)
                var cell = addedFriendsTableView.cellForRowAtIndexPath(indexPath) as? AddFriendsTableViewCell
                
                friendEmails.append(cell!.usernameEmail!)
            }
        }
        
        /* Check that friends list was actually populated */
        for friend in friendEmails {
            PULog("\(friend)")
        }
        
        /* Send to backend */
        
        create?.secondPage(friendEmails)
        
        var backendError: NSString? = create?.sendToBackend()
        if (backendError == nil)
        {
            self.performSegueWithIdentifier("eventCreationTwoToHome", sender: self)
        }
        else {
            displayAlert("Event creation Failed", message: backendError!)
            self.performSegueWithIdentifier("eventCreationTwoToHome", sender: self)
        }
    
    }
    
    
    /*--------------------------------
    /* Table search helper methods */
    --------------------------------*/
    
    /*
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        self.performSegueWithIdentifier("eventCreationTwoToResults", sender: self)
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = usernameList.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.usersTableView.reloadData()
    }

    */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedFriends!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as AddFriendsTableViewCell;
        
        var user: NSDictionary = NSDictionary()
        user = addedFriends![indexPath.row] as NSDictionary
        
        var firstName: NSString = CreateEventModel.getUserFirstName(user)
        var lastName: NSString = CreateEventModel.getUserLastName(user)
        var usernameEmail: NSString = CreateEventModel.getUserEmail(user)
        var userID: NSString =  CreateEventModel.getUserID(user)
        
        var fullName = firstName +  " " + lastName
        cell.loadCell(fullName, firstName: firstName, lastName: lastName, userID: userID, usernameEmail: usernameEmail)
        
        cell.accessoryType = UITableViewCellAccessoryType.None
        return cell
    }
    
    func updateAddedFriends() {
        var friendsToAdd: NSArray = create!.getSelectedUsers()
        addedFriends?.addObjectsFromArray(friendsToAdd)
        create?.setInviteList(addedFriends! as NSArray)
        addedFriendsTableView.reloadData()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
