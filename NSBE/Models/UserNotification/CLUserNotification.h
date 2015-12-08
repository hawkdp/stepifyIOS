//
//  CLUserNotification.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/18/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLUserNotificationProtocol.h"

#pragma mark - Type defines and enums

#define kUserDefaultsUserNotificationsKey @"userDefaultsUserNotifications"

typedef NSDictionary CLUserNotification;

#pragma mark - User notifications types

typedef NS_ENUM(NSInteger, CLUserNotificationType) {
	kCLUserNotificationTypeUnknown			= 0,
	kCLUserNotificationTypeRank				= 1,
	kCLUserNotificationTypeStepsLogged		= 2,
	kCLUserNotificationTypeSyncing			= 3,
	kCLUserNotificationTypeSyncSuccess		= 4,
	kCLUserNotificationTypeSyncFailure		= 5
};

@interface NSDictionary (CLUserNotification)

#pragma mark - User notification properties

@property (nonatomic, readonly, assign) CLUserNotificationType notificationType;

@property (nonatomic, readonly, strong) NSDate *notificationDate;

@property (nonatomic, readonly, assign) NSInteger notificationDay;

@property (nonatomic, readonly, assign) NSString *notificationMessage;

#pragma mark - All the user notifications

+ (NSArray *)notifications;

#pragma mark - User notifications class methods

+ (void)setUserNotificationDelegate:(id<CLUserNotificationProtocol>)delegate;

+ (void)removeUserNotificationDelegate;

+ (void)setNotification:(CLUserNotificationType)type
				forDate:(NSDate *)date
				 forDay:(NSInteger)day
			withMessage:(NSString *)message;

#pragma mark - User defaults management methods

+ (void)saveUserNotificationsToUserDefaults:(NSArray *)notifications;

+ (NSArray *)loadUserNotificationsFromUserDefaults;

@end
