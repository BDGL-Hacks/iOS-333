//
//  AddChooseEventsViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/21/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class AddChooseEventsViewController: PartyUpViewController, UITableViewDelegate, UITableViewDataSource {

    
    /* Constants for section numbers */
    let Owned = 0
    let Attending = 1
    let Invited = 2
    
    /* Table section names */
    var sectionsInTable = ["Owned", "Invited", "Attending"]
    
    let searchEventsModel: SearchEventsModel = SearchEventsModel()
    var ownedQueryResults: NSArray? = NSArray()
    var attendingQueryResults: NSArray? = NSArray()
    var invitedQueryResults: NSArray? = NSArray()
    
    var shouldPerformQueries: Bool = true
    var selectedCellEventData: NSDictionary = NSDictionary()
    var previousViewController: CreateGroup2ViewController?
    var createEvent: CreateModel?
    
    @IBOutlet weak var eventsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self

        self.eventsTableView.rowHeight = 60
        

        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        eventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "eventCellPrototype")
        // Do any additional setup after loading the view.
    }
    
    // Acquire table data from create model
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (shouldPerformQueries && isLoggedIn()) {
            searchEventsModel.update(SearchEventsModel.QueryType.User)
            
            /* Set all model arrays */
            //createEvent?.setOwnedQueryResults(searchEventsModel.getCreatedEvents())
            createEvent?.setAttendingQueryResults(searchEventsModel.getAttendingEvents())
            //createEvent?.setInvitedQueryResults(searchEventsModel.getInvitedEvents())
            
            ownedQueryResults = createEvent?.getOwnedQueryResults()
            attendingQueryResults = createEvent?.getAttendingQueryResults()
            invitedQueryResults = createEvent?.getInvitedQueryResults()
            
            shouldPerformQueries = false
            PULog("About to reload data")
            eventsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying search events page")
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
        return 3
    }
    
    /* Returns the number of cells in each section of the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Owned {
            // PULog("Section: \(section) and NumEvents: \(searchEventsModel.getCreatedEvents().count)")
            return ownedQueryResults!.count
        }
        else if section == Attending {
            return attendingQueryResults!.count
        }
        else if section == Invited {
            return invitedQueryResults!.count
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
        // PULog("In tableView reload method")
        var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("eventCellPrototype") as! PartyUpTableCell
        
        var event: NSDictionary = NSDictionary()
        if (indexPath.section == Owned) {
            event = ownedQueryResults![indexPath.row] as! NSDictionary
        }
        else if (indexPath.section == Attending) {
            event = attendingQueryResults![indexPath.row] as! NSDictionary
        }
        else if (indexPath.section == Invited) {
            event = invitedQueryResults![indexPath.row] as! NSDictionary
        }
        
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
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
        headerCell.backgroundColor = UIColorFromRGB(0xE6C973)
        headerCell.headerTextLabel.text = sectionsInTable[section]
        return headerCell
    }
    
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
        // PULog("\(createEvent?.getSelectedEvents())")
        previousViewController?.updateAddedEvents(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
