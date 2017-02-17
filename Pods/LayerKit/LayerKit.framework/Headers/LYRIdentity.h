//
//  LYRIdentity.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/16/15.
//  Copyright (c) 2015 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRQuery.h"

@class LYRMessage;

/**
 @abstract The `LYRIdentity` class represents an identity synchronized to the client with information provided
 by the provider application. `LYRIdentity` objects are used as `LYRConversation` participants and as `LYRMessage` sender values.
 */
@interface LYRIdentity : NSObject <LYRQueryable>

/**
 @abstract A unique identifier for the identity.
 @discussion The `identifier` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.
 */
@property (nonatomic, readonly) NSURL *identifier LYR_QUERYABLE_PROPERTY;

/**
 @abstract The userID associated with the identity.
 @discussion The `userID` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.
 */
@property (nonatomic, readonly) NSString *userID LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRMessage);

/**
 @abstract The display name for the identity.
 @discussion The `displayName` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`,  `LYRPredicateOperatorIsNotIn`, and `LYRPredicateOperatorLike` operators.
 */
@property (nonatomic, readonly) NSString *displayName LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRMessage);

/**
 @abstract The first name for the identity.
 @discussion The `firstName` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, `LYRPredicateOperatorIsNotIn`,and `LYRPredicateOperatorLike` operators.
 */
@property (nonatomic, readonly) NSString *firstName LYR_QUERYABLE_PROPERTY;

/**
 @abstract The last name for the identity.
 @discussion The `lastName` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, `LYRPredicateOperatorIsNotIn`, and `LYRPredicateOperatorLike` operators.
 */
@property (nonatomic, readonly) NSString *lastName LYR_QUERYABLE_PROPERTY;

/**
 @abstract The email address for the identity.
 @discussion The `emailAddress` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, `LYRPredicateOperatorIsNotIn`, and `LYRPredicateOperatorLike`x operators.
 */
@property (nonatomic, readonly) NSString *emailAddress LYR_QUERYABLE_PROPERTY;

/**
 @abstract The phone number for the identity.
 @discussion The `phoneNumber` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.
 */
@property (nonatomic, readonly) NSString *phoneNumber LYR_QUERYABLE_PROPERTY;

/**
 @abstract The avatar image url for the identity.
 @discussion The `avatarImageURL` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.
 */
@property (nonatomic, readonly) NSURL *avatarImageURL LYR_QUERYABLE_PROPERTY;

/**
 @abstract Returns the metadata associated with the identity.
 @discussion Metadata is a free form dictionary of string key-value pairs that allows arbitrary developer supplied information to be associated with the identity. The `metadata` property is queryable in 2 forms.  The first is key path form eg:`metadata.first.second`, and is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`,
 `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.  The second is querying against `metadata` and passing in a dictionary object value, and is only queryable via the `LYRPredicateOperatorIsEqualTo` operator.
 */
@property (nonatomic, readonly) NSDictionary *metadata LYR_QUERYABLE_PROPERTY;

/**
 @abstract The public key for the identity.
 @discussion The `publicKey` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.
 */
@property (nonatomic, readonly) NSString *publicKey LYR_QUERYABLE_PROPERTY;

/**
 @abstract The followed property indicates if an identity has been synchronized with Layer's platform.
 @discussion The `followed` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.  `YES` if the identity has been synchronized with Layer's platform.
 */
@property (nonatomic, readonly) BOOL followed LYR_QUERYABLE_PROPERTY;

@end
