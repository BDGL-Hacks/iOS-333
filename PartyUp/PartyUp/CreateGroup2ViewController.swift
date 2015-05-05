//
//  CreateGroup2ViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/20/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class CreateGroup2ViewController: PartyUpViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate {
    
    var createGroup: CreateModel?
    var group: NSDictionary?
    var addedEvents: NSMutableArray? = NSMutableArray()
    @IBOutlet weak var addedEventsTableView: UITableView!
    var fromGroupInfo = false
        
    @IBOutlet weak var navBar: UINavigationBar!
    /* Set up the table and fetch data from create model */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.delegate = self
        addedEventsTableView.delegate = self
        addedEventsTableView.dataSource = self
        
        
        self.addedEventsTableView.rowHeight = 65
        self.addedEventsTableView.sectionHeaderHeight = 65
        
        addedEvents?.addObjectsFromArray(createGroup!.getGroupEvents() as [AnyObject])
        
        var customTableCellNib: UINib = UINib(nibName: "PartyUpTableCell", bundle: nil)
        addedEventsTableView.registerNib(customTableCellNib, forCellReuseIdentifier: "eventCellPrototype")
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (isLoggedIn()) {
            addedEventsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying create group 2 page")
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    func setGroupData(group: NSDictionary) {
        self.group = group
        createGroup = CreateModel()
    }
    
    func setIsFromGroupInfo(fromGroupInfo: Bool) {
        self.fromGroupInfo = fromGroupInfo
    }

    /* Store added events in create model and dismiss view */
    
    /* User presses checkmark and execute segue */
    
    @IBAction func checkmarkPressed(sender: UIBarButtonItem) {
        if (fromGroupInfo) {
            self.performSegueWithIdentifier("createGroup2ToGroupInfo", sender: self)
        }
        else {
            self.performSegueWithIdentifier("createGroup2ToHome", sender: self)
        }
    }
    
    
    
    @IBAction func backToLastPage(sender: UIBarButtonItem) {
        PULog("Going back to first group creation page")
        if (!fromGroupInfo) {
            var eventsList = addedEvents! as NSArray
            createGroup?.setGroupEvents(eventsList)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    /* Prepare for segues */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "createGroup2ToCreateEvent" {
            let destinationVC = segue.destinationViewController as! CreateEvent1ViewController
            destinationVC.createEvent = self.createGroup!
            destinationVC.previousViewController = self
            destinationVC.isFromGroup = true
        }
        else if segue.identifier == "createGroup2ToSearchEvents" {
            let destinationVC = segue.destinationViewController as! AddChooseEventsViewController
            destinationVC.createEvent = self.createGroup!
            destinationVC.previousViewController = self
        }
        else if segue.identifier == "createGroup2ToBrowseEvents" {
            let destinationVC = segue.destinationViewController as! AddBrowseEventsViewController
            destinationVC.createEvent = self.createGroup!
            destinationVC.previousViewController = self
        }
        else if segue.identifier == "createGroup2ToHome" {
            finalizeGroup()
        }
        else if segue.identifier == "createGroup2ToGroupInfo" {
            PULog("Preparing for segue")
            finalizeGroup()
            let destinationVC = segue.destinationViewController as! GroupInfoViewController
            var groupID = "\(DataManager.getGroupID(group!))"
            destinationVC.setGroupData(groupID: groupID)
        }
    }
    
    /* Iterate through events and send event IDs to create model.
       Call method to create the group and report an error if 
       something went wrong */
    func finalizeGroup() {
        PULog("Finalize event pressed")
        
        var eventIDs: [NSString] = [NSString]()
        for var j = 0; j < addedEventsTableView.numberOfSections(); ++j {
            for var i = 0; i < addedEventsTableView.numberOfRowsInSection(j); ++i {
                
                var indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: j)
                var cell = addedEventsTableView.cellForRowAtIndexPath(indexPath)
                if let PUCell = cell as? PartyUpTableCell {
                    var event = PUCell.getCellData()
                    var eventID = DataManager.getEventID(event)
                    eventIDs.append("\(eventID)" as NSString)
                }
                
            }
        }
        
        /* Check that friends list was actually populated
        for event in eventIDs {
            PULog(event)
        }
        */
        
        
        
        /* Send to backend */
        if (fromGroupInfo) {
            var groupID: NSString = "\(DataManager.getGroupID(group!))"
            var backendError: NSString? = createGroup!.addEventsToGroup(groupID, eventIDs: eventIDs)
            if (backendError != nil) {
                displayAlert("Group Update Failed", message: backendError!)
            }
        }
            
        else {
            createGroup?.groupSecondPage(eventIDs)
        
            var backendError: NSString? = createGroup?.groupSendToBackend()
        
            /* Not sure if need this code because segue is already bound to the button */
            if (backendError != nil)
            {
                displayAlert("Group creation Failed", message: backendError!)
            
            }
        }

    }
    
    
    /* Called by other views to update the table based 
       on user additions */
    func updateAddedEvents(eventNewlyCreated: Bool) {
        
        var eventsToAdd: NSArray?
        
        if (eventNewlyCreated == true) {
            eventsToAdd = createGroup!.getNewlyCreatedEvents()
            
        }
        else {
            eventsToAdd = createGroup!.getSelectedEvents()
        }
        
        addedEvents?.addObjectsFromArray(eventsToAdd! as [AnyObject])
        createGroup?.setGroupEvents(addedEvents! as NSArray)
        addedEventsTableView.reloadData()
    }
    
    
    /* Return number of sections in the table */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /* Return number of cells in the table */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedEvents!.count
    }
    
    /* Determines how to populate each cell in the table: *
    * Loads the display and event data into each cell.   */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCellPrototype") as! PartyUpTableCell
        
        var event: NSDictionary = NSDictionary()
        event = addedEvents![indexPath.row] as! NSDictionary
        
        var dayText: NSString = DataManager.getEventDayText(event)
        var dayNumber: NSString = DataManager.getEventDayNumber(event)
        var mainText: NSString = DataManager.getEventTitle(event)
        var subText = DataManager.getEventLocationName(event)
        
        cell.loadCell(dayText: dayText, dayNumber: dayNumber, mainText: mainText, subText: subText)
        cell.setCellData(event)
        cell.accessoryType = UITableViewCellAccessoryType.None
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderTableViewCell
        headerCell.contentView.backgroundColor = UIColorFromRGB(0xE6C973)
        headerCell.headerTextLabel.text = "Added Events (swipe to delete)";
        return headerCell.contentView
    }
    
    /* Allows user to swipe to delete added events */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            addedEvents!.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /* Determines what to do when user taps on a cell in the table */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: PartyUpTableCell = tableView.cellForRowAtIndexPath(indexPath) as! PartyUpTableCell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
