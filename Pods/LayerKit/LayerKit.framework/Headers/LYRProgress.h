//
//  LYRProgress.h
//  LayerKit
//
//  Created by Klemen Verdnik on 1/12/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRConstants.h"

@protocol LYRProgressDelegate;

/**
 @abstract The `LYRProgress` class is responsible for progress reporting.  It provides a simple interface modeled on `NSProgress` that allows for easy integration with a user interface. Changes in progress are observable via key-value observation or delegation. `LYRProgress` also provides an interface for pausing or canceling the underlying operation that it is reporting on behalf of, should the operation allow it.
 @warning Please note that when integrating an `LYRProgress` with a user interface you must take care to ensure that the updates are processed on the main thread. For performance reasons `LYRProgress` objects do not provide any guarantees about the thread context on which notifications will be delivered.
 */
@interface LYRProgress : NSObject

/**
 @name Returns the size of the job receiver is tracking the progress for.
 */
@property (nonatomic, readonly) NSUInteger totalUnitCount;

/**
 @name Returns the number of units completed.
 */
@property (nonatomic, readonly) NSUInteger completedUnitCount;

/**
 @name Returns the fraction of the overall work completed by receiver or its children.
 */
@property (nonatomic, readonly) double fractionCompleted;

/**
 @name User assigned userInfo dictionary.
 */
@property (nonatomic, copy, nullable) NSDictionary *userInfo;

/**
 @name The `LYRProgressDelegate` protocol provides a method for notifying the
 receiver about the progress changes.
 */
@property (nonatomic, weak, nullable) id<LYRProgressDelegate> delegate;

/**
 @name Returns YES if operation the progress is being tracked for is cancellable.
 */
@property (nonatomic, readonly, getter = isCancellable) BOOL cancellable;

/**
 @name Returns YES if operation the progress was canceled.
 */
@property (readonly, getter=isCancelled) BOOL cancelled;

/**
 @abstract Cancels the current operation and its descendants (if cancellable).
 */
- (void)cancel;

/**
 @name Returns YES if operation the progress is being tracked for is pausable.
 */
@property (nonatomic, readonly, getter = isPausable) BOOL pausable;

/**
 @name Returns YES if operation the progress was paused.
 */
@property (readonly, getter=isPaused) BOOL paused;

/**
 @abstract Pauses the current operation and its descendants (if cancellable).
 */
- (void)pause;

@end

/**
 @abstract The `LYRAggressProgress` class is a subclass of `LYRProgress` that provides an interface for aggregating the progress reported by an arbitrary number of underlying `LYRProgress` instances. It calculates the total progress based on the state of the child `LYRProgress` instances that it is aggregating.
 */
@interface LYRAggregateProgress : LYRProgress

/**
 @name Returns an array of children objects, if any, otherwise `nil`.
 */
@property (nonatomic, readonly, nullable) NSArray<__kindof LYRProgress *> *children;

/**
 @abstract Returns a new instance of aggregate progress object.
 @param progresses An array of `LYRProgress` instances.
 */
+ (nonnull instancetype)aggregateProgressWithProgresses:(nullable NSArray *)progresses;

/**
 @abstract progress An instance of LYRProgress to add to the aggregate.
 */
- (void)addProgress:(nonnull LYRProgress *)progress;

@end

/**
 @abstract The `LYRProgressDelegate` protocol provides a method for notifying the adopting delegate about progress changes.
 */
@protocol LYRProgressDelegate <NSObject>

@required
/**
 @abstract Tells the delegate that the progress instance has changed.
 @discussion Progress is observed via instance's `fractionCompleted` or `completedUnitCount` properties.
 */
- (void)progressDidChange:(nonnull LYRProgress *)progress;

@end
