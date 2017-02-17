//
//  LYRErrors.h
//  LayerKit
//
//  Created by Blake Watters on 4/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const LYRErrorDomain;

typedef NS_ENUM(NSUInteger, LYRError) {
    LYRErrorUnknownError                            = 1000,
    
    // Messaging Errors
    LYRErrorUnauthenticated                         = 1001,
    LYRErrorInvalidMessage                          = 1002,
    LYRErrorTooManyParticipants                     = 1003,
    LYRErrorDataLengthExceedsMaximum                = 1004,
    LYRErrorMessageAlreadyMarkedAsRead              = 1005,
    LYRErrorObjectNotSent                           = 1006,
    LYRErrorMessagePartContentAlreadyAvailable      = 1007,
    LYRErrorMessagePartContentAlreadyPurged         = 1008,
    LYRErrorMessagePartContentInlined               = 1009,
    LYRErrorConversationAlreadyDeleted              = 1010,
    LYRErrorUserNotAParticipantInConversation       = 1011, 
    LYRErrorImmutableParticipantsList               = 1012,
    LYRErrorDistinctConversationExists              = 1013,
    LYRErrorParticipantNotAParticipantInConversation= 1014,
    LYRErrorDistinctDeletedConversationExists       = 1015,
    LYRErrorParticipantsContainsBlockedUser         = 1016,
    
    // Validation Errors
    LYRErrorInvalidKey                              = 2000,
    LYRErrorInvalidValue                            = 2001,
    
    // Policy Errors
    LYRErrorPolicyValidationFailure                 = 4000,
    LYRErrorPolicyNotFound                          = 4001,
    
    // Query Controller Errors
    LYRErrorQueryControllerExecutionFailure         = 5000
};

typedef NS_ENUM(NSUInteger, LYRClientError) {
    // Client Errors
    LYRClientErrorAlreadyConnected                  = 6000,
    LYRClientErrorInvalidAppID                      = 6001,
    LYRClientErrorNetworkRequestFailed              = 6002,
    LYRClientErrorConnectionTimeout                 = 6003,
    LYRClientErrorAsyncTimeout                      = 6004,
    LYRClientErrorInvalidIdentifier                 = 6005,
    LYRClientErrorNotConnected                      = 6006,
    
    // Crypto Configuration Errors
    LYRClientErrorKeyPairNotFound                   = 7000,
    LYRClientErrorCertificateNotFound               = 7001,
    LYRClientErrorIdentityNotFound                  = 7002,
    
    // Authentication
    LYRClientErrorNotAuthenticated                  = 7004,
    LYRClientErrorAlreadyAuthenticated              = 7005,
    LYRClientErrorInvalidToken                      = 7006,
    
    // Push Notification Errors
    LYRClientErrorDeviceTokenInvalid                = 8000,
    
    // Synchronization Errors
    LYRClientErrorUndefinedSyncFailure                  = 9000,
    LYRClientErrorDevicePersistenceFailure              = 9001,
    LYRClientErrorSynchronizationFailure                = 9002,
    LYRClientErrorManualSyncIgnoredInForeground         = 9003,
    LYRClientErrorManualSyncFailedNoConnection          = 9004,
    LYRClientErrorManualSyncIgnoredAlreadyInProgress    = 9005,
    LYRClientErrorManualSyncIgnoredAlreadyFullySynced   = 9006,
    LYRClientErrorManualSyncIgnoredNothingToSync        = 9007,
    
    // Debug Errors
    LYRClientErrorZipArchiveCreationFailure         = 10001,
    LYRClientErrorZipFileArchiveFailure             = 10002,
    LYRClientErrorTempFileArchiveFailure            = 10003,
    LYRClientErrorSnapshotCaptureFailure            = 10004,
    LYRClientErrorNoFileLoggerPath                  = 10005,
    LYRClientErrorDatabaseBackupFailure             = 10006,
    
    // Marking Messages as Read
    LYRClientErrorMessageDeleted                    = 11001,
    LYRClientErrorConversationDeleted               = 11002,
    LYRClientErrorInvalidClassType                  = 11003,
    
    // Session Errors
    LYRClientErrorInvalidSession                    = 12001,
    LYRClientErrorDuplicateSession                  = 12002,
};

extern NSString * _Nonnull const LYRErrorAuthenticatedUserIDUserInfoKey;
extern NSString * _Nonnull const LYRErrorUnderlyingErrorsKey;

/**
 @abstract A key into the `userInfo` dictionary of an error returned when attempting to create a new distinct conversation. That key's value represents an existing distinct conversation object.
 */
extern NSString * _Nonnull const LYRExistingDistinctConversationKey;

/**
 @abstract A key into the `userInfo` dictionary of an error passed when attempting to run a partial sync for a specific conversation. The key's value represents an `LYRProgress` instance of an existing synchronization process.
 */
extern NSString * _Nonnull const LYRExistingSynchronizationProgress;

