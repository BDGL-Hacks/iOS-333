//
//  GroupDetailViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 5/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class GroupDetailViewController: PartyUpViewController, UIWebViewDelegate {
    
   /*--------------------------------------------*
    * Variables and Constants
    *--------------------------------------------*/
    
    var groupData: NSDictionary = NSDictionary()
    
    let homeURL: String = "http://52.4.3.6/web/groups/home"
    let pingURL: String = "http://52.4.3.6/web/groups/ping"
    var shouldUsePingURL: Bool = false
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var webView: UIWebView!
    
    
   /*--------------------------------------------*
    * View response Methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scalesPageToFit = true
        webView.contentMode = UIViewContentMode.ScaleAspectFit
        
        let loadURL: String = homeURL
        if (shouldUsePingURL) {
            let loadURL: String = pingURL
            shouldUsePingURL = false
        }
        
        if (isLoggedIn()) {
            let url: NSURL = NSURL(string: loadURL)!
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    /* If we are segueing to GroupChatVC, send the cell's group data beforehand */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "groupsDetailToGroupChat") {
            let navController: UINavigationController = segue.destinationViewController as! UINavigationController
            let groupChatVC: GroupChatViewController = navController.viewControllers[0] as! GroupChatViewController
            groupChatVC.setGroupData(groupData)
        }
        else if (segue.identifier == "groupsDetailToGroupEdit") {
            let groupEditVC: GroupInfoViewController = segue.destinationViewController as! GroupInfoViewController
            groupEditVC.setGroupData(group: groupData)
        }
        else if (segue.identifier == "groupsDetailToInviteFriends") {
            let inviteFriendsVC: InviteFriendsViewController = segue.destinationViewController as! InviteFriendsViewController
            inviteFriendsVC.setGroupData(groupData)
            inviteFriendsVC.setGroupOrEvent(false)
            inviteFriendsVC.previousViewController = self
            inviteFriendsVC.setPrev(InviteFriendsViewController.PrevType.GroupDetail)
        }
    }
    
    
   /*--------------------------------------------*
    * View response Methods
    *--------------------------------------------*/
    
    func usePingURL() {
        self.shouldUsePingURL = true
    }
    
    
   /*--------------------------------------------*
    * UIWebViewDelegate Methods
    *--------------------------------------------*/
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        let url: NSURL = request.URL!
        let urlString: NSString = url.absoluteString! as NSString
        
        PULog("Web View Load Request Detected: \(urlString)")
        
        var urlStringArray: [NSString] = urlString.componentsSeparatedByString("//") as! [NSString]
        if (urlStringArray.count != 2) {
            PULog("URL String is invalid")
            return true
        }
        
        let urlStringStripped = urlStringArray[1]
        
        urlStringArray = urlStringStripped.componentsSeparatedByString("/?") as! [NSString]
        if (urlStringArray.count != 2) {
            PULog("URL String is invalid")
            return true
        }
        
        let type: NSString = urlStringArray[0]
        let groupID: NSString = urlStringArray[1]
        PULog("Type: \(type), Group ID: \(groupID)")
        
        if (type == "groups-chat")
        {
            PULog("Transitioning to Group Chat. Group ID: \(groupID)")
            
            let (errorMessage: NSString?, group: NSDictionary?) = PartyUpBackend.instance.queryGroupSearchByID(groupID)
            if (errorMessage != nil) {
                displayAlert("Failed to get group.", message: errorMessage!)
                return false
            }
            
            groupData = group!
            self.performSegueWithIdentifier("groupsDetailToGroupChat", sender: self)
            return false
        }
        else if (type == "groups-edit")
        {
            PULog("Transition to Group Edit. Group ID: \(groupID)")
            
            let (errorMessage: NSString?, group: NSDictionary?) = PartyUpBackend.instance.queryGroupSearchByID(groupID)
            if (errorMessage != nil) {
                displayAlert("Failed to get group.", message: errorMessage!)
                return false
            }
            
            groupData = group!
            self.performSegueWithIdentifier("groupsDetailToGroupEdit", sender: self)
            return false
        }
        else if (type == "groups-invite")
        {
            PULog("Transition to Invite Friends. Group ID: \(groupID)")
            
            let (errorMessage: NSString?, group: NSDictionary?) = PartyUpBackend.instance.queryGroupSearchByID(groupID)
            if (errorMessage != nil) {
                displayAlert("Failed to get group.", message: errorMessage!)
                return false
            }
            
            groupData = group!
            self.performSegueWithIdentifier("groupsDetailToInviteFriends", sender: self)
            return false
        }
        else {
            PULog("URL String type did not match any expected types")
            return true
        }
    }
    
}
