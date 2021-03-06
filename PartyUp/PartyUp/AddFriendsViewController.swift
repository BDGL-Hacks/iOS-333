//
//  AddFriendsViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/12/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class AddFriendsViewController: PartyUpViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationBarDelegate {
    
    enum PrevType {
        case CreateGroup1
        case CreateEvent2
        case InviteFriends
    }
    
    /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var queryTableView: UITableView!
    
    /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var prevType = PrevType.CreateGroup1
    var previousViewController: AnyObject?
    var queryResults: NSArray? = NSArray()
    var create: CreateModel?
    var prevSearch: String? = nil
    
    /* text that gets sent to search method on backend */
    var searchText: String? = nil {
        didSet {
            searchTextField?.text = searchText
            prevSearch = oldValue
            if (prevSearch != nil) {
                PULog("Inside the if statement")
                addFriends()
            }
            refresh()
        }
    }

    
    /*
    var isFromEvent: Bool = false
    var isFromInviteFriends: Bool = false
    var isFromGroup: Bool = false
    */
    
    /* Set type of previous view controller */
    func setPrev(typeOfPrev: PrevType) {
        self.prevType = typeOfPrev
    }
    
    /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegates
        queryTableView.delegate = self
        queryTableView.dataSource = self
        navBar.delegate = self
        
        self.queryTableView.rowHeight = 65
        
        queryTableView.allowsMultipleSelection = true
        refresh()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    /* Make a query to the backend and reload the table */
    func refresh() {
        if (searchText != nil) {
            create?.update(CreateModel.QueryType.Search, search: searchText)
            queryResults = create?.getSearchUsers()
            queryTableView.reloadData()
        }
    }
    
    /* Text field property */
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    
    // MARK: Keyboard functions
    
    /* Dismisses keyboard when user presses "Return" button */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    /* Dismiss keyboard if view was tapped */
    @IBAction func viewTapped(sender: AnyObject) {
        searchTextField.resignFirstResponder()
    }
    
    /* Dismiss view and add selected friends to invite list */
    @IBAction func checkmarkPressed(sender: UIBarButtonItem) {
        addFriends()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* Dimiss view without adding friends */
    @IBAction func xButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    /*--------------------------------------------*
    * TableView methods
    *--------------------------------------------*/
    
    /* Returns the number of sections in tableView */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        return 1
    }
    
    /* Returns the number of rows in section */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        return queryResults!.count
    }
    
    /* Determines how to populate each cell in the table: *
    * Loads the display and event data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! AddFriendsTableViewCell
        
        // Configure the cell //
        
        var user: NSDictionary = NSDictionary()
        user = queryResults![indexPath.row] as! NSDictionary
        
        // get values from model to display in the cell
        var firstName: NSString = DataManager.getUserFirstName(user)
        var lastName: NSString = DataManager.getUserLastName(user)
        var usernameEmail: NSString = DataManager.getUserUsername(user)
        var userID: NSString = "\(DataManager.getUserID(user))"
        var fullName = DataManager.getUserFullName(user)
        
        cell.loadCell(fullName, usernameEmail: usernameEmail)
        cell.setCellData(user)
        // set the checkmark accessory (default is no checkmark)
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
    
    /*--------------------------------------------*
    * Helper methods
    *--------------------------------------------*/
    
    /* Iterate through selected cells and set selected users property
       of create model */
    func addFriends() {
        var selectedUsers: NSMutableArray = NSMutableArray()
        if let indexPaths = queryTableView.indexPathsForSelectedRows() {
            for var i = 0; i < indexPaths.count; ++i {
                var thisPath = indexPaths[i] as! NSIndexPath
                var cell = queryTableView.cellForRowAtIndexPath(thisPath)
                if let cell = cell as? AddFriendsTableViewCell {
                    
                    /*
                    var userFirstName = cell.firstName!
                    var userLastName = cell.lastName!
                    var userEmail = cell.usernameEmail!
                    var userID = cell.userID!
                    var dict: [NSString : NSString] = ["username": userEmail, "id": userID, "first_name": userFirstName, "last_name": userLastName]
                    */
                    
                    var dict = cell.getCellData()
                    
                    selectedUsers.addObject(dict)
                }
            }
        }
        
        create?.setSelectedUsers(selectedUsers as NSArray)
        
        switch prevType {
        case .InviteFriends:
            let prevInviteFriends = previousViewController as! InviteFriendsViewController
            prevInviteFriends.updateAddedFriends()
        case .CreateEvent2:
            let prevEventCreation2 = previousViewController as! CreateEvent2ViewController
            prevEventCreation2.updateAddedFriends()
        case .CreateGroup1:
            let prevGroupCreation1 = previousViewController as! CreateGroup1ViewController
            prevGroupCreation1.updateAddedFriends()
        }
        
        // self.dismissViewControllerAnimated(true, nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
