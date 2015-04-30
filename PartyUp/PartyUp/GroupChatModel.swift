//
//  GroupChatModel.swift
//  PartyUp
//
//  Created by Lance Goodridge on 4/21/15.
//  Copyright (c) 2015 BDGL-Hacks. All rights reserved.
//

import Foundation

class GroupChatModel: NSObject, PTPusherDelegate
{
   /*--------------------------------------------*
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    let PUSHER_API_KEY: String = "todo"
    
    
   /*--------------------------------------------*
    * Instance variables and Declarations
    *--------------------------------------------*/
    
    var groupID: NSInteger = -1
    var groupTitle: NSString = ""
    var groupChannel: NSString = ""
    var groupMessages: NSMutableArray = NSMutableArray()
    
    var earliestMessageID: NSInteger = -1
    var latestMessageID: NSInteger = -1
    var userID: NSInteger = -1
    
    var incomingBubbleImage: JSQMessagesBubbleImage
    var outgoingBubbleImage: JSQMessagesBubbleImage
    
    
   /*--------------------------------------------*
    * Initialization Methods
    *--------------------------------------------*/
    
    override init()
    {
        // Set up JSQViewController
        let bubbleFactory: JSQMessagesBubbleImageFactory = JSQMessagesBubbleImageFactory()
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        
        super.init()
    }
    
    func setupPusher() {
        let client: PTPusher = PTPusher.pusherWithKey(PUSHER_API_KEY, delegate: self, encrypted: true) as! PTPusher
        let channel: PTPusherChannel = client.subscribeToChannelNamed(groupChannel as String)
        PULog("Listening on pusher channel: \(groupChannel)")
        channel.bindToEventNamed("message", handleWithBlock: {(PTPusherEventBlockHandler) in
            PULog("Sending Pusher notification")
            NSNotificationCenter.defaultCenter().postNotificationName(self.groupChannel as String, object: self)
        })
    }
    
    
   /*--------------------------------------------*
    * Action Methods
    *--------------------------------------------*/
    
    /* Queries the backend and updates the model with earlier *
     * messages. Returns an error message if update failed.   */
    func getEarlierMessages() -> NSString?
    {
        var (errorMessage: NSString?, userID: NSInteger?, queryResults: NSArray?) = (nil, nil, nil)
        
        // First time querying messages: Get 10 most recent
        if (earliestMessageID == -1) {
            return getMostRecentMessages()
        }
        
        // Get 10 messages before the current earliest one
        else {
            PULog("Fetching earlier group messages")
            (errorMessage, userID, queryResults) = PartyUpBackend.instance.queryGroupMessages(groupID: groupID, messageID: earliestMessageID)
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
                if (latestMessageID == -1) {
                    latestMessageID = DataManager.getMessageID(queryResults![queryResults!.count - 1] as! NSDictionary)
                }
                return nil
            }
        }
    }
    
    /* Queries backend and updates the model with most recent *
     * messages. Returns an error message if update failed.   */
    func getMostRecentMessages() -> NSString?
    {
        var (errorMessage: NSString?, userID: NSInteger?, queryResults: NSArray?) = (nil, nil, nil)
        
        PULog("Loading most recent message(s)")
        (errorMessage, userID, queryResults) = PartyUpBackend.instance.queryGroupMessages(groupID: groupID)
        
        // Failed to refresh messages
        if (errorMessage != nil) {
            PULog("Failed to retrieve messages: \(errorMessage!)")
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
                for i in 0 ... queryResults!.count - 1 {
                    let message: NSDictionary = queryResults![i] as! NSDictionary
                    if latestMessageID < DataManager.getMessageID(message) {
                        groupMessages.addObject(jsqMessages[i])
                    }
                }
                if (earliestMessageID == -1) {
                    earliestMessageID = DataManager.getMessageID(queryResults![0] as! NSDictionary)
                }
                latestMessageID = DataManager.getMessageID(queryResults![queryResults!.count - 1] as! NSDictionary)
                return nil
            }
        }
    }
    
    /* Throws away previous message data, and re-queries backend for    *
     * most recent messages. Returns an error message if update failed. */
    func resetMessages() -> NSString? {
        PULog("Resetting messages")
        earliestMessageID = -1
        latestMessageID = -1
        groupMessages = NSMutableArray()
        return getMostRecentMessages()
    }
    
    /* Sends a message to the backend. Returns an error *
     * message string if message failed to send.        */
    func sendMessage(message: NSString) -> NSString? {
        PULog("Sending message: \(message)")
        return PartyUpBackend.instance.postGroupChatMessage(groupID, message: message)
    }
    
    func setGroupData(group: NSDictionary) {
        groupID = DataManager.getGroupID(group)
        groupTitle = DataManager.getGroupTitle(group)
        groupChannel = DataManager.getGroupChannel(group)
        setupPusher()
        
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userID = userDefaults.objectForKey("USER_ID") as! NSInteger
    }
    
    
   /*--------------------------------------------*
    * Helper Methods
    *--------------------------------------------*/
    
    /* Takes an NSArray of raw Message JSON objects *
     * and returns an array of JSQMessage objects.  */
    private func convertToJSQMessages(jsonMessages: NSArray) -> NSArray
    {
        var jsqMessages: NSMutableArray = NSMutableArray()
        for element in jsonMessages {
            let message: NSDictionary = element as! NSDictionary
            let senderID: String = "\(DataManager.getMessageOwnerID(message))"
            let messageSenderName: String = DataManager.getMessageOwnerFullName(message) as String
            let messageDate: NSDate = NSDate(dateString: DataManager.getMessageDatetimeRaw(message) as String)
            let messageText: String = DataManager.getMessageText(message) as String
            let jsqMessage: JSQMessage = JSQMessage(senderId: senderID, senderDisplayName: messageSenderName, date: messageDate, text: messageText)
            jsqMessages.addObject(jsqMessage)
        }
        return jsqMessages as NSArray
    }
    
    
   /*--------------------------------------------*
    * Get Methods
    *--------------------------------------------*/
    
    func getGroupTitle() -> NSString {
        return groupTitle
    }
    
    func getGroupMessages() -> NSArray {
        return groupMessages as NSArray
    }
    
    func getGroupMessageAtIndex(index: Int) -> JSQMessage {
        return groupMessages[index] as! JSQMessage
    }
    
    func getNotificationName() -> NSString {
        return groupChannel
    }
    
    func getIncomingBubbleImage() -> JSQMessagesBubbleImage {
        return incomingBubbleImage
    }
    
    func getOutgoingBubbleImage() -> JSQMessagesBubbleImage {
        return outgoingBubbleImage
    }
    
    func messageWasSentByUser(message: JSQMessage) -> Bool {
        let senderID: NSInteger = NSString(string: message.senderId).integerValue as NSInteger
        return userID == senderID
    }
}