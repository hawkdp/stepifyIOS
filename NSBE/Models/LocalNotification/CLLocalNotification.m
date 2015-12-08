//
//  CLLocalNotification.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/22/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLLocalNotification.h"

@implementation CLLocalNotification

#pragma mark - Local notification class methods

+ (void)addLocalNotification:(NSString *)message
				  slideTitle:(NSString *)slideTitle
					 forDate:(NSDate *)date
				 badgeNumber:(NSInteger)badgeNumber
{
	// First of all, check if local notification access was granted by the user
	if ([UIApplication instancesRespondToSelector:@selector(currentUserNotificationSettings)]) {
		UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
		if (notificationSettings.types == UIUserNotificationTypeNone) {
			
			// Access not granted, return
			return;
		}
	}
	
	// Create local notification
	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
	
	// Set up local notification
	localNotification.fireDate = date;
	localNotification.alertBody = message;
	localNotification.alertAction = slideTitle;
	localNotification.soundName = UILocalNotificationDefaultSoundName;
	localNotification.applicationIconBadgeNumber = badgeNumber;
	
	// Schedule local notification
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
	
	NSLog(@"notification \"%@\" scheduled at %@", message, date);
}

+ (void)removeAllLocalNotifications
{
	// Cancel all local notifications
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	NSLog(@"all local notifications were cancelled");
}

@end
