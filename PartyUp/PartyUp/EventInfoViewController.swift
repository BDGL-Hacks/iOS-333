//
//  EventInfoViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/11/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class EventInfoViewController: PartyUpViewController {
    
   /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var event: NSDictionary = NSDictionary()
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        PULog("Back button pressed")
        PULog("Returning to previous screen")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEventData()
        PULog("Displaying Event Info Page")
    }
    
    
   /*--------------------------------------------*
    * Helper methods
    *--------------------------------------------*/
    
    /* Loads the event data into the views */
    func loadEventData() {
        PULog("Loading Event Info page data:\n\(event)")
        
        // Retrieve relevant information from event
        let eventTitle: NSString = SearchEventsModel.getEventTitle(event)
        
        // Put information into corresponding views
        eventTitleLabel.text = eventTitle
    }
    
    func setEventData(event: NSDictionary) {
        self.event = event
    }
}
