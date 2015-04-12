//
//  AddFriendsViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/12/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class AddFriendsViewController: PartyUpViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var previousViewController: CreateEvent2ViewController?
    var queryResults: NSArray? = NSArray()
    var create: CreateEventModel?
    
    // text that gets sent to search method on backend
    var searchText: String? = "David" {
        didSet{
            searchTextField?.text = searchText
            refresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.rowHeight = 44
        
        tableView.allowsMultipleSelection = true
        refresh()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    // refresh the table by querying the backend
    func refresh() {
        if (searchText != nil) {
            create?.update(CreateEventModel.QueryType.Search, search: searchText)
            queryResults = create?.getSearchUsers()
            tableView.reloadData()
        }
    }
    
    //  text box property
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    // dismiss keyboard if view was tapped
    @IBAction func viewTapped(sender: AnyObject) {
        searchTextField.resignFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return queryResults!.count
    }
    
    // populate the table using the userList array
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as AddFriendsTableViewCell
        
        
        // Configure the cell //
        
        var user: NSDictionary = NSDictionary()
        user = queryResults![indexPath.row] as NSDictionary
        
        // get values from model to display in the cell
        var firstName: NSString = CreateEventModel.getUserFirstName(user)
        var lastName: NSString = CreateEventModel.getUserLastName(user)
        var emailAddress: NSString = CreateEventModel.getUserEmail(user)
        var idNum: NSString = "10" as NSString // CreateEventModel.getUserIDNum(user)
        
        // concatenate the name for cell display
        var fullName = firstName +  " " +  lastName
        cell.loadCell(fullName, first: firstName, last: lastName, id: idNum, email: emailAddress)
        
        // set the checkmark
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        return cell
    }
    
    // function to determine selection of cells - if cell is selected a checkmark appears
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        PULog("Cell selected: \(indexPath.row)")
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    // user presses "Add Friends" button, send list to model
    @IBAction func addFriends(sender: UIButton) {
        
        var selectedUsers: NSMutableArray = NSMutableArray()
        if let indexPaths = tableView.indexPathsForSelectedRows() {
            for var i = 0; i < indexPaths.count; ++i {
                var thisPath = indexPaths[i] as NSIndexPath
                var cell = tableView.cellForRowAtIndexPath(thisPath)
                if let cell = cell as? AddFriendsTableViewCell {
                    
                    var userFirstName = cell.firstName!
                    var userLastName = cell.lastName!
                    var userEmail = cell.usernameEmail!
                    var userID = cell.userID!
                    
                    var dict: [NSString : NSString] = ["username": userEmail, "id": userID, "first_name": userFirstName, "last_name": userLastName]
                    
                    selectedUsers.addObject(dict)
                    
                    // Do something with the cell
                    // If it's a custom cell, downcast to the proper type
                }
            }
        }
        
        create?.setSelectedFriends(selectedUsers as NSArray)
        previousViewController!.updateAddedFriends()
        previousViewController!.reloadView()
        
        self.dismissViewControllerAnimated(true, nil)
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
