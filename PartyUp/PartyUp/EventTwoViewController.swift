//
//  EventTwoViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/6/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class EventTwoViewController: PartyUpViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    var create: EventCreation?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendsLabel: UILabel!
    
    var searchActive : Bool = false
    var fakeData = ["Blake Lawson","Graham Turk","Lance Goodridge","David Gilhooley","Alan Turing","Bob Dondero","Brian Kernighan"]
    var fakeBools = [false, false, false, false, false, false, false]
    var filtered:[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        
        //mySwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backToFirst(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func createEvent(sender: UIButton) {
        
        /* Iterate through friends list and send it to the backend */
        var cells = [NSMutableArray]()
        for var j = 0; j < tableView.numberOfSections(); ++j {
            for var i = 0; i < tableView.numberOfRowsInSection(j); ++i {
                
                var indexPath: NSIndexPath = NSIndexPath(forRow: i,inSection: j)
                var cell = tableView.cellForRowAtIndexPath(indexPath)
                
                //var sview = cell.accessoryView as UISwitch
                //if sview.isOn() {
                   // cells.addObject(cell)
                //}
            }
        }
        
        /*
        for c in cells {
            friends.append(c.textLabel)
        }
        
        
        
        create.secondPage(friends)
        
        var backendError: NSString? = create?.sendToBackend()
        if (backendError == nil)
        {
            
            self.performSegueWithIdentifier("eventCreationTwoToHome", sender: self)
        }
        else {
            displayAlert("Event creation Failed", message: backendError!)
            self.performSegueWithIdentifier("eventCreationTwoToHome", sender: self)
        }
        */
    }
    
    /*
    func stateChanged(switchState: UISwitch) {
        if switchState.on {
            friendsLabel.text = "The Switch is On"
        } else {
            friendsLabel.text = "The Switch is Off"
        }
    }
    */
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = fakeData.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return fakeData.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell;
        
        /*
        var switchview = UISwitch(frame: CGRectZero)
        cell.accessoryView = switchview;
        */
        
        if(searchActive){
            cell.textLabel?.text = filtered[indexPath.row]
        } else {
            cell.textLabel?.text = fakeData[indexPath.row];
        }
        
        return cell;
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
