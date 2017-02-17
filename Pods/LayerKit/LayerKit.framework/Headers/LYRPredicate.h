//
//  LYRPredicate.h
//  LayerKit
//
//  Created by Blake Watters on 10/20/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @abstract The `LYRPredicateOperator` enumeration defines the set of comparison operators available for use by `LYRPredicate` objects.
 */
typedef NS_ENUM(NSUInteger, LYRPredicateOperator) {
    
    ///----------------------------------
    /// @name Absolute Equality Operators
    ///----------------------------------
    
    /**
     @abstract The property's value is equal to the given value.
     */
    LYRPredicateOperatorIsEqualTo,
    
    /**
     @abstract The property's value is not equal to the given value.
     */
    LYRPredicateOperatorIsNotEqualTo,
    
    ///------------------------------------
    /// @name Relative Comparison Operators
    ///------------------------------------
    
    /**
     @abstract The property's value is less than the given value.
     */
    LYRPredicateOperatorIsLessThan,
    
    /**
     @abstract The property's value is less than or equal to the given value.
     */
    LYRPredicateOperatorIsLessThanOrEqualTo,
    
    /**
     @abstract The property's value is greater than the given value.
     */
    LYRPredicateOperatorIsGreaterThan,
    
    /**
     @abstract The property's value is greater than or equal to the given value.
     */
    LYRPredicateOperatorIsGreaterThanOrEqualTo,
    
    ///-------------------------------------
    /// @name Collection Inclusion Operators
    ///-------------------------------------
    
    /**
     @abstract The property's value is contained in the given collection of values.
     */
    LYRPredicateOperatorIsIn,
    
    /**
     @abstract The property's value is not contained in the given collection of values.
     */
    LYRPredicateOperatorIsNotIn,
    
    ///---------------------
    /// @name Like Operators
    ///---------------------
    
    /**
     @abstract The property's value partial string matches the given value.
     */
    LYRPredicateOperatorLike
};

/**
 @abstract The `LYRPredicate` class is used to describe a comparison between the value of a specified property and an input 
 value using a comparison operator.
 */
@interface LYRPredicate : NSObject <NSCopying, NSCoding>

///---------------------------
/// @name Creating a Predicate
///---------------------------

/**
 @abstract Creates and returns a new predicate with the given property, operator, and value.
 @property property The property whose value is to be compared.
 @property predicateOperator The operator that determines how the property's value is compared to the reference value.
 @property value The reference value to use in the comparison.
 @returns A newly created predicate object.
 */
+ (nonnull instancetype)predicateWithProperty:(nonnull NSString *)property predicateOperator:(LYRPredicateOperator)predicateOperator value:(nullable id)value;

///-------------------------------------
/// @name Accessing Predicate Attributes
///-------------------------------------

/**
 @abstract Returns the property whose value the receiver will compare against the reference value.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *property;

/**
 @abstract Returns the predicate operator that specifies how the property's value will be compared against the reference value.
 */
@property (nonatomic, readonly) LYRPredicateOperator predicateOperator;

/**
 @abstract Returns the reference value used for comparison.
 */
@property (nonatomic, readonly, nullable) id value;

@end

/**
 @abstract The `LYRPredicateOperator` enumeration defines the set of comparison operators available for use by `LYRPredicate` objects.
 */
typedef NS_ENUM(NSUInteger, LYRCompoundPredicateType) {
    /**
     @abstract A logical AND compound predicate type.
     */
    LYRCompoundPredicateTypeAnd,
    
    /**
     @abstract A logical OR compound predicate type.
     */
    LYRCompoundPredicateTypeOr,
    
    /**
     @abstract A logical NOT compound predicate type.
     @discussion Query will only evaluate a single predicate in the compound predicate. If there is more than one sub-predicate in the `subpredicates` array, the query will perform the negation operation only on the first predicate, the rest of the predicates will be ignored.
     */
    LYRCompoundPredicateTypeNot
};

/**
 @abstract The `LYRCompoundPredicate` class is a subclass of `LYRPredicate` that provides support for combining multiple sub-predicates into a grouping with a conjunction operator such as
 `And`, `Or`, or `Not`.
 */
@interface LYRCompoundPredicate : LYRPredicate <NSCopying, NSCoding>

/**
 @abstract Creates and returns a new compound predicate with the given type and subpredicates in a given array.
 @property compoundPredicateType Compound predicate type, @see LYRCompoundPredicateType.
 @property subpredicates An array of `LYRPredicate` instances.
 @returns A newly created compound predicate object.
 */
+ (nonnull instancetype)compoundPredicateWithType:(LYRCompoundPredicateType)compoundPredicateType subpredicates:(nonnull NSArray<__kindof LYRPredicate *> *)subpredicates;

///---------------------------------------
/// @name Accessing Type and Subpredicates
///---------------------------------------

/**
 @abstract The compound predicate type for the receiver.
 */
@property (nonatomic, readonly) LYRCompoundPredicateType compoundPredicateType;

/**
 @abstract The receiver's subpredicates;
 */
@property (nonatomic, readonly, nonnull) NSArray *subpredicates;

@end
