//
//  MasterViewController.swift
//  PartyUp
//
//  Created by Lance Goodridge on 5/3/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

// Tracks whether the side menu is expanded or collapsed
enum SlideOutState {
    case Collapsed
    case Expanded
}

class MasterViewController: PartyUpViewController, HomepageViewControllerDelegate, UIGestureRecognizerDelegate {
    
   /*--------------------------------------------*
    * Variables and Declarations
    *--------------------------------------------*/
    
    var homepageNavigationController: UINavigationController!
    var homepageViewController: HomepageViewController!
    
    var sideMenuViewController: SideMenuViewController?
    
    // Stores whether the side menu is expanded / collapsed and 
    // if the homepage view controller should display a shadow
    var currentState: SlideOutState = .Collapsed {
        didSet {
            let shouldShowShadow = (currentState != .Collapsed)
            showShadowForHomepageViewController(shouldShowShadow)
        }
    }
    
    // Stores how far "indented" the side menu should be displayed
    let sideMenuExpandedOffset: CGFloat = 60
    
    
   /*--------------------------------------------*
    * View Response Properties
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homepageViewController = UIStoryboard.homepageViewController()
        homepageViewController.delegate = self
        
        // Make HomepageViewController the main view
        self.view.addSubview(homepageViewController.view)
        self.addChildViewController(homepageViewController)
        homepageViewController.didMoveToParentViewController(self)
        
        // Give the homepage a gesture recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        homepageViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    
   /*--------------------------------------------*
    * HomepageViewControllerDelegate Methods
    *--------------------------------------------*/
    
    func showSideMenu() {
        currentState = .Expanded
        addSideMenuViewController()
        animateSideMenu(shouldExpand: true)
    }
    
    func hideSideMenu() {
        currentState = .Collapsed
        animateSideMenu(shouldExpand: false)
    }
    
    func toggleSideMenu() {
        if (currentState == .Expanded) {
            PULog("Hiding side menu")
            hideSideMenu()
        } else {
            PULog("Showing side menu")
            showSideMenu()
        }
    }
    
    
   /*--------------------------------------------*
    * Menu Management Helper Methods
    *--------------------------------------------*/
    
    func addSideMenuViewController() {
        if (sideMenuViewController == nil) {
            sideMenuViewController = UIStoryboard.sideMenuViewController()
            addChildSideMenuController(sideMenuViewController!)
        }
    }
    
    func addChildSideMenuController(sideMenuController: SideMenuViewController) {
        sideMenuController.delegate = homepageViewController
        view.insertSubview(sideMenuController.view, atIndex: 0)
        self.addChildViewController(sideMenuController)
        sideMenuController.didMoveToParentViewController(self)
    }
    
    
   /*--------------------------------------------*
    * Menu UI Helper Methods
    *--------------------------------------------*/
    
    func animateSideMenu(#shouldExpand: Bool) {
        if (sideMenuViewController != nil) {
            if (shouldExpand) {
                currentState = .Expanded
                animateCenterPanelXPosition(targetPosition: -CGRectGetWidth(homepageViewController.view.frame) + sideMenuExpandedOffset)
            }
            else {
                animateCenterPanelXPosition(targetPosition: 0) { _ in
                    self.currentState = .Collapsed
                    self.sideMenuViewController!.view.removeFromSuperview()
                    self.sideMenuViewController = nil;
                }
            }
        }
    }
    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.homepageViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForHomepageViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            homepageViewController.view.layer.shadowOpacity = 0.8
        } else {
            homepageViewController.view.layer.shadowOpacity = 0.0
        }
    }
   
    
   /*--------------------------------------------*
    * UIGestureRecognizerDelegate Methods
    *--------------------------------------------*/
    
    /* Hide side menu if the user pans left */
    func handlePanGesture(recognizer: UIPanGestureRecognizer)
    {
        if (currentState == .Expanded) {
            let gestureIsDraggingFromLeftToRight: Bool = (recognizer.velocityInView(view).x > 0)
            switch (recognizer.state) {
                case .Changed:
                    recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                    recognizer.setTranslation(CGPointZero, inView: view)
                case .Ended:
                    if (sideMenuViewController != nil) {
                        let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
                        animateSideMenu(shouldExpand: hasMovedGreaterThanHalfway)
                    }
                default:
                    break
            }
        }
    }
    
}

/* Extension for Storyboard that gives us access to some helpful custom methods */
private extension UIStoryboard
{
    /* Returns the main (and only) storyboard */
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    /* Returns the homepage view controller */
    class func homepageViewController() -> HomepageViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("HomepageViewController") as! HomepageViewController
    }
    
    /* Returns the side menu view controller */
    class func sideMenuViewController() -> SideMenuViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SideMenuViewController") as! SideMenuViewController
    }
}
