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
    * Variables
    *--------------------------------------------*/
    
    var groupData: NSDictionary = NSDictionary()
    
    
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
        
        /*
        let url: NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("test", ofType: "html")!, isDirectory: false)!
        PULog("URL: \(url.absoluteString!)")
        webView.loadRequest(NSURLRequest(URL: url))
        */
        
        let url: NSURL = NSURL(string: "http://52.4.3.6/web/groups/home")!
        webView.loadRequest(NSURLRequest(URL: url))
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
    }
   
    
   /*--------------------------------------------*
    * UIWebViewDelegate Methods
    *--------------------------------------------*/
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        let url: NSURL = request.URL!
        let urlString: NSString = url.absoluteString! as NSString
        
        PULog("WebView Load Request Detected: \(urlString)")
        
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
        else {
            PULog("URL String type did not match any expected types")
            return true
        }
    }
    
}
