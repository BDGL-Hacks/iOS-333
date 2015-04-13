//
//  EventInfoViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/11/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class EventInfoViewController: PartyUpViewController, UITableViewDelegate, UITableViewDataSource {
    
   /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var event: NSDictionary = NSDictionary()
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ageRestrictionsLabel: UILabel!
    
    @IBOutlet weak var attendeeTable: PUDynamicTableView!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        PULog("Back button pressed")
        PULog("Returning to previous screen")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEventData()
        PULog("Displaying Event Info Page")
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
        let group: NSString? = DataManager.getEventGroup(event)
        let desc: NSString = DataManager.getEventDescription(event)
        let price: NSInteger? = DataManager.getEventPrice(event)
        let ageRestriction: NSInteger? = DataManager.getEventAgeRestriction(event)
        
        // Put information into corresponding views
        eventTitleLabel.text = eventTitle
        dateLabel.text = date
        timeLabel.text = startTime
        locationLabel.text = locationName
        descriptionLabel.text = desc
        if (group != nil) {
            groupLabel.text = group!
        } else {
            groupLabel.text = "Going solo..."
        }
        if (price != nil) {
            priceLabel.text = "This event costs $\(price) to attend."
        } else {
            priceLabel.text = "This event is free."
        }
        if (ageRestriction != nil) {
            ageRestrictionsLabel.text = "You must be at \(ageRestriction) or older to attend."
        } else {
            ageRestrictionsLabel.text = "This event is open for all ages"
        }
    }
    
    func setEventData(event: NSDictionary) {
        self.event = event
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
        let user: NSDictionary = DataManager.getEventAttendees(event)[indexPath.row] as NSDictionary
        cell.textLabel!.text = DataManager.getUserFullName(user)
        return cell
    }
    
    /* Determines what to do when a table cell is selected */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
