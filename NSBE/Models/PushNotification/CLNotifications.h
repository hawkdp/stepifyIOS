//
//  CLNotifications.h
//  NSBE
//

#import <Foundation/Foundation.h>
#import "CLPushNotification.h"

#define kUserDefaultsPushNotificationsKey @"userDefaultsPushNotifications"
#define kNotificationsUpdatedNotification @"notificationsUpdated"

@protocol CLNotificationsDelegate <NSObject>

- (void)notificationsUpdated;

@end

@interface CLNotifications : NSObject

+ (CLNotifications *)sharedInstance;

- (NSArray *)allNotifications;
- (NSArray *)unreadNotifications;
- (NSArray *)notificationsGroupedByDate;
- (NSArray *)myFitClubNotificationsGroupedByDate;
- (NSArray *)theWorldNotificationsGroupedByDate;
- (void)addNotificationWithMessage:(NSString *)message type:(CLPushType)type pictureURL:(NSString *)pictureURL picture:(UIImage *)picture value:(NSInteger)value;
- (void)markTopNotificationRead;

- (void)savePushNotificationsToUserDefaults;

@end
