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
    
    var groupChatModel: GroupChatModel = GroupChatModel()
    
    
   /*--------------------------------------------*
    * UI Components
    *--------------------------------------------*/
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var groupTitleLabel: UILabel!
    
    
   /*--------------------------------------------*
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = groupChatModel.getGroupTitle() as String
        
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userID: NSInteger = userDefaults.objectForKey("USER_ID") as! NSInteger
        let userFullName: NSString = userDefaults.objectForKey("USER_FULL_NAME") as! NSString
        
        PULog("ID: \(userID), Name: \(userFullName)")
        
        self.senderId = "\(userID)"
        self.senderDisplayName = userFullName as String
        
        self.navigationItem.title = groupChatModel.getGroupTitle() as String
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonPressed:")
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        automaticallyScrollsToMostRecentMessage = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newPusherMessageCallback:", name: groupChatModel.getNotificationName() as String, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let errorMessage: NSString? = groupChatModel.resetMessages()
        updateCollectionView(errorMessage: errorMessage)
    }
    
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem!) {
        PULog("Back button pressed")
        PULog("Returning to previous screen")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
   /*--------------------------------------------*
    * Helper methods
    *--------------------------------------------*/
    
    func newPusherMessageCallback(sender: AnyObject) {
        PULog("New pusher message detected!")
        let errorMessage: NSString? = groupChatModel.getMostRecentMessages()
        updateCollectionView(errorMessage: errorMessage)
        finishReceivingMessage()
    }
    
    /* Updates the collection view. Optionally accepts an error message. */
    func updateCollectionView(errorMessage: NSString? = nil) {
        if (errorMessage != nil) {
            displayAlert("Failed to retrieve group messages.", message: errorMessage!)
        }
        self.collectionView.reloadSections(NSIndexSet(index: 0))
    }
    
    /* Displays an alert with the provided title and message */
    func displayAlert(title: NSString, message: NSString, buttonText: NSString = "OK") {
        var alertView: UIAlertView = UIAlertView()
        alertView.title = title as String
        alertView.message = message as String
        alertView.delegate = self
        alertView.addButtonWithTitle(buttonText as String)
        alertView.show()
    }
    
    
   /*--------------------------------------------*
    * Set methods
    *--------------------------------------------*/
    
    func setGroupData(group: NSDictionary) {
        groupChatModel.setGroupData(group)
    }
    
    
   /*--------------------------------------------*
    * JSQMessagesViewController action methods
    *--------------------------------------------*/
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        PULog("Send button pressed")
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        var errorMessage: NSString? = groupChatModel.sendMessage(text)
        if (errorMessage != nil) {
            displayAlert("Message failed to send.", message: errorMessage!)
        }
        errorMessage = groupChatModel.getMostRecentMessages()
        updateCollectionView(errorMessage: errorMessage)
        finishSendingMessage()
    }
    
    
   /*--------------------------------------------*
    * JSQMessagesViewController collection methods
    *--------------------------------------------*/
    
    /* Return the number of currently stored messages */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupChatModel.getGroupMessages().count
    }
    
    /* Return the message to use for each index */
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return groupChatModel.getGroupMessageAtIndex(indexPath.item)
    }
    
    /* Return the avatar image for each message */
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    /* Determine what cell properties to use for each message */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message: JSQMessage = groupChatModel.getGroupMessageAtIndex(indexPath.item)
        if (groupChatModel.messageWasSentByUser(message)) {
            cell.textView.textColor = UIColor.whiteColor()
        } else {
            cell.textView.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    /* Determine which message bubble image to use */
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let message: JSQMessage = groupChatModel.getGroupMessageAtIndex(indexPath.item)
        if (groupChatModel.messageWasSentByUser(message)) {
            return groupChatModel.getOutgoingBubbleImage()
        } else {
            return groupChatModel.getIncomingBubbleImage()
        }
    }
    
    /* Show sender's name for incoming messages */
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString!
    {
        let message: JSQMessage = groupChatModel.getGroupMessageAtIndex(indexPath.item)
        
        if (groupChatModel.messageWasSentByUser(message)) {
            return NSAttributedString(string: "")
        }
        
        if (indexPath.item - 1 > 0) {
            let previousMessage: JSQMessage = groupChatModel.getGroupMessageAtIndex(indexPath.item - 1)
            if (previousMessage.senderId == message.senderId) {
                return NSAttributedString(string: "")
            }
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    /* Leave room for a sender name label for incoming messages */
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        let message: JSQMessage = groupChatModel.getGroupMessageAtIndex(indexPath.item)
        
        if (groupChatModel.messageWasSentByUser(message)) {
            return 0.0
        }
        
        if (indexPath.item - 1 > 0) {
            let previousMessage: JSQMessage = groupChatModel.getGroupMessageAtIndex(indexPath.item - 1)
            if (previousMessage.senderId == message.senderId) {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    /* Show a timestamp every 3rd message */
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString!
    {
        if (indexPath.item % 3 == 0) {
            let message: JSQMessage = groupChatModel.getGroupMessageAtIndex(indexPath.item)
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return NSAttributedString(string: "")
    }
    
    /* Leave room for a timestamp label every 3rd message */
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        if (indexPath.item % 3 == 0) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
}
