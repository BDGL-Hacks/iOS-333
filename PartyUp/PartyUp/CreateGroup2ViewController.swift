//
//  CreateGroup2ViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/20/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class CreateGroup2ViewController: PartyUpViewController, UITableViewDataSource, UITableViewDelegate {

    var createGroup: CreateModel?
    var addedEvents: NSMutableArray? = NSMutableArray()
    @IBOutlet weak var addedEventsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addedEventsTableView.delegate = self
        addedEventsTableView.dataSource = self
        
        self.addedEventsTableView.rowHeight = 60
        
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

    @IBAction func backToGroup1(sender: UIButton) {
        PULog("Going back to first group creation page")
        var eventsList = addedEvents! as NSArray
        createGroup?.setGroupEvents(eventsList)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
        else if segue.identifier == "GroupCreation2ToHome" {
            PULog("Preparing for segue")
            let destinationVC = segue.destinationViewController as! HomepageViewController
            destinationVC.setActiveView(HomepageViewController.NavView.Groups)
        }
    }
    
    
    @IBAction func finalizeGroup(sender: UIButton) {
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
        
        /* Check that friends list was actually populated */
        for event in eventIDs {
            PULog(event)
        }
        
        /* Send to backend */
        
        createGroup?.groupSecondPage(eventIDs)
        
        var backendError: NSString? = createGroup?.groupSendToBackend()
        
        /* Not sure if need this code because segue is already bound to the button */
        if (backendError != nil)
        {
            displayAlert("Group creation Failed", message: backendError!)
            // self.performSegueWithIdentifier("GroupCreation2ToHome", sender: self)
        }
            /*
        else {
            // self.performSegueWithIdentifier("GroupCreation2ToHome", sender: self)
        }
        */

    }
    
    
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
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedEvents!.count
    }
    
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
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            addedEvents!.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
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