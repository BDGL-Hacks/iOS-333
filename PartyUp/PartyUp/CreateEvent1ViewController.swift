//
//  CreateEvent1ViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class CreateEvent1ViewController: PartyUpViewController, UITextFieldDelegate // UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    
    var itemIndex: Int = 0
    //private var pageViewController: UIPageViewController?
    //private let numPages = 3
    
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var publicSwitch: UISwitch!
    var createEvent: CreateModel? = CreateModel()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var selectedDate: UILabel!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    var backendDate: String?
    var isFromGroup: Bool = false
    var previousViewController: CreateGroup2ViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // createPageViewController()
        
        // Do any additional setup after loading the view.
    }
    
    var activeTextField: UITextField? {
        get {
            if (eventTitleTextField.isFirstResponder()) {
                return eventTitleTextField
            }
            else if (locationTextField.isFirstResponder()) {
                return locationTextField
            }
            return nil
        }
        set {
            
        }
    }

    /* User changes the date in the date picker */
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        var dateStr = dateFormatter.stringFromDate(myDatePicker.date)
        selectedDate.text = dateStr
        dateFormatter.dateFormat = "YYYYMMddhhmm"
        var backendStr = dateFormatter.stringFromDate(myDatePicker.date)
        PULog(backendStr)
        backendDate = backendStr
        
    }
    
    /* User goes back to the previous screen */
    @IBAction func dismissModal(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* Tap anywhere outside text field dismisses keyboard */
    @IBAction func viewTapped(sender: AnyObject) {
        eventTitleTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (isFromGroup == true) {
            addFriendsButton.hidden = true
        }
        else {
            continueButton.hidden = true
        }
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /* Dismisses keyboard if user returns */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /* Send EventCreation object to next stage of event creation */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventCreationOneToTwo" {
            PULog("In prepare for segue")
            let destinationVC = segue.destinationViewController as! CreateEvent2ViewController
            destinationVC.createEvent = self.createEvent!
        }
    }
    
    
    /*--------------------------------------------*
    * UITextField Delegate Methods
    *--------------------------------------------*/
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        scrollView.scrollEnabled = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
        scrollView.scrollEnabled = false
    }
    
    
    
    /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    
    @IBAction func addFriendsPressed(sender: UIButton) {
        
        PULog("Add friends button pressed")
        
        // Ensure the form is valid
        var validationError: NSString? = validateForm()
        if (validationError != nil) {
            PULog("Form is invalid: \(validationError!)")
            displayAlert("Event creation failed", message: validationError!)
            return
        }
        
        var isPublic = "False"
        if publicSwitch.on {
            isPublic = "True"
        }
        
        // Retrieve all necessary fields
        var eventTitle: NSString = eventTitleTextField.text
        var eventLocation: NSString = locationTextField.text
        var eventDateTime: NSString = backendDate!
        
        createEvent!.eventFirstPage(eventTitle, location: eventLocation, dateTime: eventDateTime, eventPublic: isPublic)
    }
    
    
    @IBAction func continueButtonPressed(sender: UIButton) {
        PULog("Continue button pressed")
        
        // Ensure the form is valid
        var validationError: NSString? = validateForm()
        if (validationError != nil) {
            PULog("Form is invalid: \(validationError!)")
            displayAlert("Event creation failed", message: validationError!)
            return
        }
        
        var isPublic = "False"
        if publicSwitch.on {
            isPublic = "True"
        }
        
        // Retrieve all necessary fields
        var eventTitle: NSString = eventTitleTextField.text
        var eventLocation: NSString = locationTextField.text
        var eventDateTime: NSString = backendDate!
        
        createEvent!.eventFirstPage(eventTitle, location: eventLocation, dateTime: eventDateTime, eventPublic: isPublic)
        createEvent!.eventSecondPage(createEvent!.getInviteEmails())
    
        
        let (backendError: NSString?, eventID: NSString?) = createEvent!.eventSendToBackend()
        /* Not sure if need this code because segue is already bound to the button */
        if (backendError != nil)
        {
            displayAlert("Event creation Failed", message: backendError!)
        }
        
        // PULog("\(eventID)")
        createEvent!.updateNewlyCreatedEvents(eventID as NSString?)
        previousViewController!.updateAddedEvents(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
    
    /* Validates the form fields.         *
    * Returns an error message string    *
    * if form is invalid, nil otherwise. */
    func validateForm() -> NSString?
    {
        var eventTitle: NSString = eventTitleTextField.text
        var eventLocation: NSString = locationTextField.text
        var eventTime: NSString = selectedDate.text!
        
        if (eventTitle == "") {
            return "Event title is required."
        }
        if (eventLocation == "") {
            return "Event location is required."
        }
        if (eventTime == "Date and Time") {
            return "Date and Time is required"
        }
        return nil
    }
    
    /*--------------------------------------------*
    * Keyboard Scrolling Methods
    *--------------------------------------------*/
    
    // Code from creativecoefficient.net
    
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeShown:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWillBeShown(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize.height
        let activeTextFieldRect: CGRect? = activeTextField?.frame
        let activeTextFieldOrigin: CGPoint? = activeTextFieldRect?.origin
        if (!CGRectContainsPoint(aRect, activeTextFieldOrigin!)) {
            scrollView.scrollRectToVisible(activeTextFieldRect!, animated:true)
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(sender: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
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