//
//  CLNotifications.m
//  NSBE
//

#import "CLNotifications.h"
#import "Utils.h"

@interface CLNotifications ()

@property(nonatomic, strong) NSMutableArray *notifications;
@end

@implementation CLNotifications

#pragma mark - Singleton

+ (CLNotifications *)sharedInstance
{
    static CLNotifications *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CLNotifications alloc] initWithNotifications:[[self loadPushNotificationsFromUserDefaults] mutableCopy] ?: [NSMutableArray new]];
    });
    return sharedInstance;
}

#pragma mark - Initializer

- (id)initWithNotifications:(NSArray *)notifications
{
    self = [super init];
    if (self) {
        _notifications = [notifications mutableCopy];
    }
    return self;
}

#pragma mark - Get notifications

- (NSArray *)allNotifications
{
    return self.notifications;
}

- (NSArray *)unreadNotifications
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"readFlag == NO"];
    return [self.notifications filteredArrayUsingPredicate:predicate];
}

- (NSArray *)notificationsGroupedByDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    NSArray *reverseOrderUsingComparator = [self.notifications sortedArrayUsingComparator:^(CLPushNotification *obj1, CLPushNotification *obj2) {
        return [obj2.receivedDate compare:obj1.receivedDate];
    }];

    NSMutableSet *dates = [[NSMutableSet alloc] init];
    [reverseOrderUsingComparator enumerateObjectsUsingBlock:^(CLPushNotification *pushNotification, NSUInteger idx, BOOL *stop) {
        NSString *dateStr = [dateFormatter stringFromDate:pushNotification.receivedDate];
        [dates addObject:dateStr];
//        [dates addObject:pushNotification.receivedDate];
    }];

    NSArray *ascendingdates = [dates allObjects];
    NSArray *reverseOrderDates = [ascendingdates sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2) {
        return [obj2 compare:obj1];
    }];

    [reverseOrderDates enumerateObjectsUsingBlock:^(NSString *pushDateStr, NSUInteger idx, BOOL *stop) {
        NSDate *date = [dateFormatter dateFromString:pushDateStr];
        NSArray *pushesForDate = [self fetchNotificationsWithDate:date];
        NSDictionary *groupedNotifications = @{pushDateStr : pushesForDate};
        [result addObject:groupedNotifications];
    }];

    return result;
}

- (NSArray *)myFitClubNotificationsGroupedByDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    NSMutableArray *result = [[NSMutableArray alloc] init];

    NSArray *reverseOrderUsingComparator = [self.notifications sortedArrayUsingComparator:^(CLPushNotification *obj1, CLPushNotification *obj2) {
        return [obj2.receivedDate compare:obj1.receivedDate];
    }];

    NSMutableSet *dates = [[NSMutableSet alloc] init];
    [reverseOrderUsingComparator enumerateObjectsUsingBlock:^(CLPushNotification *pushNotification, NSUInteger idx, BOOL *stop) {
        NSString *dateStr = [dateFormatter stringFromDate:pushNotification.receivedDate];
        [dates addObject:dateStr];
//        [dates addObject:pushNotification.receivedDate];
    }];

    NSArray *ascendingdates = [dates allObjects];
    NSArray *reverseOrderDates = [ascendingdates sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2) {
        return [obj2 compare:obj1];
    }];

    [reverseOrderDates enumerateObjectsUsingBlock:^(NSString *pushDateStr, NSUInteger idx, BOOL *stop) {
        NSDate *date = [dateFormatter dateFromString:pushDateStr];
        NSArray *pushesForDate = [self fetchMyFitClubNotificationsWithDate:date];
        NSDictionary *groupedNotifications = @{pushDateStr : pushesForDate};
        if (pushesForDate.count > 0) {
            [result addObject:groupedNotifications];
        }
    }];
    
    return result;
}

- (NSArray *)theWorldNotificationsGroupedByDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    NSMutableArray *result = [[NSMutableArray alloc] init];

    NSArray *reverseOrderUsingComparator = [self.notifications sortedArrayUsingComparator:^(CLPushNotification *obj1, CLPushNotification *obj2) {
        return [obj2.receivedDate compare:obj1.receivedDate];
    }];

    NSMutableSet *dates = [[NSMutableSet alloc] init];
    [reverseOrderUsingComparator enumerateObjectsUsingBlock:^(CLPushNotification *pushNotification, NSUInteger idx, BOOL *stop) {
        NSString *dateStr = [dateFormatter stringFromDate:pushNotification.receivedDate];
        [dates addObject:dateStr];
//        [dates addObject:pushNotification.receivedDate];
    }];

    NSArray *ascendingdates = [dates allObjects];
    NSArray *reverseOrderDates = [ascendingdates sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2) {
        return [obj2 compare:obj1];
    }];

    [reverseOrderDates enumerateObjectsUsingBlock:^(NSString *pushDateStr, NSUInteger idx, BOOL *stop) {
        NSDate *date = [dateFormatter dateFromString:pushDateStr];
        NSArray *pushesForDate = [self fetchTheWorldNotificationsWithDate:date];
        NSDictionary *groupedNotifications = @{pushDateStr : pushesForDate};
        if (pushesForDate.count > 0) {
            [result addObject:groupedNotifications];
        }
    }];
    
    return result;
}

#pragma mark - Change push notifications

- (void)addNotificationWithMessage:(NSString *)message type:(CLPushType)type pictureURL:(NSString *)pictureURL picture:(UIImage *)picture value:(NSInteger)value
{
    CLPushNotification *newNotification = [[CLPushNotification alloc] initWithMessage:message type:type pictureURL:pictureURL picture:picture value:value];
    [self.notifications addObject:newNotification];

    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationsUpdatedNotification object:nil];

    [self savePushNotificationsToUserDefaults];
}

- (void)markTopNotificationRead
{
    ((CLPushNotification *) [[self unreadNotifications] lastObject]).readFlag = YES;

    [self savePushNotificationsToUserDefaults];
}

#pragma mark - NSUserDefaults

- (void)savePushNotificationsToUserDefaults
{
    [self savePushNotificationsToUserDefaults:self.notifications];
}

- (void)savePushNotificationsToUserDefaults:(NSArray *)notifications
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:notifications];
    [userDefaults setObject:data forKey:kUserDefaultsPushNotificationsKey];
    [userDefaults synchronize];
}

+ (NSArray *)loadPushNotificationsFromUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:kUserDefaultsPushNotificationsKey];
    NSArray *notifications = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return notifications;
}

#pragma mark - Private

- (NSArray *)fetchNotificationsWithDate:(NSDate *)date {
    NSArray *reverseOrderUsingComparator = [self.notifications sortedArrayUsingComparator:^(CLPushNotification *obj1, CLPushNotification *obj2) {
        return [obj2.receivedDate compare:obj1.receivedDate];
    }];

    NSMutableArray *result = [[NSMutableArray alloc] init];
    [reverseOrderUsingComparator enumerateObjectsUsingBlock:^(CLPushNotification *pushNotification, NSUInteger idx, BOOL *stop) {
        if ([Utils isDate:pushNotification.receivedDate sameDayAsDate:date]) {
            [result addObject:pushNotification];
        }
    }];
    return result;
}

- (NSArray *)fetchMyFitClubNotificationsWithDate:(NSDate *)date {
    NSArray *reverseOrderUsingComparator = [self.notifications sortedArrayUsingComparator:^(CLPushNotification *obj1, CLPushNotification *obj2) {
        return [obj2.receivedDate compare:obj1.receivedDate];
    }];

    NSMutableArray *result = [[NSMutableArray alloc] init];
    [reverseOrderUsingComparator enumerateObjectsUsingBlock:^(CLPushNotification *pushNotification, NSUInteger idx, BOOL *stop) {
        BOOL isMyFitclub = pushNotification.type == 0 || pushNotification.type == 7 || pushNotification.type == 8 || pushNotification.type == 9 || pushNotification.type == 10 || pushNotification.type == 11 || pushNotification.type == 12 || pushNotification.type == 13 || pushNotification.type == 14 || pushNotification.type == 15;
        if ([Utils isDate:pushNotification.receivedDate sameDayAsDate:date] && isMyFitclub) {
            [result addObject:pushNotification];
        }
    }];
    return result;
}

- (NSArray *)fetchTheWorldNotificationsWithDate:(NSDate *)date {
    NSArray *reverseOrderUsingComparator = [self.notifications sortedArrayUsingComparator:^(CLPushNotification *obj1, CLPushNotification *obj2) {
        return [obj2.receivedDate compare:obj1.receivedDate];
    }];

    NSMutableArray *result = [[NSMutableArray alloc] init];
    [reverseOrderUsingComparator enumerateObjectsUsingBlock:^(CLPushNotification *pushNotification, NSUInteger idx, BOOL *stop) {
        BOOL isMyFitclub = pushNotification.type == 0 || pushNotification.type == 7 || pushNotification.type == 8 || pushNotification.type == 9 || pushNotification.type == 10 || pushNotification.type == 11 || pushNotification.type == 12 || pushNotification.type == 13 || pushNotification.type == 14 || pushNotification.type == 15;
        if ([Utils isDate:pushNotification.receivedDate sameDayAsDate:date] && !isMyFitclub) {
            [result addObject:pushNotification];
        }
    }];
    return result;
}

@end
