//
//  LYRPolicy.h
//  LayerKit
//
//  Created by Blake Watters on 2/3/15.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @abstract The `LYRPolicyType` enumeration defines the types of policies that can be defined to govern communications within Layer.
 */
typedef NS_ENUM(NSInteger, LYRPolicyType) {
    /**
     @abstract Defines a policy which will block a matching entity from communicating with the target.
     */
    LYRPolicyTypeBlock,
};

/**
 @abstract The `LYRPolicy` object defines a policy that governs how communications destined for a given target user
 will be routed within Layer.
 @discussion It is important that you configure your `LYRPolicy` object appropriately before adding it to a client. Layer client objects make a copy of the policy you provide and use the copy for evaluation and enforcement. The policy objects maintained by the client are immutable and cannot be reconfigured. If you need to modify a policy, then you must make a copy of it, apply the appropriate changes, add the updated policy object to the client and remove the original policy (if appropriate).
 */
@interface LYRPolicy : NSObject <NSCopying, NSCoding>

///------------------------
/// @name Creating a Policy
///------------------------

/**
 @abstract Creates and returns a new policy with the given type.
 @discussion Upon return, the policy will contain new constraints and as such will apply globally.
 @param type The type of policy to create and return.
 @return A newly created policy object with the given type.
 */
+ (nonnull instancetype)policyWithType:(LYRPolicyType)type;

///----------------------------
/// @name Accessing Policy Type
///----------------------------

/**
 @abstract Returns the type of the receiver.
 */
@property (nonatomic, readonly) LYRPolicyType type;

///-----------------------------
/// @name Constraining by Sender
///-----------------------------

/**
 @abstract Specifies the sender of the content that the policy applies to. If `nil`, the policy applies to all senders.
 */
@property (nonatomic, copy, nullable) NSString *sentByUserID;

@end
