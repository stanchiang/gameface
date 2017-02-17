//
//  ConversationSubscription.swift
//  Drift
//
//  Created by Brian McDonald on 25/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//


public protocol ConversationDelegate: class{
    func conversationsDidUpdate(_ conversations: [Conversation])
    func conversationDidUpdate(_ conversation: Conversation)
}

open class ConversationSubscription {
    
    public convenience init(delegate: ConversationDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    weak var delegate: ConversationDelegate?
}

