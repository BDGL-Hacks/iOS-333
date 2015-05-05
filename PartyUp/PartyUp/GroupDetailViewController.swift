//
//  GroupDetailViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 5/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class GroupDetailViewController: UIViewController, UIWebViewDelegate {
    
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
        
        let url: NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("test", ofType: "html")!, isDirectory: false)!
        PULog("URL: \(url.absoluteString!)")
        webView.loadRequest(NSURLRequest(URL: url))
    }
   
    
   /*--------------------------------------------*
    * UIWebViewDelegate Methods
    *--------------------------------------------*/
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url: NSURL = request.URL!
        PULog("Killing it")
        if (url.absoluteString == "http://TODO") {
            PULog("Yay!")
            return false
        }
        else {
            return true
        }
    }
    
}
