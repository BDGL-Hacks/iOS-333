//
//  GC1ViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class GC1ViewController: PartyUpViewController // UIPageViewControllerDataSource, UIPageViewControllerDelegate
{

    var itemIndex: Int = 0
    //private var pageViewController: UIPageViewController?
    //private let numPages = 3
    
    
    @IBOutlet weak var selectedDate: UILabel!

    @IBOutlet weak var myDatePicker: UIDatePicker!

    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // createPageViewController()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        var dateStr = dateFormatter.stringFromDate(myDatePicker.date)
        selectedDate.text = dateStr
    }
    
    @IBAction func dismissModal(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    private func createPageViewController() {
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("GroupController") as UIPageViewController
        pageController.dataSource = self
        
        let firstController = getItemController(0)!
        let startingViewControllers: NSArray  = [firstController]
        pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController?.didMoveToParentViewController(self)
    }
    
    /* Implemenet UIPageViewControllerDataSource Methods */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as GC1ViewController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex - 1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as GC1ViewController
        
        if itemController.itemIndex+1 < numPages {
            return getItemController(itemController.itemIndex + 1)
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> GC1ViewController? {
        
        if itemIndex < numPages {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("GroupCreation1") as GC1ViewController?
            pageItemController?.itemIndex = itemIndex
            return pageItemController
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return numPages
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

*/

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
