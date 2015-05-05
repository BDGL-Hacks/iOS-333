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
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var userEventsTableView: PUDynamicTableView!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        userEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
        self.userEventsTableView.sectionHeaderHeight = 65
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
            eventInfoVC.setEventData(event: selectedCellEventData)
        }
    }
    
    
   /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Updates the views for the tables and their labels */
    func updateViews()
    {
        userEventsTableView.reloadData()
        
        if (userEventsTableView.numberOfRowsInSection(0) == 0) {
            userEventsTableView.hideView()
            placeholderLabel.hidden = false
        }
        else {
            userEventsTableView.showView()
            placeholderLabel.hidden = true
        }
    }
   
    
   /*--------------------------------------------*
    * TableView methods
    *--------------------------------------------*/
    
    /* Returns the number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchEventsModel.getAttendingEvents().count
    }
    
    /* Determines how to populate each cell in the table: *
     * Loads the display and event data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("partyUpTableCell") as! PartyUpTableCell
        
        var event: NSDictionary = searchEventsModel.getAttendingEvents()[indexPath.row] as! NSDictionary
        
        var dayText: NSString = DataManager.getEventDayText(event)
        var dayNumber: NSString = DataManager.getEventDayNumber(event)
        var mainText: NSString = DataManager.getEventTitle(event)
        var subText: NSString = DataManager.getEventLocationName(event)
        
        cell.loadCell(dayText: dayText, dayNumber: dayNumber, mainText: mainText, subText: subText)
        cell.setCellData(event)
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
        headerCell.contentView.backgroundColor = UIColorFromRGB(0xE6C973)
        headerCell.headerTextLabel.text = "My Events"
        return headerCell.contentView
    }
    
    /* Determines what to do when a table cell is selected */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: PartyUpTableCell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpTableCell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let eventName: NSString = DataManager.getEventTitle(cell.getCellData())
        PULog("Event Cell Pressed.\nCell Row: \(indexPath.row), Event Name: \(eventName)")
        PULog("Transitioning to Event Info screen")
        selectedCellEventData = cell.getCellData()
        self.performSegueWithIdentifier("myEventsToEventInfo", sender: self)
    }
    
}