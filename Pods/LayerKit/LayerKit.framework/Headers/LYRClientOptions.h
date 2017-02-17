//
//  LYRClientOptions.h
//  LayerKit
//
//  Created by Kevin Coleman on 5/26/16.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRConstants.h"

/*
 @abstract A `LYRClientOptions` object encapsulates configuration of an `LYRClient` object.
 @discussion Use this class to configure the synchronization behavior of an `LYRClient` object during a cold synchronization or upon encountering a new conversation with an existing body of history.
 */
@interface LYRClientOptions : NSObject <NSCoding, NSCopying>

/**
 @abstract Configures the client synchronization policy.
 @discussion The synchronization policy determines how a Layer client object behaves when it encoutners a conversation during cold synchronization or when added to a conversation with an existing body of history. The default value is `LYRClientSynchronizationPolicyUnreadOnly`.
 @see LYRClientSynchronizationPolicy enum.
 */
@property (nonatomic) LYRClientSynchronizationPolicy synchronizationPolicy;

/**
 @abstract Configures the number of messages to initially synchronize when the `synchronizationPolicy` is set to `LYRClientSynchronizationPolicyPartialHistory`.
 @discussion The message count applies to conversations discovered during cold sync or when the authenticated user is added to a conversation with an existing body of history. The default value is `25`.
 @see LYRClientSynchronizationPolicy enum.
 */
@property (nonatomic) NSUInteger partialHistoryMessageCount;

@end
