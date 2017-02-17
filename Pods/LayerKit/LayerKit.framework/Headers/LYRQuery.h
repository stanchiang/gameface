//
//  LYRQuery.h
//  LayerKit
//
//  Created by Blake Watters on 10/20/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRPredicate.h"

/**
 @abstract Queryable models declare support for querying on a per attribute basis via the `LYR_QUERYABLE_PROPERTY` annotation.
 @discussion Not all operators are available for each queryable attribute. Consult the documentation on each property for details about querying semantics.
 */
#define LYR_QUERYABLE_PROPERTY __attribute__((annotate("lyr_queryable_property")))

/**
 @abstract Properties that are queryable from an associated class declare the support via the `LYR_QUERYABLE_FROM` annotation.
 */
#define LYR_QUERYABLE_FROM(klass) __attribute__((annotate("lyr_queryable_property_from_#klass")))

/**
 @abstract The `LYRQueryable` protocol is adopted by classes that are queryable via `LYRQuery`.
 */
@protocol LYRQueryable <NSObject>

/**
 @abstract Returns the unique identifier for the receiver as a URL.
 */
@property (nonatomic, readonly, nonnull) NSURL *identifier;

@end

/**
 @abstract The domain for errors emitted by the querying system.
 */
extern NSString * _Nonnull const LYRQueryingErrorDomain;

/**
 @abstract Codes for errors in the `LYRQueryingErrorDomain` error domain.
 */
typedef NS_ENUM(NSUInteger, LYRQueryError) {
    LYRQueryErrorUnqueryableProperty        =   12000, // The specified property is not available for querying.
    LYRQueryErrorUnsupportedPredicate       =   12001, // The property & operator specified are not a supported combination.
    LYRQueryErrorUnsupportedSortDescriptor  =   12002, // The property specified is not available for sorting.
    LYRQueryErrorInvalidInputValue          =   12003  // The value given is not usable with the given predicate operator.
};

/**
 @abstract Specifies the type of result produced by the execution of a query.
 */
typedef NS_ENUM(NSUInteger, LYRQueryResultType) {
    /**
     @abstract The query is to return fully realized object instances.
     */
    LYRQueryResultTypeObjects,
    
    /**
     @abstract The query is to return object identifier URL objects.
     */
    LYRQueryResultTypeIdentifiers,
    
    /**
     @abstract The query is to return a count of the number of results it would return if executed.
     */
    LYRQueryResultTypeCount
};

/**
 @abstract The `LYRQuery` class provides a flexible querying interface for Layer content.
 @discussion Instances of `LYRQuery` are used to query the local database for messaging content. Queries target a specific queryable class
 and apply a predicate that constrains the search. Predicates are expressed in terms of a public property (such as `createdAt` or `isUnread`), an operator
 (such as 'is equal to' or 'is greater than or equal to'), and a comparison value. The sort order of the results can be affected by applying one or more
 sort descriptors which also bind to a public property and are applied in either ascending or descending order. To facilitate pagination, queries may be further
 constrained by applying a limit and offset value. Query results can be returned as either fully realized object instances, object identifiers, or as an aggregate
 count of the total number of objects matching the query.
 */
@interface LYRQuery : NSObject <NSCopying, NSCoding>

///-----------------------
/// @name Creating a Query
///-----------------------

/**
 @abstract Creates and returns a new query object for the given queryable class.
 @param queryableClass A class that conforms to the `LYRQueryable` protocol that is to be queried.
 @return A newly created query object.
 */
+ (nonnull instancetype)queryWithQueryableClass:(nonnull Class<LYRQueryable>)queryableClass;

/**
 @abstract Returns the queryable class that the receiver is bound to.
 */
@property (nonatomic, readonly, nonnull) Class<LYRQueryable> queryableClass;

///------------------------
/// @name Query Constraints
///------------------------

/**
 @abstract The predicate of the receiver.
 */
@property (nonatomic, nullable) LYRPredicate *predicate;

/**
 @abstract The limit configures the maximum number of objects to be returned when the query is executed.
 @discussion A value of `NSUIntegerMax` (the default) indicates that no limit should be applied.
 */
@property (nonatomic) NSUInteger limit;

/**
 @abstract The offset configures the number of rows that are to be skipped in the result set before results are returned.
 @discussion The default value is zero. The `offset` isn't used if the `limit` is not defined.
 */
@property (nonatomic) NSUInteger offset;

///--------------
/// @name Sorting
///--------------

/**
 @abstract Configures the sort descriptors used to order the result set.
 @discussion The sort descriptors specify how the objects returned when the query is executed should be ordered (for example by creation date or index). The sort descriptors are 
 applied in the order in which they appear in the `sortDescriptors` array. A value of nil (the default) means that no explicit sorting is applied and the results are returned in database row order.
 */
@property (nonatomic, nullable) NSArray<NSSortDescriptor *> *sortDescriptors;

///----------------------------------------
/// @name Managing How Results Are Returned
///----------------------------------------

/**
 @abstract Configures how results are returned when the receiver is executed.
 @discussion The default is `LYRQueryResultTypeObjects`.
 */
@property (nonatomic) LYRQueryResultType resultType;

@end
