//
//  CLUserNotification.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/18/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLUserNotification.h"

#pragma mark - Properties dictionary key names

#define kUserNotificationsKey @"userNotifications"
#define kUserNotificationDelegate @"userNotificationDelegate"
#define kUserNotificationTypeKey @"userNotificationType"
#define kUserNotificationDateKey @"userNotificationDate"
#define kUserNotificationDayKey @"userNotificationDay"
#define kUserNotificationMessageKey @"userNotificationMessage"

@implementation NSDictionary (CLUserNotification)

@dynamic notificationType;
@dynamic notificationDate;
@dynamic notificationDay;
@dynamic notificationMessage;

#pragma mark - All the user notifications

+ (NSMutableDictionary *)notificationsData
{
	static NSMutableDictionary *notificationsData;
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		
		if (!notificationsData) {
			// The user notifications data instance hasn't been created yet, so try to retrieve the notifications
			// from user defaults
			NSArray *notifications = [CLUserNotification loadUserNotificationsFromUserDefaults];
			
			// If user notifications data was loaded from user defaults, use it, otherwise create a new
			// notification data instace
			notificationsData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								 [[NSMutableArray alloc] initWithArray:notifications ?: @[]],
								 kUserNotificationsKey, nil];
		}
	});
	
	return notificationsData;
}

+ (NSArray *)notifications
{
	return [CLUserNotification notificationsData][kUserNotificationsKey];
}

#pragma mark - Setters and getters

- (CLUserNotificationType)notificationType
{
	return [self[kUserNotificationTypeKey] integerValue];
}

- (void)setNotificationType:(CLUserNotificationType)notificationType
{
	// Do nothing
}

- (NSDate *)notificationDate
{
	return self[kUserNotificationDateKey];
}

- (void)setNotificationDate:(NSDate *)notificationDate
{
	// Do nothing
}

- (NSInteger)notificationDay
{
	return [self[kUserNotificationDayKey] integerValue];
}

- (void)setNotificationDay:(NSInteger)notificationDay
{
	// Do nothing
}

- (NSString *)notificationMessage
{
	return self[kUserNotificationMessageKey];
}

- (void)setNotificationMessage:(NSString *)notificationMessage
{
	// Do nothing
}

#pragma mark - User notifications class methods

+ (void)setUserNotificationDelegate:(id<CLUserNotificationProtocol>)delegate
{
	if (delegate) {
		
		// Add delegate
		[CLUserNotification notificationsData][kUserNotificationDelegate] = delegate;
	} else {
		
		// Remove delegate
		[CLUserNotification removeUserNotificationDelegate];
	}
}

+ (void)removeUserNotificationDelegate
{
	[[CLUserNotification notificationsData] removeObjectForKey:kUserNotificationDelegate];
}

+ (void)setNotification:(CLUserNotificationType)type
				forDate:(NSDate *)date
				 forDay:(NSInteger)day
			withMessage:(NSString *)message
{
	// Get all notifications
	NSMutableArray *notifications = [CLUserNotification notificationsData][kUserNotificationsKey];
	
	// Create new notification
	CLUserNotification *notification = @{kUserNotificationTypeKey : @(type),
										 kUserNotificationDateKey : date ?: [NSDate date],
										 kUserNotificationDayKey : @(day),
										 kUserNotificationMessageKey : message ?: @""};
	
	// Evaluate notification position and replacing
	switch (type) {
		case kCLUserNotificationTypeUnknown:
		case kCLUserNotificationTypeRank:
		case kCLUserNotificationTypeStepsLogged: {
			BOOL flag = NO;
			
			for (int i = 0; i < notifications.count; i++) {
				CLUserNotification *notification = notifications[i];
				
				if (notification.notificationType == type && notification.notificationDay == day) {
					
					// Replace found notification with the new notification
					flag = YES;
					[notifications replaceObjectAtIndex:i
											 withObject:@{kUserNotificationTypeKey : @(type),
														  kUserNotificationDateKey : notification.notificationDate,
														  kUserNotificationDayKey : @(day),
														  kUserNotificationMessageKey : message ?: @""}];
				}
			}
			
			// Add notification in the notifications if another one has not been found
			if (!flag) {
				[notifications addObject:notification];
			}
			break;
		}
		case kCLUserNotificationTypeSyncing:
		case kCLUserNotificationTypeSyncSuccess:
		case kCLUserNotificationTypeSyncFailure: {
			
			// Remove any notification with type syncing, sync success or sync failure
			NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(CLUserNotification *notification,
																				 NSDictionary *bindings) {
				return (notification.notificationType != kCLUserNotificationTypeSyncing &&
						notification.notificationType != kCLUserNotificationTypeSyncSuccess &&
						notification.notificationType != kCLUserNotificationTypeSyncFailure);
			}];
			notifications = [[NSMutableArray alloc] initWithArray:[notifications filteredArrayUsingPredicate:filterPredicate]];
			
			// Add notification in the notifications array
			[notifications addObject:notification];
			
			// Replace notifications array
			[CLUserNotification notificationsData][kUserNotificationsKey] = notifications;
			break;
		}
	}
	
	// Sort the notifications array
	[notifications sortUsingComparator:^NSComparisonResult(CLUserNotification *ntf1, CLUserNotification *ntf2) {
		if (ntf1.notificationType == kCLUserNotificationTypeSyncing ||
			ntf1.notificationType == kCLUserNotificationTypeSyncSuccess ||
			ntf1.notificationType == kCLUserNotificationTypeSyncFailure) {
			return NSOrderedAscending;
		}
		if (ntf2.notificationType == kCLUserNotificationTypeSyncing ||
			ntf2.notificationType == kCLUserNotificationTypeSyncSuccess ||
			ntf2.notificationType == kCLUserNotificationTypeSyncFailure) {
			return NSOrderedDescending;
		}
		return [ntf2.notificationDate compare:ntf1.notificationDate];
	}];
	
	// Call delegate user notifications updated selector
	id delegate = [CLUserNotification notificationsData][kUserNotificationDelegate];
	if (delegate && [delegate conformsToProtocol:@protocol(CLUserNotificationProtocol)] &&
		[delegate respondsToSelector:@selector(userNotificationsUpdated:)]) {
		
		// Call selector
		[(id<CLUserNotificationProtocol>) delegate userNotificationsUpdated:
		 [CLUserNotification notificationsData][kUserNotificationsKey]];
	}
}

#pragma mark - User defaults management methods

+ (void)saveUserNotificationsToUserDefaults:(NSArray *)notifications
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:notifications forKey:kUserDefaultsUserNotificationsKey];
	[userDefaults synchronize];
	
	NSLog(@"saving user notifications to user defaults");
}

+ (NSArray *)loadUserNotificationsFromUserDefaults
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults objectForKey:kUserDefaultsUserNotificationsKey];
}

@end
