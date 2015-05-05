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
    //private var pageViewController: UIPageViewController?
    //private let numPages = 3
    
    
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var publicSwitch: UISwitch!
    var createEvent: CreateModel? = CreateModel()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    var backendDate: String?
    var isFromGroup: Bool = false
    var previousViewController: CreateGroup2ViewController?
    @IBOutlet weak var selectedDate: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // createPageViewController()
        // Do any additional setup after loading the view.
        navBar.delegate = self
        scrollView.contentSize = scrollView.subviews[0].frame.size
        setDelegates()
    }
    
    func setDelegates() {
        descriptionTextField.delegate = self
        locationTextField.delegate = self
        eventTitleTextField.delegate = self
    }
    
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
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
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
    
    
    /* Tap anywhere outside text field dismisses keyboard */
   
    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        eventTitleTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        
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
        /* Not sure if need this code because segue is already bound to the button */
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
    
    
    
    
    /* DatePicker Table View Methods */
    
    /*
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var numberOfRows = tableData!.count
        
        if hasInlineTableViewCell() {
            numberOfRows += 1
        }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var dataRow = indexPath.row
        
        if selectedIndexPath != nil && selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row < indexPath.row {
            dataRow -= 1;
        }
        
        
        // Configure the cell...
        var rowData = tableData![dataRow]
        let title = rowData["title"]! as! String
        let type = rowData["type"]! as! String
        if selectedIndexPath != nil && selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row == indexPath.row - 1 {
            
                if type == "datepicker" {
                    let datePickerCell = tableView.dequeueReusableCellWithIdentifier("DatePickerCell", forIndexPath: indexPath) as! DatePickerCell
                
                    datePickerCell.datePicker.addTarget(self, action:"handleDatePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
                
                    if title == "StartDate" {
                        datePickerCell.datePicker.datePickerMode = .DateAndTime
                    }
                   
                
                    if let date :AnyObject = rowData["value"] {
                        datePickerCell.datePicker.setDate(date as! NSDate, animated: true)
                    }
                
                    return datePickerCell
                }
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NormalCell", forIndexPath: indexPath) as! UITableViewCell
        
        
        cell.textLabel!.text = title
        if let valueOfRow: AnyObject = rowData["value"] {
            if title == "StartTime" {
                dateFormatter!.dateStyle = .FullStyle
                dateFormatter!.dateFormat = "hh:mm a"
                cell.detailTextLabel!.text = dateFormatter!.stringFromDate(valueOfRow as! NSDate)
                
                /* Fill backend string */
                dateFormatter!.dateFormat = "YYYYMMddhhmm"
                var backendStr = dateFormatter!.stringFromDate(valueOfRow as! NSDate)
                PULog(backendStr)
                backendDate = backendStr
            
            }
            else {
                cell.detailTextLabel!.text = valueOfRow as? String
            }
        }
        else {
            cell.detailTextLabel!.text = "Any"
        }
        
        return cell
    }
    
        
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var heightForRow :CGFloat = 44.0
        if selectedIndexPath != nil && selectedIndexPath!.section == indexPath.section
            && selectedIndexPath!.row == indexPath.row - 1 {
                heightForRow = 216.0
        }
            
        return heightForRow
    }
        
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        PULog("Cell selected")
        var dataRow = indexPath.row
        if selectedIndexPath != nil && selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row < indexPath.row {
                dataRow -= 1
        }
            
        var rowData = tableData![dataRow]
        var type = rowData["type"]! as! String
        if type != "normal" {
            displayOrHideInlinePickerViewForIndexPath(indexPath)
        }
            
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
        
    func displayOrHideInlinePickerViewForIndexPath(indexPath: NSIndexPath!) {
        
        datePickerTableView.beginUpdates()
            
        if selectedIndexPath == nil {
            
            selectedIndexPath = indexPath
            datePickerTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)], withRowAnimation: .Fade)
            
        } else if selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row == indexPath.row {
            
            datePickerTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)], withRowAnimation: .Fade)
            selectedIndexPath = nil
            
        } else if selectedIndexPath!.section != indexPath.section || selectedIndexPath!.row != indexPath.row {
            
            datePickerTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: selectedIndexPath!.row + 1, inSection: selectedIndexPath!.section)], withRowAnimation: .Fade)
            
            // After the deletion operation the then indexPath of original table view changed to the resulting table view
            if (selectedIndexPath!.section == indexPath.section && selectedIndexPath!.row < indexPath.row) {
                
                datePickerTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)], withRowAnimation: .Fade)
                selectedIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
                
            } else {
                
                datePickerTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)], withRowAnimation: .Fade)
                selectedIndexPath = indexPath
            }
        }
        
        
        
        datePickerTableView.endUpdates()
    }
        
    func hasInlineTableViewCell() -> Bool {
            return !(self.selectedIndexPath == nil)
    }
        
    func handleDatePickerValueChanged(datePicker: UIDatePicker!) {
        var index = selectedIndexPath!.row
        var rowData = tableData![index]
        rowData["value"] = datePicker.date
        if var tmpArray = tableData {
            tmpArray[index] = rowData
            tableData = tmpArray
        }
            
        datePickerTableView.reloadRowsAtIndexPaths([selectedIndexPath!], withRowAnimation: .Fade)
    }
    
    */
    

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