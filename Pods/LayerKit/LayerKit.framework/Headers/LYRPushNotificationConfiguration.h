//
//  LYRPushNotificationOption.h
//  LayerKit
//
//  Created by Kabir Mahal on 9/11/15.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @abstract The `LYRPushNotificationConfiguration` class models the push notification configuration options provided by the Layer messaging service. It provides for customizing push notifications for all recipients of a message or on a per recipient basis.
 */
@interface LYRPushNotificationConfiguration : NSObject <NSCoding, NSCopying>

/**
 @abstract A string that is the displayed text in the push notification.
 */
@property (copy, nonatomic, nullable) NSString *alert;

/**
 @abstract The name of a sound file in the app bundle.
 */
@property (copy, nonatomic, nullable) NSString *sound;

/**
 @abstract A short string describing the purpose of the notification.
 */
@property (copy, nonatomic, nullable) NSString *title;

/**
 @abstract A string that sets the APNS category for the push.
 */
@property (copy, nonatomic, nullable) NSString *category;

/**
 @abstract A dictionary with additional definable APNS values. Can include `launch-image` key.
 */
@property (copy, nonatomic, nullable) NSDictionary<NSString *, NSString *> *apns;

/**
 @abstract A dictionary with optional additional text key-value pairs to be sent in the push notification.
 */
@property (copy, nonatomic, nullable) NSDictionary<NSString *, NSString *> *data;

/**
 @abstract The key to a title string in the Localizable.strings file for the current localization.
 @discussion This property should only be set in a default configuration.  Setting this property in a per recipient configuration raises an exception.
 */
@property (copy, nonatomic, nullable) NSString *titleLocalizationKey;

/**
 @abstract Variable string values to appear in place of the format specifiers in title-loc-key.
 @discussion This property should only be set in a default configuration.  Setting this property in a per recipient configuration raises an exception.
 */
@property (copy, nonatomic, nullable) NSArray<NSString *> *titleLocalizationArguments;

/**
 @abstract A key to an alert-message string in a Localizable.strings file for the current localization.
 @discussion This property should only be set in a default configuration.  Setting this property in a per recipient configuration raises an exception.
 */
@property (copy, nonatomic, nullable) NSString *alertLocalizationKey;

/**
 @abstract An array of variable string values to appear in place of the format specifiers in loc-key.
 @discussion This property should only be set in a default configuration.  Setting this property in a per recipient configuration raises an exception.
 */
@property (copy, nonatomic, nullable) NSArray<NSString *> *alertLocalizationArguments;

/**
 @abstract If specified, the system displays an alert that includes the Close and View buttons.
 @discussion This property should only be set in a default configuration.  Setting this property in a per recipient configuration raises an exception.
 */
@property (copy, nonatomic, nullable) NSString *actionLocalizationKey;

/**
 @abstract Sets a per participant configuration for the specified participant identifier.
 @discussion This method is used on a default configuration to add per participant customization.  If this method is called on an instance that has per
 participant configurations, an exception is raised.
 @param configuration A `LYRPushNotificationConfiguration` instance with values that override the default configuration.
 @param participantIdentifier A string that represents the participant identifier that will receive customized configuration.
 */
- (void)setPushConfiguration:(nonnull LYRPushNotificationConfiguration *)configuration forParticipant:(nonnull NSString *)participantIdentifier;

@end

