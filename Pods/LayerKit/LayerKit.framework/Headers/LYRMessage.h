//
//  LYRMessage.h
//  LayerKit
//
//  Created by Blake Watters on 5/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRQuery.h"
#import "LYRConstants.h"
#import "LYRPushNotificationConfiguration.h"
#import "LYRIdentity.h"

@class LYRConversation, LYRMessagePart;

/**
 @abstract `LYRRecipientStatus` is an enumerated value that describes the status of a given Message for a specific participant in the Conversation to which the Message belongs.
 */
typedef NS_ENUM(NSInteger, LYRRecipientStatus) {
    /// @abstract Status for the recipient cannot be determined because the message is not in a state in which recipient status can be evaluated or the user is not a participant in the Conversation.
    LYRRecipientStatusInvalid   = -1,
    
    /// @abstract The message has been transported to Layer and is awaiting synchronization by the recipient's devices.
    LYRRecipientStatusPending   = 0,
    
    /// @abstract The message has been transported to Layer and is awaiting synchronization by the recipient's devices.
    LYRRecipientStatusSent      = 1,
	
    /// @abstract The message has been synchronized to at least one device for a recipient but has not been marked as read.
    LYRRecipientStatusDelivered = 2,
	
    /// @abstract The message has been marked as read by one of the recipient's devices.
    LYRRecipientStatusRead      = 3
};

///------------------
/// @name Option Keys
///------------------

/**
 @abstract The option key used in the Message initializer options to specify the APNS configuration. The value given for this key
 must be an instance of `LYRPushNotificationConfiguration`.  See `LYRPushNotificationConfiguration` for per recipient customization options.
 */
extern NSString * _Nonnull const LYRMessageOptionsPushNotificationConfigurationKey;

/**
 @abstract A `LYRMessageOptions` object encapsulates configuration of a newly instantiated `LYRMessage` object meant to be sent out.
 @discussion Use this class to configure the behavior of a message during the time of the initialization of the
   `LYRMessage` object instance.
 */
@interface LYRMessageOptions : NSObject <NSCoding, NSCopying>

/**
 @abstract Push notification configuration sent to the Layer services along with the newly initialized `LYRMessage` instance.
 @discussion @see `LYRPushNotificationConfiguration` for per recipient customization options.
 */
@property (nonatomic, copy, nullable) LYRPushNotificationConfiguration *pushNotificationConfiguration;

@end

//------------------------------------------------------------

/**
 @abstract The `LYRMessage` class represents a message within a conversation (modeled by the `LYRConversation` class) between two or
 more participants within Layer.
 */
@interface LYRMessage : NSObject <LYRQueryable>

/**
 @abstract A unique identifier for the message.
 @discussion The `identifier` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.
 */
@property (nonatomic, readonly, nonnull) NSURL *identifier LYR_QUERYABLE_PROPERTY;

/**
 @abstract Logical position of the message in a conversation.
 The `position` property is queryable using all predicate operators.
 @discussion Unsent messages have index value of `LYRPositionNotDefined`.
 */
@property (nonatomic, readonly) LYRPosition position LYR_QUERYABLE_PROPERTY;

/**
 @abstract The conversation that the receiver is a part of.
 @discussion The `conversation` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.
 */
@property (nonatomic, readonly, nullable) LYRConversation *conversation LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRMessagePart);

/**
 @abstract An array of message parts (modeled by the `LYRMessagePart` class) that provide access to the content of the receiver.
 */
@property (nonatomic, readonly, nonnull) NSArray<LYRMessagePart *> *parts;

/**
 @abstract Returns a Boolean value that is true when the receiver has been sent by a client and posted to the Layer services.
 @discussion The `isSent` property is queryable via the `LYRPredicateOperatorIsEqualTo` and `LYRPredicateOperatorIsNotEqualTo` predicate operators.
 */
@property (nonatomic, readonly) BOOL isSent LYR_QUERYABLE_PROPERTY;

/**
 @abstract Returns a Boolean value that indicates if the receiver has been deleted.
 */
@property (nonatomic, readonly) BOOL isDeleted;

/**
 @abstract Returns a Boolean value that indicates if the receiver has not yet been read by the current user.
 @discussion The `isUnread` property is queryable via the `LYRPredicateOperatorIsEqualTo` and `LYRPredicateOperatorIsNotEqualTo` predicate operators.
 */
@property (nonatomic, readonly) BOOL isUnread LYR_QUERYABLE_PROPERTY;

/**
 @abstract The date and time that the message was originally sent.
 @discussion The `sentAt` property is queryable using all predicate operators.
 */
@property (nonatomic, readonly, nullable) NSDate *sentAt LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRConversation);

/**
 @abstract The date and time that the message was received by the authenticated user.
 @discussion For messages sent by the current user the `receivedAt` value will be equal to `sentAt`. The `receivedAt` property is queryable using all predicate operators.
 */
@property (nonatomic, readonly, nullable) NSDate *receivedAt LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRConversation);

/**
 @abstract The sender who sent the message.
 @discussion The `sender` can be an authenticated user or from a platform, specificed by the sender's properties `userID` and `name`. They are mutually exclusive. The sender's `userID` and `name` properties are queryable from `LYRMessage`.
 */
@property (nonatomic, readonly, nonnull) LYRIdentity *sender;

///----------------------
/// @name Marking as Read
///----------------------

/**
 @abstract Marks the message as being read by the current user.
 @discussion If multiple messages must be marked as read, use `markMessagesAsRead:error:` on `LYRClient` or `markAllMessagesAsRead:error` on `LYRConversation` instead.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the message could not be sent.
 @return `YES` if the message was marked as read or `NO` if the message was already marked as read.
 */
- (BOOL)markAsRead:(NSError * _Nullable * _Nullable)error;

///---------------------------
/// @name Deleting the Message
///---------------------------

/**
 @abstract Deletes a message in the specified mode.
 @param mode The deletion mode, specifying how the message is to be deleted (i.e. for only the currently authenticated user's devices or synchronized across participants).
 @param error A pointer to an error that upon failure is set to an error object describing why the deletion failed.
 @return A Boolean value indicating if the request to delete the message was submitted for synchronization.
 @raises NSInvalidArgumentException Raised if `message` is `nil`.
 */
- (BOOL)delete:(LYRDeletionMode)deletionMode error:(NSError * _Nullable * _Nullable)error __attribute__((swift_error(none)));

///------------------------------
/// @name Accessing Read Receipts
///------------------------------

/**
 @abstract Returns a dictionary keyed the user ID of all participants in the Conversation that the receiver belongs to and whose
 values are an `NSNumber` representation of the receipient status (`LYRRecipientStatus` value) for their corresponding key.
 */
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSNumber *> *recipientStatusByUserID;

/**
 @abstract Retrieves the message state for a given participant in the conversation.
 
 @param userID The user ID to retrieve the message status for.
 @return An `LYRRecipientStatus` value specifying the message status for the given participant or `LYRRecipientStatusInvalid` if the specified user is not a participant in the conversation.
 */
- (LYRRecipientStatus)recipientStatusForUserID:(nonnull NSString *)userID;

@end
