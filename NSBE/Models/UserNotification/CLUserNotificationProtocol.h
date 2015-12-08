//
//  CLUserNotificationProtocol.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/18/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CLUserNotificationProtocol <NSObject>

@optional

- (void)userNotificationsUpdated:(NSArray *)notifications;

@end
