//
//  HomeEventsViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class MyEventsViewController: PartyUpViewController, UITableViewDelegate, UITableViewDataSource
{
    
   /*--------------------------------------------*
    * Model and instance variables
    *--------------------------------------------*/
    
    let searchEventsModel: SearchEventsModel = SearchEventsModel()
    
    var shouldPerformQueries: Bool = true
    var selectedCellEventData: NSDictionary = NSDictionary()
    var isCreatedEvent = false
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var createdEventsLabel: UILabel!
    @IBOutlet weak var attendingEventsLabel: UILabel!
    @IBOutlet weak var invitedEventsLabel: UILabel!
    
    @IBOutlet weak var createdEventsTableView: PUDynamicTableView!
    @IBOutlet weak var attendingEventsTableView: PUDynamicTableView!
    @IBOutlet weak var invitedEventsTableView: PUDynamicTableView!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        createdEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
        attendingEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
        invitedEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (shouldPerformQueries && isLoggedIn()) {
            searchEventsModel.update(SearchEventsModel.QueryType.User)
            shouldPerformQueries = false
            updateViews()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying My Events tab")
    }
    
    /* If we are segueing to EventInfoVC, send the cell's event data beforehand */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "myEventsToEventInfo") {
            let eventInfoVC: EventInfoViewController = segue.destinationViewController
                as! EventInfoViewController
            eventInfoVC.setEventData(selectedCellEventData)
            eventInfoVC.setIsCreatedEvent(isCreatedEvent)
            isCreatedEvent = false
        }
    }
    
    
   /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Updates the views for the tables and their labels */
    func updateViews()
    {
        createdEventsTableView.reloadData()
        attendingEventsTableView.reloadData()
        invitedEventsTableView.reloadData()
        
        var isCreatedEventsTableEmpty: Bool = false
        var isAttendingEventsTableEmpty: Bool = false
        var isInvitedEventsTableEmpty: Bool = false
        
        if (createdEventsTableView.numberOfRowsInSection(0) == 0) {
            isCreatedEventsTableEmpty = true
            createdEventsTableView.hideView()
        } else {
            createdEventsTableView.showView()
        }
        
        if (attendingEventsTableView.numberOfRowsInSection(0) == 0) {
            isAttendingEventsTableEmpty = true
            attendingEventsTableView.hideView()
        } else {
            attendingEventsTableView.showView()
        }
        
        if (invitedEventsTableView.numberOfRowsInSection(0) == 0) {
            isInvitedEventsTableEmpty = true
            invitedEventsTableView.hideView()
        } else {
            invitedEventsTableView.showView()
        }
        
        if (isCreatedEventsTableEmpty && isAttendingEventsTableEmpty && isInvitedEventsTableEmpty) {
            createdEventsLabel.hidden = true
            attendingEventsLabel.hidden = true
            invitedEventsLabel.hidden = true
            placeholderLabel.hidden = false
        } else {
            createdEventsLabel.hidden = false
            attendingEventsLabel.hidden = false
            invitedEventsLabel.hidden = false
            placeholderLabel.hidden = true
        }
    }
   
    
   /*--------------------------------------------*
    * TableView methods
    *--------------------------------------------*/
    
    /* Returns the number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == createdEventsTableView) {
            return searchEventsModel.getCreatedEvents().count
        }
        else if (tableView == attendingEventsTableView) {
            return searchEventsModel.getAttendingEvents().count
        }
        else if (tableView == invitedEventsTableView) {
            return searchEventsModel.getInvitedEvents().count
        }
        else {
            PULog("Table view specified was not recognized")
            return 0
        }
    }
    
    /* Determines how to populate each cell in the table: *
     * Loads the display and event data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("partyUpTableCell") as! PartyUpTableCell
        
        var event: NSDictionary = NSDictionary()
        if (tableView == createdEventsTableView) {
            event = searchEventsModel.getCreatedEvents()[indexPath.row] as! NSDictionary
        }
        else if (tableView == attendingEventsTableView) {
            event = searchEventsModel.getAttendingEvents()[indexPath.row] as! NSDictionary
        }
        else if (tableView == invitedEventsTableView) {
            event = searchEventsModel.getInvitedEvents()[indexPath.row] as! NSDictionary
        }
        
        var dayText: NSString = DataManager.getEventDayText(event)
        var dayNumber: NSString = DataManager.getEventDayNumber(event)
        var mainText: NSString = DataManager.getEventTitle(event)
        
        var subText: NSString = ""
        if (tableView == createdEventsTableView || tableView == invitedEventsTableView) {
            subText = DataManager.getEventLocationName(event)
        }
        // TODO: Should actually be group you are going with
        else if (tableView == attendingEventsTableView) {
            subText = DataManager.getEventLocationName(event)
        }
        
        cell.loadCell(dayText: dayText, dayNumber: dayNumber, mainText: mainText, subText: subText)
        cell.setCellData(event)
        return cell
    }
    
    /* Determines what to do when a table cell is selected */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: PartyUpTableCell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpTableCell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let eventName: NSString = DataManager.getEventTitle(cell.getCellData())
        PULog("Event Cell Pressed.\nCell Row: \(indexPath.row), Event Name: \(eventName)")
        PULog("Transitioning to Event Info screen")
        selectedCellEventData = cell.getCellData()
        if tableView == createdEventsTableView {
            isCreatedEvent = true
        }
        self.performSegueWithIdentifier("myEventsToEventInfo", sender: self)
    }
    
}