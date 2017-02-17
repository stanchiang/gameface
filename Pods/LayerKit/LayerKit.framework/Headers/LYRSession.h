//
//  LYRSession.h
//  LayerKit
//
//  Created by Kevin Coleman on 4/5/16.
//  Copyright (c) 2016 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRIdentity.h"

/**
 @abstract The `LYRSessionState` enumeration describes the authentication states that an `LYRSession` can be in.
 */
typedef NS_ENUM(NSUInteger, LYRSessionState) {
    /**
     @abstract The session is unauthenticated. The session is either new or has been explicitly deauthenticated.
     */
    LYRSessionStateUnauthenticated,
    
    /**
     @abstract The session is authenticated and valid. This is the normal operational state for a session. Messaging services are available.
     */
    LYRSessionStateAuthenticated,
    
    /**
     @abstract The session has been challenged. The previous session has expired or been invalidated and must be reauthenticated. Messaging services are unavailable until the challenge is resolved.
     */
    LYRSessionStateChallenged
};

/**
 @abstract The `LYRSession` class models a Layer session.
 */
@interface LYRSession : NSObject

/**
 @abstract The identifier for the session.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 @abstract The authenticated user for the session.
 */
@property (nonatomic, readonly) LYRIdentity *authenticatedUser;

/**
 @abstract An enum value that describes the authentication state of the session.
 */
@property (nonatomic, readonly) LYRSessionState state;

/**
 @abstract The path to which the session is persisted.
 */
@property (nonatomic, readonly) NSString *sessionPath;

/**
 @abstract The database path for the underlying database for the session.
 */
@property (nonatomic, readonly) NSString *databasePath;

@end
