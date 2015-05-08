//
//  CreateEvent1ViewController.swift
//  PartyUp
//
//  Created by Graham Turk on 4/2/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import UIKit

class CreateEvent1ViewController: PartyUpViewController, UITextFieldDelegate, UINavigationBarDelegate
{
    
    var itemIndex: Int = 0
    
    /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var publicSwitch: UISwitch!
    @IBOutlet weak var selectedDate: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    /*--------------------------------------------*
    * Instance variables
    *--------------------------------------------*/
    
    var backendDate: String?
    var isFromGroup: Bool = false
    var previousViewController: CreateGroup2ViewController?
    var createEvent: CreateModel? = CreateModel()
    
    /* Computed property for active text field */
    var activeTextField: UITextField? {
        get {
            if (eventTitleTextField.isFirstResponder()) {
                return eventTitleTextField
            }
            else if (locationTextField.isFirstResponder()) {
                return locationTextField
            }
            else if (descriptionTextField.isFirstResponder()) {
                return descriptionTextField
            }
            
            return nil
        }
        set {
            
        }
    }
    
    /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // createPageViewController()
        
        navBar.delegate = self
        scrollView.contentSize = scrollView.subviews[0].frame.size
        setDelegates()
    }
    
    /* Set text field delegates */
    func setDelegates() {
        descriptionTextField.delegate = self
        locationTextField.delegate = self
        eventTitleTextField.delegate = self
    }
    
    /* Set position for top naviation bar */
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    /* Dismisses keyboard when user taps return key */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /* Sets limit on maximum number of characters the user can enter into a text field */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= 100 // Bool
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
    @IBAction func dismissView(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /* Tapping anywhere outside text field dismisses keyboard */
    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        eventTitleTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        
    }
    
    /* Hide buttons depending on previous view controller */
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
    
    
    /* Send EventCreation object to next stage of event creation */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventCreationOneToTwo" {
            PULog("In prepare for segue")
            let destinationVC = segue.destinationViewController as! CreateEvent2ViewController
            destinationVC.createEvent = self.createEvent!
        }
    }
    
    /* User taps add friends button to move on to next page */
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
        var eventDescription: NSString = descriptionTextField.text
        
        createEvent!.eventFirstPage(eventTitle, location: eventLocation, dateTime: eventDateTime, eventPublic: isPublic, eventDescription: eventDescription)
        self.performSegueWithIdentifier("eventCreationOneToTwo", sender: self)
    }
    
    /* Alternate button for group creation flow. Creates event
       using emails of friends already added and information
       from this page */
    @IBAction func continueButtonPressed(sender: UIButton) {
        PULog("Continue button pressed")
        
        // Ensure the form is valid
        var validationError: NSString? = validateForm()
        if (validationError != nil) {
            PULog("Form is invalid: \(validationError!)")
            displayAlert("Some required fields left blank", message: validationError!)
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
        var eventDescription: NSString = descriptionTextField.text
        
        createEvent!.eventFirstPage(eventTitle, location: eventLocation, dateTime: eventDateTime, eventPublic: isPublic, eventDescription: eventDescription)
        createEvent!.eventSecondPage(createEvent!.getInviteIDs())
    
        
        let (backendError: NSString?, eventID: NSString?) = createEvent!.eventSendToBackend()
        if (backendError != nil)
        {
            displayAlert("Event creation Failed", message: backendError!)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        else {
            /* Update backend array and update the table of the
           previous view controller */
            createEvent!.updateNewlyCreatedEvents(eventID as NSString?)
            previousViewController!.updateAddedEvents(true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    /*--------------------------------------------*
    * View helper methods
    *--------------------------------------------*/
   
    /* Validates the form fields.         *
    * Returns an error message string    *
    * if form is invalid, nil otherwise. */
    func validateForm() -> NSString?
    {
        if (backendDate == nil) {
            return "Date and Time are required"
        }
        var eventTitle: NSString = eventTitleTextField.text
        var eventLocation: NSString = locationTextField.text
        var eventTime: NSString = backendDate!
        
        if (eventTitle == "") {
            return "Event title is required."
        }
        if (eventLocation == "") {
            return "Event location is required."
        }
        
        return nil
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}