//
//  AddChooseEventsViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/21/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class AddChooseEventsViewController: PartyUpViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {

    
  
    /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    let searchEventsModel: SearchEventsModel = SearchEventsModel()
    var attendingQueryResults: NSArray? = NSArray()
    //var invitedQueryResults: NSArray? = NSArray()
    //var ownedQueryResults: NSArray? = NSArray()
    
    var shouldPerformQueries: Bool = true
    var selectedCellEventData: NSDictionary = NSDictionary()
    var previousViewController: CreateGroup2ViewController?
    var createEvent: CreateModel?
    
    /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        navBar.delegate = self

        self.eventsTableView.rowHeight = 65
        self.eventsTableView.sectionHeaderHeight = 65
        

        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        eventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "eventCellPrototype")
    }
    
    /* Acquire table data from create model */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (shouldPerformQueries && isLoggedIn()) {
            searchEventsModel.update(SearchEventsModel.QueryType.User)
            
            /* Set all model arrays */
            createEvent?.setAttendingQueryResults(searchEventsModel.getAttendingEvents())
            //createEvent?.setInvitedQueryResults(searchEventsModel.getInvitedEvents())
            //createEvent?.setOwnedQueryResults(searchEventsModel.getCreatedEvents())
            
            attendingQueryResults = createEvent?.getAttendingQueryResults()
            //invitedQueryResults = createEvent?.getInvitedQueryResults()
            //ownedQueryResults = createEvent?.getOwnedQueryResults()
            
            shouldPerformQueries = false
            PULog("About to reload data")
            eventsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying search events page")
    }
    
    /* Set position of navigation bar */
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    // Add selected events and dismiss the view
    @IBAction func checkmarkPressed(sender: UIBarButtonItem) {
        addEvents()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Dismiss the view without adding events
    @IBAction func xButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*----------------------------------------*
     * Table view methods                     *
     *----------------------------------------*/
    
    /* Returns the number of sections in the table */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /* Returns the number of cells in each section of the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendingQueryResults!.count
    }
    
    /* Determines how to populate each cell in the table: *
    * Loads the display and event data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // PULog("In tableView reload method")
        var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("eventCellPrototype") as! PartyUpTableCell
        
        var event: NSDictionary = NSDictionary()
        event = attendingQueryResults![indexPath.row] as! NSDictionary
        
        var dayText: NSString = DataManager.getEventDayText(event)
        var dayNumber: NSString = DataManager.getEventDayNumber(event)
        var mainText: NSString = DataManager.getEventTitle(event)
        
        var subText = DataManager.getEventLocationName(event)
        
        cell.loadCell(dayText: dayText, dayNumber: dayNumber, mainText: mainText, subText: subText)
        cell.setCellData(event)
        cell.hideCheckmark()
        return cell
    }
    
    /* Determines what to do when a table cell is selected */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: PartyUpTableCell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpTableCell
        let eventName: NSString = DataManager.getEventTitle(cell.getCellData())
        PULog("Event Cell Pressed.\nCell Row: \(indexPath.row), Event Name: \(eventName)")
        selectedCellEventData = cell.getCellData()
        
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.showCheckmark()
        }
    }
    
    /* Called when user deselects a cell in the table  *
    Removes the checkmark to indiciate deselection  */
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: PartyUpTableCell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpTableCell
        let eventName: NSString = DataManager.getEventTitle(cell.getCellData())
        PULog("Event Cell deselected.\nCell Row: \(indexPath.row), Event Name: \(eventName)")
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            cell.hideCheckmark()
        }
    }
    
    /*
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsInTable[section]
    }
    */
    
    /* Determines format and content for a header cell */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
        headerCell.headerTextLabel.text = "Events"
        headerCell.backgroundColor = UIColorFromRGB(0xFFFFFF)
        headerCell.contentView.backgroundColor = UIColorFromRGB(0xFFFFFF)
        headerCell.headerTextLabel.textColor = UIColorFromRGB(0x80C8B5)
        headerCell.contentView.layer.borderColor = UIColorFromRGB(0x80C8B5).CGColor
        headerCell.contentView.layer.borderWidth = 2.0
        return headerCell
    }
    
    /*----------------------------------------*
    * Helper methods                          *
    *-----------------------------------------*/
    
    /* Adds selected events to table of added events in previous view controller */
    func addEvents() {
        var selectedEvents: NSMutableArray = NSMutableArray()
        if let indexPaths = eventsTableView.indexPathsForSelectedRows() {
            for var i = 0; i < indexPaths.count; ++i {
                var thisPath = indexPaths[i] as! NSIndexPath
                var cell = eventsTableView.cellForRowAtIndexPath(thisPath)
                if let PUCell = cell as? PartyUpTableCell {
                    var event = PUCell.getCellData()
                    selectedEvents.addObject(event)
                    PULog("\(event)")
                }
            }
        }
        
        createEvent?.setSelectedEvents(selectedEvents as NSArray)
        previousViewController?.updateAddedEvents(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
