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
    * View response methods
    *--------------------------------------------*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ba-BOMBS"
        self.senderId = "HahaYouLose"
        self.senderDisplayName = "Lance Goodridge"
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        self.collectionView.reloadData()
        automaticallyScrollsToMostRecentMessage = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        groupChatModel.refreshMessages()
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
        groupChatModel.sendMessage(text)
        groupChatModel.refreshMessages()
        finishSendingMessage()
    }
    
    
   /*--------------------------------------------*
    * JSQMessagesViewController collection methods
    *--------------------------------------------*/
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupChatModel.getGroupMessages().count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = groupChatModel.getGroupMessageAtIndex(indexPath.item)
        if (groupChatModel.messageWasSentByUser(message)) {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return groupChatModel.getGroupMessageAtIndex(indexPath.item)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = groupChatModel.getGroupMessageAtIndex(indexPath.item)
        if (groupChatModel.messageWasSentByUser(message)) {
            return groupChatModel.getIncomingBubbleImage()
        } else {
            return groupChatModel.getOutgoingBubbleImage()
        }
    }
    
}
