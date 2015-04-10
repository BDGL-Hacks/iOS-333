//
//  FindEventsViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class FindEventsViewController: PartyUpViewController
{
   /*--------------------------------------------*
    * Model
    *--------------------------------------------*/
    
    let searchEventsModel: SearchEventsModel = SearchEventsModel()
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        searchEventsModel.update(SearchEventsModel.QueryType.Find)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PULog("Displaying Find Events tab")
    }
    
}