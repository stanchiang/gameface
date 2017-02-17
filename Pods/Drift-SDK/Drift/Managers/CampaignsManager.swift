//
//  AlertManager.swift
//  Drift
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Foundation
import LayerKit
import ObjectMapper

class CampaignsManager {
    /**
        Checks Layer for conversations
        Calls Presentation Manager to present any Campaigns to be shown
     */
    class func checkForCampaigns() throws{
        LoggerManager.log("Checking for campaigns")
        do {
            let convo = LYRQuery(queryableClass: LYRConversation.self)
            convo.predicate = LYRPredicate(property: "hasUnreadMessages", predicateOperator: LYRPredicateOperator.isEqualTo, value: true)
            let conversationController = try LayerManager.sharedInstance.layerClient?.queryController(with: convo)
            try conversationController?.execute()
            var announcements:[Campaign] = []
            var messages:[(conversationId: Int, messages:[Message])] = []
            if let countUInt = conversationController?.numberOfObjects(inSection: 0) {
                let count = Int(countUInt)
                for index: Int in 0..<count {
                    if let conversation = conversationController?.object(at: IndexPath(row: index, section: 0)) as? LYRConversation {
                        LoggerManager.log("Conversation hasunread: \(conversation.hasUnreadMessages)")
                        LoggerManager.log("Conversation Id: \(conversation.identifier)")
                        let newData = try getCampaignsAndMessagesFor(conversation)
                        announcements = announcements + newData.announcments
                        if !newData.messages.isEmpty {
                            messages.append((conversationId: newData.messages.first!.conversationId, messages: newData.messages))
                        }
                    }
                }
            }
            
            var messagesToShow:[(conversationId: Int, messages:[Message])] = []
            var messagesSyncedToVC = false
            for messageTouple in messages {
                if InboxManager.sharedInstance.hasSubscriptionForConversationId(messageTouple.conversationId) {
                    for message in messageTouple.messages {
                        InboxManager.sharedInstance.messageDidUpdate(message)
                    }
                    messagesSyncedToVC = true
                }else {
                    //Tell presentation controller we have new messages?
                    messagesToShow.append((conversationId: messageTouple.conversationId, messages: messageTouple.messages))
                }
            }
            
            if !messagesSyncedToVC {
                if messagesToShow.isEmpty {
                    let filtered = filtercampaigns(announcements)
                    PresentationManager.sharedInstance.didRecieveCampaigns(filtered.nps + filtered.announcements)
                }else{
                    PresentationManager.sharedInstance.didRecieveNewMessages(messagesToShow)
                }
            }
            
            
        } catch {
            LoggerManager.log("Error in checking conversations")
        }
    }
    
    
    /**
        Given a conversation get an array of campaigns for that conversation
        
        This will itterate through messages in a conversation and then its message parts searching for MimeType JSON and parse that into a campaign.
     
        - parameter conversation: Layer Conversation to traverse for campaigns
        - returns: All campaigns in a conversation - These are not SDK dependant - Should be parsed later for non presentable campaigns
     */
    class func getCampaignsAndMessagesFor(_ conversation: LYRConversation) throws -> (announcments: [Campaign], messages: [Message]) {
                
        let messagesQuery:LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
        messagesQuery.predicate = LYRPredicate(property: "conversation", predicateOperator: LYRPredicateOperator.isEqualTo, value: conversation)
        messagesQuery.sortDescriptors = [NSSortDescriptor(key:"position", ascending:true)]
        let queryController = try LayerManager.sharedInstance.layerClient?.queryController(with: messagesQuery)
        try queryController?.execute()
        
        var announcements:[Campaign] = []
        var messages:[Message] = []

        if let countUInt = queryController?.numberOfObjects(inSection: 0) {
            LoggerManager.log("Number Of Messages: \(countUInt)")
            let count = Int(countUInt)
            for index: Int in 0..<count {
                if let message = queryController?.object(at: IndexPath(row: index, section: 0)) as? LYRMessage , message.isUnread {
                    
                    for part in message.parts {
                        switch part.mimeType {
//                        case "text/plain":
                        case "application/json":
                            LoggerManager.log("Mapping Mime Type")

                            if let data = part.data, let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                                if let newAnnouncement = Mapper<Campaign>().map(JSON: json) {
                                    announcements.append(newAnnouncement)
                                }else if let newMessage = Mapper<Message>().map(JSON: json) {
                                    messages.append(newMessage)
                                }
                            }
                            
                        default:
                            LoggerManager.log("Ignored MimeType")
                        }
                    }
                }
            }
        }
        return (announcements, messages)
    }
    
    /**
        This is responsible for filtering an array of campaigns into NPS and Announcements
        This will also filter out non presentable campaigns
        - parameter campaign: Array of non filtered campaigns
        - returns: Tuple of NPS and Announcement Type Campaigns that are presentable in SDK
    */
    class func filtercampaigns(_ campaigns: [Campaign]) -> (nps: [Campaign], announcements: [Campaign]){
        
        ///GET NPS or NPS_RESPONSE
        
        ///DO Priority - Announcements before NPS, Latest first
        
        var npsResponse: [Campaign] = []
        var nps: [Campaign] = []
        var announcements: [Campaign] = []
        
        for campaign in campaigns {
            
            switch campaign.messageType {
                
            case .some(.NPS):
                nps.append(campaign)
            case .some(.NPSResponse):
                npsResponse.append(campaign)
            case .some(.Announcement):
                //Only show chat response announcements if we have an email
                if let ctaType = campaign.announcementAttributes?.cta?.ctaType , ctaType == .ChatResponse{
                    if let email = DriftDataStore.sharedInstance.embed?.inboxEmailAddress , email != ""{
                        announcements.append(campaign)
                    }else{
                        LoggerManager.log("Did remove chat announcement as we dont have an email")
                    }
                }else{
                    announcements.append(campaign)
                }
            default:
                ()
            }
        }
        
        let npsResponseIds = npsResponse.flatMap { $0.conversationId }
        
    
        nps = nps.filter {
            if let conversationId = $0.conversationId {
                return !npsResponseIds.contains(conversationId)
            }
            return false
        }
        
        return (nps, announcements)
    }
    
    
    /**
     Given a message ID this function marks it as read in Layer
    
     - parameter messageId:
     */
    class func markConversationAsRead(_ messageId: String) {
        guard let messageId = URL(string: "layer:///messages/\(messageId)") else{
            return
        }
        
        do {
            let messagesQuery:LYRQuery = LYRQuery(queryableClass: LYRMessage.self)

            messagesQuery.predicate = LYRPredicate(property: "identifier", predicateOperator: LYRPredicateOperator.isEqualTo, value: messageId)
            let queryController = try LayerManager.sharedInstance.layerClient?.queryController(with: messagesQuery)
            try queryController?.execute()
            if let countUInt = queryController?.numberOfObjects(inSection: 0) {
                let count = Int(countUInt)
                for index: Int in 0..<count {
                    if let message = queryController?.object(at: IndexPath(row: index, section: 0)) as? LYRMessage {
                        LoggerManager.log("Marking as Read: \(messageId)")
                        try message.markAsRead()
                    }
                }
            }
        } catch let error as NSError {
            LoggerManager.didRecieveError(error)
        }
    }
}
