//
//  LYRMessagePart.h
//  LayerKit
//
//  Created by Blake Watters on 5/8/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRQuery.h"
#import "LYRConstants.h"
#import "LYRProgress.h"

@class LYRMessage;

/**
 @abstract The `LYRContentTransferStatus` enumeration describes the transfer status of the message part's content.
 */
typedef NS_ENUM(NSUInteger, LYRContentTransferStatus) {
    /**
     @abstract Content is available locally and is yet to be uploaded.
     @discussion This state is expected before the message is sent.
     */
    LYRContentTransferAwaitingUpload,
    /**
     @abstract Content is available locally and is in a state of uploading.
     @discussion This state is expected when message is in the sending process.
     */
    LYRContentTransferUploading,
    /**
     @abstract Content is not available locally but it is ready for download.
     @discussion This state is expected when message part didn't met the criteria to be auto-downloaded. Use `downloadContent` to initiate a manual download process.
     @see `LYRConnectionConfigurationAutodownloadMIMETypesKey`, `LYRConnectionConfigurationAutodownloadMaximumFileSizeKey` and `[(LYRClient *)client setConfiguration:forConnection:]` on how to use auto-downlod features.
     */
    LYRContentTransferReadyForDownload,
    /**
     @abstract Content is not yet avaiable locally and is in a state of downloading.
     @discussion This state is expected when message part downloaded was started manually or by using the auto-download feature.
     */
    LYRContentTransferDownloading,
    /**
     @abstract Content is available locally.
     @abstract This state is expected when the transfer completes.
     */
    LYRContentTransferComplete,
};

/**
 @abstract The `LYRMessagePart` class represents a piece of content embedded within a containing message. Each part has a specific MIME Type
 identifying the type of content it contains. Messages may contain an arbitrary number of parts with any MIME Type that the application
 wishes to support.
 */
@interface LYRMessagePart : NSObject <LYRQueryable>

///-----------------------------
/// @name Creating Message Parts
///-----------------------------

/**
 @abstract Creates a message part with the given MIME Type and data.
 
 @param MIMEType A MIME Type identifying the type of data contained in the given data object.
 @param data The data to be embedded in the mesage part.
 @return A new message part with the given MIME Type and data.
 @raises NSInvalidArgumentException Raised if MIME Type or data is nil.
 */
+ (nonnull instancetype)messagePartWithMIMEType:(nonnull NSString *)MIMEType data:(nonnull NSData *)data;

/**
 @abstract Creates a message part with the given MIME Type and stream of data.
 
 @param MIMEType A MIME Type identifying the type of data contained in the given data object.
 @param stream A stream from which to read the data for the message part.
 @return A new message part with the given MIME Type and stream of data.
 @raises NSInvalidArgumentException Raised if MIME Type or stream is nil.
 */
+ (nonnull instancetype)messagePartWithMIMEType:(nonnull NSString *)MIMEType stream:(nonnull NSInputStream *)stream;

/**
 @abstract Create a message part with a string of text.
 @discussion This is a convience accessor encapsulating the common operation of creating a message part
 with a plain text data attachment in UTF-8 encoding. It is functionally equivalent to the following example code:
 
 [LYRMessagePart messagePartWithMIMEType:@"text/plain" data:[text dataUsingEncoding:NSUTF8StringEncoding]];
 
 @param text The plain text body of the new message part.
 @return A new message part with the MIME Type text/plain and a UTF-8 encoded representation of the given input text.
 @raises NSInvalidArgumentException Raised if text is nil.
 */
+ (nonnull instancetype)messagePartWithText:(nonnull NSString *)text;

///---------------
/// @name Identity
///---------------

/**
 @abstract A unique identifier for the message part.
 */
@property (nonatomic, readonly, nonnull) NSURL *identifier LYR_QUERYABLE_PROPERTY;

/**
 @abstract Object index dictating message part order in a collection of LYRMessage.
 */
@property (nonatomic, readonly) NSUInteger index LYR_QUERYABLE_PROPERTY;

/**
 @abstract The message that the receiver is a part of.
 */
@property (nonatomic, readonly, nullable) LYRMessage *message LYR_QUERYABLE_PROPERTY;

///------------------------
/// @name Accessing Content
///------------------------

/**
 @abstract The MIME Type of the content represented by the receiver.
 */
@property (nonatomic, readonly, nonnull) NSString *MIMEType LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRMessage);

/**
 @abstract The content of the receiver as a data object.
 @discussion Property will be `nil` if content is not availble. Note that this operation might be expensive if trying to read large data.
 */
@property (nonatomic, readonly, nullable) NSData *data;

/**
 @abstract Returns a `NSURL` object to the filesystem location of the receiver’s content or `nil` if the content is not available locally or was transmitted inline.
 @discussion Property will be `nil` if content is not availble.
 */
@property (nonatomic, readonly, nullable) NSURL *fileURL;

/**
 @abstract The size of the content in bytes.
 */
@property (nonatomic, readonly) LYRSize size LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRMessage);

/**
 @abstract The current transfer status of the message part.
 */
@property (nonatomic, readonly) LYRContentTransferStatus transferStatus LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRMessage);

/**
 @abstract Progress of the current transfer state.
 @discussion Property will return a new instance, if previous one has been released from the memory.
 */
@property (nonatomic, readonly, nonnull) LYRProgress *progress;

/**
 @abstract Returns a new input stream object for reading the content of the receiver as a stream.
 @return A new, unopened input stream object configured for reading the content of the part represented by the receiver, if the content is available, otherwise `nil`.
 */
- (nullable NSInputStream *)inputStream;

/**
 @abstract Tells the receiver to schedule a download of the content, optionally reporting progress.
 @param error A pointer to an error object that upon failure will be set to an object that indicates why the download could not be started.
 @return An `LYRProgress` object that reports the progress of the download operation or `nil` if the content cannot be downloaded. 
 */
- (nullable LYRProgress *)downloadContent:(NSError * _Nullable * _Nullable)error;

/**
 @abstract Tells the receiver to schedule a purge of the content, optionally reporting progress.
 @param error A pointer to an error object that upon failure will be set to an object that indicates why the content could not be purged.
 @return An `LYRProgress` object that reports the progress of the content purging operation or `nil` if the content cannot be purged. 
 */
- (nullable LYRProgress *)purgeContent:(NSError * _Nullable * _Nullable)error;

@end
