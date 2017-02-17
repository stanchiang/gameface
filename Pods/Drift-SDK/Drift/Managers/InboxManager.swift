//
//  InboxManager.swift
//  Drift
//
//  Created by Brian McDonald on 25/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import ObjectMapper

class InboxManager {
    static let sharedInstance: InboxManager = InboxManager()
    let pageSize = 30
    
    var conversationSubscriptions: [ConversationSubscription] = []
    var messageSubscriptions: [MessageSubscription] = []
    
    func hasSubscriptionForConversationId(_ conversationId: Int) -> Bool {
        let matchingSub = messageSubscriptions.filter({$0.conversationId == conversationId && $0.delegate != nil})
        return !matchingSub.isEmpty
    }
    
    
    func getConversations(_ endUserId: Int, completion:@escaping (_ conversations: [Conversation]?) -> ()){
        
        
        guard let auth = DriftDataStore.sharedInstance.auth?.accessToken else {
            LoggerManager.log("No Auth Token for Recording")
            return
        }
        
        APIManager.getConversations(endUserId, authToken: auth) { (result) in
            switch result{
            case .success(let conversations):
                completion(conversations)
            case .failure:
                LoggerManager.log("Unable to retreive conversations for endUserId: \(endUserId)")
                completion(nil)
            }
        }
    }
    
    func getMessages(_ conversationId: Int, completion:@escaping (_ messages: [Message]?) -> ()){

        
        guard let auth = DriftDataStore.sharedInstance.auth?.accessToken else {
            LoggerManager.log("No Auth Token for Recording")
            return
        }
        
        APIManager.getMessages(conversationId, authToken: auth) { (result) in
            switch result{
            case .success(let messages):
                completion(messages)
            case .failure:
                LoggerManager.log("Unable to retreive messages for conversationId: \(conversationId)")
                completion(nil)
            }
        }
    }
    
    func postMessage(_ message: Message, conversationId: Int, completion:@escaping (_ message: Message?, _ requestId: Double) -> ()){
        

        guard let auth = DriftDataStore.sharedInstance.auth?.accessToken else {
            LoggerManager.log("No Auth Token for Recording")
            return
        }
        
        APIManager.postMessage(conversationId, message: message, authToken: auth) { (result) in
            switch result{
            case .success(let returnedMessage):
                completion(returnedMessage, message.requestId)
            case .failure:
                LoggerManager.log("Unable to post message for conversationId: \(conversationId)")
                completion(nil, message.requestId)
            }
        }
    }
    
    
    func createConversation(_ message: Message, authorId: Int?, completion:@escaping (_ message: Message?, _ requestId: Double) -> ()){
        
        
        guard let auth = DriftDataStore.sharedInstance.auth?.accessToken else {
            LoggerManager.log("No Auth Token for Recording")
            return
        }
        
        APIManager.createConversation(message.body ?? "", authorId: authorId, authToken: auth) { (result) in
            switch result{
            case .success(let returnedMessage):
                completion(returnedMessage, message.requestId)
            case .failure:
                LoggerManager.log("Unable to create conversation")
                completion(nil, message.requestId)
            }
        }
    }
    
    //Create subscriptions for objects
    func addConversationSubscription(_ subscription: ConversationSubscription){
        self.conversationSubscriptions.append(subscription)
    }
    
    func addMessageSubscription(_ subscription: MessageSubscription){
        self.messageSubscriptions.append(subscription)
    }

    //Alert delegates of updated to Conversations
    func conversationsDidUpdate(_ inboxId: Int, conversations: [Conversation]){
        for conversationSubscription in conversationSubscriptions{
            conversationSubscription.delegate?.conversationsDidUpdate(conversations)
        }
    }
    
    func conversationDidUpdate(_ conversation: Conversation){
        for conversationSubscription in conversationSubscriptions{
            conversationSubscription.delegate?.conversationDidUpdate(conversation)
        }
    }
    
    //Alert delegates of updates to messages
    func messagesDidUpdate(_ conversationId: Int, messages: [Message]){
        for messageSubscription in messageSubscriptions{
            if messageSubscription.conversationId == conversationId{
                messageSubscription.delegate?.messagesDidUpdate(messages)
            }
        }
    }
    
    func messageDidUpdate(_ message: Message){
        for messageSubscription in messageSubscriptions{
            if messageSubscription.conversationId == message.conversationId{
                messageSubscription.delegate?.newMessage(message)
            }
        }
    }
    
}

