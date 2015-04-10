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
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var createdEventsTableView: UITableView!
    @IBOutlet weak var attendingEventsTableView: UITableView!
    @IBOutlet weak var invitedEventsTableView: UITableView!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        createdEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
        
        // TODO: UNCOMMENT THESE
        //attendingEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
        //invitedEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (shouldPerformQueries && isLoggedIn()) {
            searchEventsModel.update(SearchEventsModel.QueryType.User)
            shouldPerformQueries = false
            createdEventsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying My Events tab")
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
    
    /* Determines how to populate each cell in the table */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->UITableViewCell {
        var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("partyUpTableCell") as PartyUpTableCell
        
        var event: NSDictionary = NSDictionary()
        if (tableView == createdEventsTableView) {
            event = searchEventsModel.getCreatedEvents()[indexPath.row] as NSDictionary
        }
        else if (tableView == attendingEventsTableView) {
            event = searchEventsModel.getAttendingEvents()[indexPath.row] as NSDictionary
        }
        else if (tableView == invitedEventsTableView) {
            event = searchEventsModel.getInvitedEvents()[indexPath.row] as NSDictionary
        }
        
        var dayText: NSString = SearchEventsModel.getEventDayText(event)
        var dayNumber: NSString = SearchEventsModel.getEventDayNumber(event)
        var mainText: NSString = SearchEventsModel.getEventTitle(event)
        
        var subText: NSString = ""
        if (tableView == createdEventsTableView || tableView == invitedEventsTableView) {
            subText = SearchEventsModel.getEventLocationName(event)
        }
        // TODO: Should actually be group you are going with
        else if (tableView == attendingEventsTableView) {
            subText = SearchEventsModel.getEventLocationName(event)
        }
        
        cell.loadCell(dayText: dayText, dayNumber: dayNumber, mainText: mainText, subText: subText)
        return cell
    }
    
    /* Determines what to do when a table cell is selected */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        PULog("Cell selected: \(indexPath.row)")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}