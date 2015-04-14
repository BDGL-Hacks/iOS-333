//
//  FindEventsViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class FindEventsViewController: PartyUpViewController, UISearchResultsUpdating
{
   /*--------------------------------------------*
    * Model
    *--------------------------------------------*/
    
    let searchEventsModel: SearchEventsModel = SearchEventsModel()
    
    var shouldPerformQueries: Bool = true
    var selectedCellEventData: NSDictionary = NSDictionary()
    
    var searchResults: NSArray = NSArray()
    var searchBarController: UISearchController = UISearchController()
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var findEventsTableView: UITableView!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        findEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpTableCell")
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (shouldPerformQueries /* && isLoggedIn() */) {
            searchEventsModel.update(SearchEventsModel.QueryType.Find)
            shouldPerformQueries = false
            findEventsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying Find Events tab")
    }
    
    /* If we are segueing to EventInfoVC, send the cell's event data beforehand */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "findEventsToEventInfo") {
            let eventInfoVC: EventInfoViewController = segue.destinationViewController
                as EventInfoViewController
            eventInfoVC.setEventData(selectedCellEventData)
        }
    }
    
    
   /*--------------------------------------------*
    * TableView methods
    *--------------------------------------------*/
    
    /* Returns the number of sections in the table */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /* Returns the number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchBarController.active) {
            return searchResults.count
        } else {
            return searchEventsModel.getNearbyEvents().count
        }
    }
    
    /* Determines how to populate each cell in the table: *
     * Loads the display and event data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PartyUpTableCell = tableView.dequeueReusableCellWithIdentifier("partyUpTableCell") as PartyUpTableCell
        
        var event: NSDictionary
        if (searchBarController.active) {
            event = searchResults[indexPath.row] as NSDictionary
        }
        else {
            event = searchEventsModel.getNearbyEvents()[indexPath.row] as NSDictionary
        }
        
        var dayText: NSString = DataManager.getEventDayText(event)
        var dayNumber: NSString = DataManager.getEventDayNumber(event)
        var mainText: NSString = DataManager.getEventTitle(event)
        var subText: NSString = DataManager.getEventLocationName(event)
        
        cell.loadCell(dayText: dayText, dayNumber: dayNumber, mainText: mainText, subText: subText)
        cell.setCellData(event)
        return cell
    }
    
    /* Determines what to do when a table cell is selected */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: PartyUpTableCell = tableView.cellForRowAtIndexPath(indexPath) as PartyUpTableCell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let eventName: NSString = DataManager.getEventTitle(cell.getCellData())
        PULog("Event Cell Pressed.\nCell Row: \(indexPath.row), Event Name: \(eventName)")
        PULog("Transitioning to Event Info screen")
        selectedCellEventData = cell.getCellData()
        self.performSegueWithIdentifier("findEventsToEventInfo", sender: self)
    }
    
    
   /*--------------------------------------------*
    * Search bar methods
    *--------------------------------------------*/
    
    /* Determines what to do when the table search bar is updated:    *
     * Filters the event data with the search and reloads table data. */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@ OR description" + "CONTAINS[c] %@ or location_name CONTAINS[c] %@", searchController.searchBar.text, searchController.searchBar.text, searchController.searchBar.text)
        searchResults = searchEventsModel.getNearbyEvents().filteredArrayUsingPredicate(searchPredicate!)
        findEventsTableView.reloadData()
    }
    
}
