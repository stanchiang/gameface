//
//  LYRObjectChange.h
//  LayerKit
//
//  Created by Klemen Verdnik on 6/29/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRConstants.h"

/** 
 * @abstract The `LYRObjectChange` models a single change that has occurred upon a Layer model object. There are three types of changes that can occur: Create, Update and Delete.
 */
@interface LYRObjectChange : NSObject

/**
 * @abstract The object upon which the change has occured.
 */
@property (nonatomic, readonly, nonnull) id object;

/**
 * @abstract The type of the change that has occured.
 */
@property (nonatomic, readonly) LYRObjectChangeType type;

/**
 @abstract The name of the property that was updated or `nil` if the receiver has a change type of `LYRObjectChangeTypeCreate` or `LYRObjectChangeTypeDelete`.
 */
@property (nonatomic, readonly, nullable) NSString *property;

/**
 @abstract The value of `property` before the update or `nil` if the receiver has a change type of `LYRObjectChangeTypeCreate` or `LYRObjectChangeTypeDelete`.
 */
@property (nonatomic, readonly, nullable) id beforeValue;

/**
 @abstract The value of `property` after the update or `nil` if the receiver has a change type of `LYRObjectChangeTypeCreate` or `LYRObjectChangeTypeDelete`.
 */
@property (nonatomic, readonly, nullable) id afterValue;

@end
