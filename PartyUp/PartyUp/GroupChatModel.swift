//
//  GroupChatModel.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/21/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation

class GroupChatModel
{
   /*--------------------------------------------*
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    var groupID: NSInteger = -1
    var groupMessages: NSMutableArray = NSMutableArray()
    
    var earliestMessageID: NSInteger = -1
    
    var incomingBubbleImage: JSQMessagesBubbleImage
    var outgoingBubbleImage: JSQMessagesBubbleImage
    
    
    init() {
        let bubbleFactory: JSQMessagesBubbleImageFactory = JSQMessagesBubbleImageFactory()
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
    
    
   /*--------------------------------------------*
    * Action Methods
    *--------------------------------------------*/
    
    /* Queries the backend and updates the model with more  *
     * messages. Returns an error message if update failed. */
    func refreshMessages() -> NSString?
    {
        var (errorMessage: NSString?, queryResults: NSArray?) = (nil, nil)
        
        // First time querying messages: Get 10 most recent
        if (earliestMessageID == -1) {
            PULog("Loading initial group messages")
            (errorMessage, queryResults) = PartyUpBackend.instance.queryGroupMessages(groupID: groupID)
        }
        
        // Get 10 messages before the current earliest one
        else {
            PULog("Updating group messages")
            (errorMessage, queryResults) = PartyUpBackend.instance.queryGroupMessages(groupID: groupID, messageID: earliestMessageID)
        }
        
        // Failed to refresh messages
        if (errorMessage != nil) {
            PULog("Failed to load messages: \(errorMessage!)")
            return errorMessage!
        }
        
        // Messages refreshed successfully
        else {
            PULog("Messages loaded successfully!")
            if (queryResults!.count == 0) {
                PULog("Group has no more messages!")
                return nil
            }
            else {
                let jsqMessages: NSArray = convertToJSQMessages(queryResults!)
                groupMessages.insertObjects(jsqMessages as! [AnyObject], atIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, queryResults!.count)))
                earliestMessageID = DataManager.getMessageID(queryResults![0] as! NSDictionary)
                return nil
            }
        }
    }
    
    /* Sends a message to the backend. Returns an error *
     * message string if message failed to send.        */
    func sendMessage(message: NSString) {
        PULog("Sending Message: \(message)")
        PartyUpBackend.instance.postGroupChatMessage(groupID, message: message)
    }
    
    func setGroupData(group: NSDictionary) {
        groupID = DataManager.getGroupID(group)
    }
    
    
   /*--------------------------------------------*
    * Helper Methods
    *--------------------------------------------*/
    
    /* Takes an NSArray of raw Message JSON objects *
     * and returns an array of JSQMessage objects.  */
    func convertToJSQMessages(jsonMessages: NSArray) -> NSArray
    {
        var jsqMessages: NSMutableArray = NSMutableArray()
        for element in jsonMessages {
            let message: NSDictionary = element as! NSDictionary
            let messageID: String = "\(DataManager.getMessageID(message))"
            let messageSenderName: String = DataManager.getMessageOwnerFullName(message) as String
            let messageDate: NSDate = NSDate(dateString: DataManager.getMessageDatetimeRaw(message) as String)
            let messageText: String = DataManager.getMessageText(message) as String
            let jsqMessage: JSQMessage = JSQMessage(senderId: messageID, senderDisplayName: messageSenderName, date: messageDate, text: messageText)
            jsqMessages.addObject(jsqMessage)
        }
        return jsqMessages as NSArray
    }
    
    
   /*--------------------------------------------*
    * Get Methods
    *--------------------------------------------*/
    
    func getGroupMessages() -> NSArray {
        return groupMessages as NSArray
    }
    
    func getGroupMessageAtIndex(index: Int) -> JSQMessage {
        return groupMessages[index] as! JSQMessage
    }
    
    func getIncomingBubbleImage() -> JSQMessagesBubbleImage {
        return incomingBubbleImage
    }
    
    func getOutgoingBubbleImage() -> JSQMessagesBubbleImage {
        return outgoingBubbleImage
    }
    
    /* TODO: ACTUALLY WRITE THIS METHOD */
    func messageWasSentByUser(message: JSQMessage) -> Bool {
        return false
    }
}