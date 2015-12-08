//
//  CLLocalNotification.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/22/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLLocalNotification : NSObject

#pragma mark - Local notification class methods

+ (void)addLocalNotification:(NSString *)message
				  slideTitle:(NSString *)slideTitle
					 forDate:(NSDate *)date
				 badgeNumber:(NSInteger)badgeNumber;

+ (void)removeAllLocalNotifications;

@end
