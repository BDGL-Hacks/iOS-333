//
//  AlertsViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/30/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class AlertsViewController: PartyUpViewController, UITableViewDelegate, UITableViewDataSource
{
    
   /*--------------------------------------------*
    * Model and instance variables
    *--------------------------------------------*/
    
    let alertsModel: AlertsModel = AlertsModel.instance
    
    var shouldPerformQueries: Bool = true
    var selectedCellData: NSDictionary = NSDictionary()
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var checkUpAlertsLabel: UILabel!
    @IBOutlet weak var groupInvitesLabel: UILabel!
    @IBOutlet weak var eventInvitesLabel: UILabel!
    
    @IBOutlet weak var checkUpAlertsTableView: PUDynamicTableView!
    @IBOutlet weak var groupInvitesTableView: PUDynamicTableView!
    @IBOutlet weak var eventInvitesTableView: PUDynamicTableView!
   
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var customTableCellNib: UINib = UINib(nibName: "PartyUpAlertCell", bundle: nil)
        checkUpAlertsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpAlertCell")
        groupInvitesTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpAlertCell")
        eventInvitesTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "partyUpAlertCell")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateViews", name: alertsModel.getUpdateNotificationName() as String, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayResponseFailedAlert", name: alertsModel.getErrorNotificationName() as String, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (shouldPerformQueries && isLoggedIn()) {
            alertsModel.update()
            shouldPerformQueries = false
            updateViews()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying Alerts Page")
    }
    
    /* Sends data to the appropiate view controller before segue */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "alertsToEventInfo") {
            let eventInfoVC: EventInfoViewController = segue.destinationViewController
                as! EventInfoViewController
            eventInfoVC.setEventData(event: selectedCellData)
        }
        else if (segue.identifier == "alertsToGroupInfo") {
            // TODO
        }
    }
   
    
   /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Updates the views for the tables and their labels */
    func updateViews()
    {
        checkUpAlertsTableView.reloadData()
        groupInvitesTableView.reloadData()
        eventInvitesTableView.reloadData()
        
        var isCheckUpAlertsTableEmpty: Bool = false
        var isGroupInvitesTableEmpty: Bool = false
        var isEventInvitesTableEmpty: Bool = false
        
        if (checkUpAlertsTableView.numberOfRowsInSection(0) == 0) {
            isCheckUpAlertsTableEmpty = true
            checkUpAlertsTableView.hideView()
        } else {
            checkUpAlertsTableView.showView()
        }
        
        if (groupInvitesTableView.numberOfRowsInSection(0) == 0) {
            isGroupInvitesTableEmpty = true
            groupInvitesTableView.hideView()
        } else {
            groupInvitesTableView.showView()
        }
        
        if (eventInvitesTableView.numberOfRowsInSection(0) == 0) {
            isEventInvitesTableEmpty = true
            eventInvitesTableView.hideView()
        } else {
            eventInvitesTableView.showView()
        }
        
        if (isCheckUpAlertsTableEmpty && isGroupInvitesTableEmpty && isEventInvitesTableEmpty) {
            checkUpAlertsLabel.hidden = true
            groupInvitesLabel.hidden = true
            eventInvitesLabel.hidden = true
            placeholderLabel.hidden = false
        } else {
            checkUpAlertsLabel.hidden = false
            groupInvitesLabel.hidden = false
            eventInvitesLabel.hidden = false
            placeholderLabel.hidden = true
        }
    }
    
    /* Displays an alert for the user if invite / checkup response failed */
    func displayResponseFailedAlert() {
        displayAlert("Unable to send response", message: "Failed to connect to server")
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
        if (tableView == checkUpAlertsTableView) {
            return alertsModel.getPingResults().count
        }
        else if (tableView == groupInvitesTableView) {
            return alertsModel.getGroupInvites().count
        }
        else if (tableView == eventInvitesTableView) {
            return alertsModel.getEventInvites().count
        }
        else {
            PULog("Table view specified was not recognized")
            return 0
        }
    }
    
    /* Determines how to populate each cell in the table: *
     * Loads the alert or invite data into each cell.     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: PartyUpAlertCell = tableView.dequeueReusableCellWithIdentifier("partyUpAlertCell") as! PartyUpAlertCell
        
        var data: NSDictionary = NSDictionary()
        var type: AlertsModel.AlertType = AlertsModel.AlertType.CheckUp
        var contentText: NSString = ""
        var index: NSInteger = indexPath.row
        
        if (tableView == checkUpAlertsTableView) {
            data = alertsModel.getPingResults()[indexPath.row] as! NSDictionary
            type = AlertsModel.AlertType.CheckUp
            contentText = "Are you okay?"
        }
        else if (tableView == groupInvitesTableView) {
            data = alertsModel.getGroupInvites()[indexPath.row] as! NSDictionary
            type = AlertsModel.AlertType.GroupInvite
            contentText = DataManager.getGroupTitle(data)
        }
        else if (tableView == eventInvitesTableView) {
            data = alertsModel.getEventInvites()[indexPath.row] as! NSDictionary
            type = AlertsModel.AlertType.EventInvite
            contentText = DataManager.getEventTitle(data)
        }
        
        cell.loadCell(data, type: type, contentText: contentText, index: index)
        return cell
    }
    
    /* Determines what to do when a table cell is selected */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell: PartyUpAlertCell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpAlertCell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (tableView == checkUpAlertsTableView) {
            PULog("Check Up Table cell Pressed: Cell Row \(indexPath.row)")
        }
        else if (tableView == groupInvitesTableView) {
            let groupName: NSString = DataManager.getGroupTitle(cell.getCellData())
            PULog("Group Cell Pressed.\nCell Row: \(indexPath.row), Group Name:")
            PULog("Transitioning to Group Info screen")
            selectedCellData = cell.getCellData()
            // TODO: Segue to Group Info screen
        }
        else if (tableView == eventInvitesTableView) {
            let eventName: NSString = DataManager.getEventTitle(cell.getCellData())
            PULog("Event Cell Pressed.\nCell Row: \(indexPath.row), Event Name: \(eventName)")
            PULog("Transitioning to Event Info screen")
            selectedCellData = cell.getCellData()
            self.performSegueWithIdentifier("alertsToEventInfo", sender: self)
        }
    }
    
}