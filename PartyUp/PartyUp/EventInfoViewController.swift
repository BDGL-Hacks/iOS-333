//
//  EventInfoViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/11/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class EventInfoViewController: PartyUpViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UINavigationBarDelegate {

    /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var event: NSDictionary = NSDictionary()
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ageRestrictionsLabel: UILabel!
    var isEventOwner: Bool = false
    var isFromGroupInfo: Bool = false
    
    @IBOutlet weak var bindEventToGroupButton: UIButton!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var attendeeTable: PUDynamicTableView!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        PULog("Back button pressed")
        PULog("Returning to previous screen")
        //self.performSegueWithIdentifier("eventInfoToHome", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventInfoToCreateGroup" {
            PULog("Preparing for segue")
            let destinationVC = segue.destinationViewController as! CreateGroupFromEventViewController
            destinationVC.setEventData(event)
            destinationVC.fillAttendeeList(DataManager.getEventAttendees(event))
        }
        else if segue.identifier == "eventInfoToBindGroup" {
            PULog("Preparing for segue")
            let destinationVC = segue.destinationViewController as! BindEventToGroupViewController
            destinationVC.setEventData(event)
        }
        else if segue.identifier == "eventInfoToInviteFriends" {
            PULog("Preparing for segue")
            let destinationVC = segue.destinationViewController as! InviteFriendsViewController
            destinationVC.setEventData(event)
            destinationVC.setGroupOrEvent(true)
            destinationVC.setCreatedEvent(isEventOwner)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEventData()
        PULog("Displaying Event Info Page")
        attendeeTable.sectionHeaderHeight = 53
        navBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (isFromGroupInfo) {
            createGroupButton.enabled = false
            bindEventToGroupButton.enabled = false
        }
    }
    
    /* User taps cell to add people to the event */
    
    
    @IBAction func addFriendsButtonPressed(sender: UIButton) {
        PULog("Invite button pressed")
        self.performSegueWithIdentifier("eventInfoToInviteFriends", sender: self)
    }
    
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
   /*--------------------------------------------*
    * Helper methods
    *--------------------------------------------*/
    
    /* Loads the event data into the views */
    func loadEventData() {
        PULog("Loading Event Info page data:\n\(event)")
        
        // Retrieve relevant information from event
        let eventTitle: NSString = DataManager.getEventTitle(event)
        let date: NSString = DataManager.getEventDate(event)
        let startTime: NSString = DataManager.getEventStartTime(event)
        let locationName: NSString = DataManager.getEventLocationName(event)
        let desc: NSString = DataManager.getEventDescription(event)
        let price: NSInteger? = DataManager.getEventPrice(event)
        let ageRestriction: NSInteger? = DataManager.getEventAgeRestriction(event)
        
        // Put information into corresponding views
        eventTitleLabel.text = eventTitle as String
        dateLabel.text = date as String
        timeLabel.text = startTime as String
        locationLabel.text = locationName as String
        descriptionLabel.text = desc as String
        if (price != nil && price != 0) {
            priceLabel.text = "$\(price!)"
        } else {
            priceLabel.text = "Free"
        }
        if (ageRestriction != nil && ageRestriction != 0) {
            ageRestrictionsLabel.text = "\(ageRestriction!)"
        } else {
            ageRestrictionsLabel.text = "None"
        }
    }
    
    func setEventData(#event: NSDictionary) {
        self.event = event
        isEventOwner = DataManager.getEventIsAdmin(event)
    }
    
    func setEventData(#eventID: NSString) {
        let (errorMessage: NSString?, queryResult: NSDictionary?) =
        PartyUpBackend.instance.queryEventSearchByID(eventID)
        if (errorMessage != nil) {
            PULog("Get event by ID failed: \(errorMessage!)")
        } else {
            PULog("Update Success!")
        }
        self.event = queryResult!
        isEventOwner = DataManager.getEventIsAdmin(event)
    }
    
    
    func setFromGroupInfo(isFromGroupInfo: Bool) {
        self.isFromGroupInfo = isFromGroupInfo
    }
    
   /*--------------------------------------------*
    * TableView methods
    *--------------------------------------------*/
    
    /* Returns the number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.getEventAttendees(event).count
    }
    
    /* Determines how to populate each cell in the table: *
     * Loads each attendee's name into the cell.          */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        let user: NSDictionary = DataManager.getEventAttendees(event)[indexPath.row] as! NSDictionary
        cell.textLabel!.text = DataManager.getUserFullName(user) as String
        return cell
    }
    
    /* Populate the section headers of each table */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
        headerCell.headerTextLabel.text = "Attendees"
        if (!isEventOwner || !(DataManager.getEventPublic(event))) {
            headerCell.hideButton()
        }
        
        if (isFromGroupInfo) {
            headerCell.hideButton()
        }
        headerCell.backgroundColor = UIColorFromRGB(0xFFFFFF)
        headerCell.contentView.backgroundColor = UIColorFromRGB(0xFFFFFF)
        headerCell.headerTextLabel.textColor = UIColorFromRGB(0x80C8B5)
        headerCell.contentView.layer.borderColor = UIColorFromRGB(0x80C8B5).CGColor
        headerCell.contentView.layer.borderWidth = 2.0
        return headerCell
    }

    
    /* Determines what to do when a table cell is selected */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
