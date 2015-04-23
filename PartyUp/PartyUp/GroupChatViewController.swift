//
//  GroupChatViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/19/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class GroupChatViewController: JSQMessagesViewController {
    
   /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var group: NSDictionary = NSDictionary()
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ba-BOMBS"
        self.senderId = "B1tch!n"
        self.senderDisplayName = "Lance Goodridge"
    }
    
    
   /*--------------------------------------------*
    * Helper methods
    *--------------------------------------------*/
    
    func setGroupData(group: NSDictionary) {
        self.group = group
    }
}
