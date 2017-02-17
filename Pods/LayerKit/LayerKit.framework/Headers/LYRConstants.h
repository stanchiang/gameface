//
//  LYRConstants.h
//  LayerKit
//
//  Created by Blake Watters on 7/13/2014
//  Copyright (c) 2014 Layer. All rights reserved.
//

///---------------
/// @name Typedefs
///---------------

/**
 @abstract A type representing an absolute logical position of an object within a sequence.
 */
typedef int64_t LYRPosition;
#define LYRPositionNotDefined INT64_MAX

/**
 @abstract A type representing a content size in bytes.
 */
typedef uint64_t LYRSize;
#define LYRSizeNotDefined UINT64_MAX

/**
 @abstract The `LYRDeletionMode` enumeration defines the available modes for deleting content.
 */
typedef NS_ENUM(NSUInteger, LYRDeletionMode) {

    /**
     @abstract Content is deleted for only the currently authenticated user. The deletion will also be synchronized 
     among all other devices for the current user.
     */
    LYRDeletionModeMyDevices                = 1,
    
    /**
     @abstract Content is deleted from all devices of all participants. This is a synchronized, permanent delete
     that results in content being deleted from the devices of existing users who have previously synchronized and
     makes the content unavailable for synchronization to new participants or devices.
     **/
    LYRDeletionModeAllParticipants          = 2
};

///---------------------
/// @name Object Changes
///---------------------

typedef NS_ENUM(NSInteger, LYRObjectChangeType) {
	LYRObjectChangeTypeCreate   = 0,
	LYRObjectChangeTypeUpdate   = 1,
	LYRObjectChangeTypeDelete   = 2
};

///-----------------------
/// @name Content Transfer
///-----------------------

/**
 @abstract The `LYRContentTransferType` values describe the type of a transfer. Used when LYRClient calls to the delegate via `layerClient:willBeginContentTransfer:ofObject:withProgress` and `layerClient:didFinishContentTransfer:ofObject:` methods.
 */
typedef NS_ENUM(NSInteger, LYRContentTransferType) {
    LYRContentTransferTypeDownload              = 0,
    LYRContentTransferTypeUpload                = 1
};

///-------------------------------
/// @name Synchronization Policies
///-------------------------------

typedef NS_ENUM(NSUInteger, LYRClientSynchronizationPolicy) {
    /**
     @abstract Configures the client to synchronize the complete history of each conversation.
     */
    LYRClientSynchronizationPolicyCompleteHistory   = 1,
    
    /**
     @abstract Configures the client to synchronize all messages up to first unread message in each conversation.
     If all messages in a given conversations have been marked as read, the client will fetch the last (most recent) message in the conversation in the initial sync.
     @discussion This is the default synchronization policy, if not specified in the options when initializing the `LYRClient`.
     */
    LYRClientSynchronizationPolicyUnreadOnly        = 2,
    
    /**
     @abstract Configures the client to synchronize a target number of messages for each conversation.
     that needs to be passed along in the options dictionary of the client initializer.
     */
    LYRClientSynchronizationPolicyPartialHistory    = 3
};

typedef NS_ENUM(NSUInteger, LYRMessageSyncOptions) {
    /**
     @abstract Using this option with `[conversation synchronizeAllMessages:error:] method will
     tell the client to synchronize all messages for that conversation.
     */
    LYRMessageSyncAll,

    /**
     @abstract Using this option with `[conversation synchronizeAllMessages:error:] method will
     tell the client to synchronize all messages up to the first unread mesasge in that conversation.
     */
    LYRMessageSyncToFirstUnread
};

///---------------------
/// @name Log Components
///---------------------

typedef NS_ENUM(NSUInteger, LYRLogComponent) {
    LYRLogComponentUndefined,
    LYRLogComponentInitialization,
    LYRLogComponentCertification,
    LYRLogComponentAuthentication,
    LYRLogComponentTransport,
    LYRLogComponentTransportPush,
    LYRLogComponentPlatformPush,
    LYRLogComponentModel,
    LYRLogComponentSQLite,
    LYRLogComponentSynchronization,
    LYRLogComponentInboundReconciliation,
    LYRLogComponentOutboundReconciliation,
    LYRLogComponentMessagingPublicAPI,
    LYRLogComponentRichContent,
    LYRLogComponentApplicationState,
    LYRLogComponentCount
};

///-----------------
/// @name Log Levels
///-----------------

typedef NS_ENUM(NSUInteger, LYRLogLevel) {
    LYRLogLevelOff,
    LYRLogLevelError,
    LYRLogLevelWarn,
    LYRLogLevelInfo,
    LYRLogLevelDebug,
    LYRLogLevelVerbose
};
