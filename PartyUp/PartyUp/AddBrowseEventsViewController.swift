//
//  AddBrowseEventsViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/22/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class AddBrowseEventsViewController: PartyUpViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate
{
    
    /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var findEventsTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    let searchEventsModel: SearchEventsModel = SearchEventsModel()
    var previousViewController: CreateGroup2ViewController?
    var createEvent: CreateModel?
    
    var findEventsQueryResults: NSArray? = NSArray()
    var searchResults: NSArray = NSArray()
    var shouldPerformQueries: Bool = true
    var selectedCellEventData: NSDictionary = NSDictionary()
    var searchBarController: UISearchController = UISearchController()
    
    /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findEventsTableView.delegate = self
        findEventsTableView.dataSource = self
        navBar.delegate = self
        
        self.findEventsTableView.rowHeight = 60
        
        // Register custon table cell
        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        findEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "eventCellPrototype")
        
        // Set up the search bar
        self.searchBarController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.findEventsTableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        findEventsTableView.tableHeaderView = searchBarController.searchBar
        findEventsTableView.reloadData()

    }
    
    /* Acquire table data from create model */
    override func viewWillAppear(animated: Bool) {
        if (shouldPerformQueries && isLoggedIn()) {
            searchEventsModel.update(SearchEventsModel.QueryType.Find)
            createEvent?.setFindQueryResults(searchEventsModel.getNearbyEvents())
            
            findEventsQueryResults = createEvent?.getFindQueryResults()
            
            shouldPerformQueries = false
            findEventsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying search public events page for group creation")
    }
    
    /* Set position of search bar */
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }

    /* Add selected events and dismiss view controller */
    @IBAction func checkmarkPressed(sender: UIBarButtonItem) {
        addEvents()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /* Dismiss view without adding events */
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
    
    /* Returns the number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchBarController.active) {
            return searchResults.count
        } else {
            return findEventsQueryResults!.count
        }
    }
    
    /* Determines how to populate each cell in the table: *
    * Loads the display and event data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("eventCellPrototype") as! PartyUpTableCell
        
        //
        var event: NSDictionary
        if (searchBarController.active) {
            event = searchResults[indexPath.row] as! NSDictionary
        }
        else {
            event = findEventsQueryResults![indexPath.row] as! NSDictionary
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
    
    /*----------------------------------------*
    * Helper methods                          *
    *-----------------------------------------*/
    
    /* Iterate through selected events and update selectedEvents array
       in the create model */
    func addEvents() {
        var selectedEvents: NSMutableArray = NSMutableArray()
        if let indexPaths = findEventsTableView.indexPathsForSelectedRows() {
            for var i = 0; i < indexPaths.count; ++i {
                var thisPath = indexPaths[i] as! NSIndexPath
                var cell = findEventsTableView.cellForRowAtIndexPath(thisPath)
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
    
    /*--------------------------------------------*
    * Search bar methods
    *--------------------------------------------*/
    
    /* Determines what to do when the table search bar is updated:    *
    * Filters the event data with the search and reloads table data. */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@ OR description CONTAINS[c] %@ or location_name CONTAINS[c] %@", searchController.searchBar.text, searchController.searchBar.text, searchController.searchBar.text)
        searchResults = findEventsQueryResults!.filteredArrayUsingPredicate(searchPredicate)
        findEventsTableView.reloadData()
    }
    
    /* Look for didSet method to implicitly add events */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
