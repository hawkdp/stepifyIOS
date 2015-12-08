//
//  CLUser.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#define ENCODE_OBJECT_FOR_KEY(ENCODER, OBJ) [ENCODER encodeObject:self.OBJ forKey:@#OBJ]
#define DECODE_OBJECT_FOR_KEY(DECODER, OBJ) self.OBJ = [DECODER decodeObjectForKey:@#OBJ]
#define ENCODE_BOOL_FOR_KEY(ENCODER, OBJ) [ENCODER encodeBool:self.OBJ forKey:@#OBJ]
#define DECODE_BOOL_FOR_KEY(DECODER, OBJ) self.OBJ = [DECODER decodeBoolForKey:@#OBJ]
#define ENCODE_INTEGER_FOR_KEY(ENCODER, OBJ) [ENCODER encodeInteger:self.OBJ forKey:@#OBJ]
#define DECODE_INTEGER_FOR_KEY(DECODER, OBJ) self.OBJ = [DECODER decodeIntegerForKey:@#OBJ]

#import "SDWebImage/SDWebImageManager.h"
#import "CLUser.h"
#import "Stylesheet.h"
#import "CLMiniGameRule.h"
#import "CLMiniGame.h"
#import "CLFacebookHandler.h"
#import "Utils.h"
#import "CLMiniGameMaxStepsRule.h"

@implementation CLUser

#pragma mark - Properties

- (NSInteger)challengeDurationWeeks {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *challengeEndDate = [cal dateByAddingUnit:NSCalendarUnitMonth
                                               value:self.challengeDurationMonths.integerValue
                                              toDate:self.challengeStartDate
                                             options:0];

    return [Utils weeksBetweenDate:self.challengeStartDate
                           andDate:challengeEndDate];
}

- (NSNumber *)maxSteps {
    for (CLMiniGameRule *miniGameRule in self.currentMiniGame.setOfRules.allObjects) {
        if ([miniGameRule isKindOfClass:[CLMiniGameMaxStepsRule class]]) {
            CLMiniGameMaxStepsRule *maxStepsRule = (CLMiniGameMaxStepsRule *)miniGameRule;
            _maxSteps = @(maxStepsRule.stepsCountLimit);
            return _maxSteps;
        }
    }
    return @(0);
}

- (NSMutableDictionary *)stepsForDay {
    if (!_stepsForDay) {
        _stepsForDay = [[NSMutableDictionary alloc] init];
    }
    return _stepsForDay;
}

- (NSMutableDictionary *)stepsForDayWithoutLimit {
    if (!_stepsForDayWithoutLimit) {
        _stepsForDayWithoutLimit = [[NSMutableDictionary alloc] init];
    }
    return _stepsForDayWithoutLimit;
}

- (NSDictionary *)stepsForCurrentDay {
    NSArray *stringDates = [self.stepsForDay allKeys];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [stringDates enumerateObjectsUsingBlock:^(NSString *strDate, NSUInteger idx, BOOL *stop) {
        NSDate *date = [dateFormatter dateFromString:strDate];
        if ([Utils isDate:date sameDayAsDate:[NSDate date]]) {
            NSNumber *steps = self.stepsForDay[strDate];
            [result setValue:steps
                      forKey:strDate];
//            *stop = YES;
        }
    }];
    return result;
}

- (NSDictionary *)stepsForCurrentDayWithoutLimit {
    NSArray *stringDates = [self.stepsForDay allKeys];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [stringDates enumerateObjectsUsingBlock:^(NSString *strDate, NSUInteger idx, BOOL *stop) {
        NSDate *date = [dateFormatter dateFromString:strDate];
        if ([Utils isDate:date sameDayAsDate:[NSDate date]]) {
            NSNumber *steps = self.stepsForDayWithoutLimit[strDate];
            [result setValue:steps
                      forKey:strDate];
            //            *stop = YES;
        }
    }];
    return result;
}

- (NSMutableArray *)challengeMiniGames {
    if (!_challengeMiniGames) {
        _challengeMiniGames = [[NSMutableArray alloc] init];
    }
    return _challengeMiniGames;
}

- (CLMiniGame *)currentMiniGame {
    __block CLMiniGame *currentGame;

    [self.challengeMiniGames enumerateObjectsUsingBlock:^(CLMiniGame *game, NSUInteger idx, BOOL *stop) {

        NSDate *currentDate = [NSDate date];
        NSDate *startDate = game.startDate;
        NSDate *endDate = [startDate dateByAddingTimeInterval:game.durationDays * 86400];

        if (([currentDate compare:startDate] == NSOrderedSame || [currentDate compare:startDate] == NSOrderedDescending) && [currentDate compare:endDate] == NSOrderedAscending) {
            currentGame = game;
            *stop = YES;
        }
    }];

    return currentGame;
}

- (void)setIsDisqualified:(BOOL)isDisqualified {
    if (!isDisqualified) {
        self.isHourlyRulePassed = YES;
        self.isDailyRulePassed = YES;
        self.isMaxStepsRulePassed = YES;
    }
    _isDisqualified = isDisqualified;
}

#pragma mark - Singleton

+ (CLUser *)user {
    static CLUser *sharedInstance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        if (!sharedInstance) {
            // The user data instance hasn't been created yet, so try to retrieve data from user defaults
            CLUser *user = [CLUser loadUserFromUserDefaults];

            // If user was loaded from user defaults, use it, otherwise create a new shared instace
            sharedInstance = user ?: [[CLUser alloc] init];
//            sharedInstance = [[CLUser alloc] init];
        }
    });

    return sharedInstance;
}

#pragma mark - NSObject methods

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        self.isHourlyRulePassed = YES;
        self.isDailyRulePassed = YES;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\r"
                                              "accessToken: %@\r"
                                              "pushToken: %@\r"
                                              "firstName: %@\r"
                                              "lastName: %@\r"
                                              "email: %@\r"
                                              "password: %@\r"
                                              "phoneNumber: %@\r"
                                              "gender: %@\r"
                                              "birthdate: %@\r"
                                              "age: %@\r"
                                              "heightFeet: %@\r"
                                              "heightInches: %@\r"
                                              "weight: %@\r"
                                              "facebookID: %@\r"
                                              "profilePictureURL: %@\r"
                                              "profilePicture: %@\r"
                                              "stepsForDay: %@\r"
                                              "challengeStartDate: %@\r"
                                              "device: %td\r",
                                      self.accessToken, self.pushToken, self.firstName, self.lastName, self.email, self.password, self.phoneNumber, self.gender, self.birthdate,
                                      self.age, self.heightFeet, self.heightInches, self.weight, self.facebookID, self.profilePictureURL,
                                      self.profilePicture, self.stepsForDay, self.challengeStartDate, self.device];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        // Custom initialization
        NSLog(@"init with decoder");

        // Set key for decoding every property
        DECODE_OBJECT_FOR_KEY(aDecoder, accessToken);
        DECODE_OBJECT_FOR_KEY(aDecoder, email);
        DECODE_OBJECT_FOR_KEY(aDecoder, password);
        DECODE_OBJECT_FOR_KEY(aDecoder, firstName);
        DECODE_OBJECT_FOR_KEY(aDecoder, lastName);
        DECODE_OBJECT_FOR_KEY(aDecoder, phoneNumber);
        DECODE_OBJECT_FOR_KEY(aDecoder, gender);
        DECODE_OBJECT_FOR_KEY(aDecoder, birthdate);
        DECODE_OBJECT_FOR_KEY(aDecoder, age);
        DECODE_OBJECT_FOR_KEY(aDecoder, heightFeet);
        DECODE_OBJECT_FOR_KEY(aDecoder, heightInches);
        DECODE_OBJECT_FOR_KEY(aDecoder, weight);
        DECODE_OBJECT_FOR_KEY(aDecoder, facebookID);
        DECODE_OBJECT_FOR_KEY(aDecoder, linkedInID);
        DECODE_OBJECT_FOR_KEY(aDecoder, profilePictureURL);
        DECODE_OBJECT_FOR_KEY(aDecoder, profilePicture);
        DECODE_OBJECT_FOR_KEY(aDecoder, stepsForDay);
        DECODE_OBJECT_FOR_KEY(aDecoder, stepsForDayWithoutLimit);
        DECODE_OBJECT_FOR_KEY(aDecoder, challengeName);
        DECODE_OBJECT_FOR_KEY(aDecoder, challengeId);
        DECODE_OBJECT_FOR_KEY(aDecoder, challengeMiniGames);
        DECODE_OBJECT_FOR_KEY(aDecoder, challengeStartDate);
        DECODE_OBJECT_FOR_KEY(aDecoder, userId);
        DECODE_INTEGER_FOR_KEY(aDecoder, device);
        DECODE_BOOL_FOR_KEY(aDecoder, isHourlyRulePassed);
        DECODE_BOOL_FOR_KEY(aDecoder, isDailyRulePassed);
        DECODE_BOOL_FOR_KEY(aDecoder, isDisqualified);
        DECODE_OBJECT_FOR_KEY(aDecoder, lastSyncDate);
        // Create a mutable copy for steps for day
        self.stepsForDay = [self.stepsForDay mutableCopy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"encode with coder");

    // Encode every property for a key
    ENCODE_OBJECT_FOR_KEY(aCoder, accessToken);
    ENCODE_OBJECT_FOR_KEY(aCoder, lastSyncDate);
    ENCODE_OBJECT_FOR_KEY(aCoder, email);
    ENCODE_OBJECT_FOR_KEY(aCoder, password);
    ENCODE_OBJECT_FOR_KEY(aCoder, firstName);
    ENCODE_OBJECT_FOR_KEY(aCoder, lastName);
    ENCODE_OBJECT_FOR_KEY(aCoder, phoneNumber);
    ENCODE_OBJECT_FOR_KEY(aCoder, gender);
    ENCODE_OBJECT_FOR_KEY(aCoder, birthdate);
    ENCODE_OBJECT_FOR_KEY(aCoder, age);
    ENCODE_OBJECT_FOR_KEY(aCoder, heightFeet);
    ENCODE_OBJECT_FOR_KEY(aCoder, heightInches);
    ENCODE_OBJECT_FOR_KEY(aCoder, weight);
    ENCODE_OBJECT_FOR_KEY(aCoder, facebookID);
    ENCODE_OBJECT_FOR_KEY(aCoder, linkedInID);
    ENCODE_OBJECT_FOR_KEY(aCoder, profilePictureURL);
    ENCODE_OBJECT_FOR_KEY(aCoder, profilePicture);
    ENCODE_OBJECT_FOR_KEY(aCoder, stepsForDay);
    ENCODE_OBJECT_FOR_KEY(aCoder, challengeName);
    ENCODE_OBJECT_FOR_KEY(aCoder, challengeId);
    ENCODE_OBJECT_FOR_KEY(aCoder, challengeMiniGames);
    ENCODE_OBJECT_FOR_KEY(aCoder, challengeStartDate);
    ENCODE_OBJECT_FOR_KEY(aCoder, userId);
    ENCODE_INTEGER_FOR_KEY(aCoder, device);
    ENCODE_BOOL_FOR_KEY(aCoder, isHourlyRulePassed);
    ENCODE_BOOL_FOR_KEY(aCoder, isDailyRulePassed);
    ENCODE_BOOL_FOR_KEY(aCoder, isDisqualified);
}

#pragma mark - Public methods

- (void)updateStepsDataWithDictionary:(NSDictionary *)stepsDictionary {
    NSArray *stringDates = [self.stepsForDay allKeys];
    NSArray *stepsDictionaryDates = [stepsDictionary allKeys];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    [stepsDictionaryDates enumerateObjectsUsingBlock:^(NSString *strDate, NSUInteger idx, BOOL *stop) {
        NSDate *date = [dateFormatter dateFromString:strDate];
        NSDate *dateWithoutTime1 = [Utils dateWithOutTime:date];

        [stringDates enumerateObjectsUsingBlock:^(NSString *stringDate, NSUInteger i, BOOL *s) {
            NSDate *parameterDate = [dateFormatter dateFromString:stringDate];
            NSDate *dateWithoutTime2 = [Utils dateWithOutTime:parameterDate];
            if ([Utils isDate:dateWithoutTime1 sameDayAsDate:dateWithoutTime2]) {
                NSNumber *steps = stepsDictionary[strDate];

//                [[CLUser user].stepsForDay setValue:steps forKey:stringDate];
                [[CLUser user].stepsForDay removeObjectForKey:stringDate];

                [[CLUser user].stepsForDay setValue:steps forKey:strDate];
//            *stop = YES;
            }
        }];
    }];
    
    NSLog(@"%@", self.stepsForDay);
}

- (void)updateStepsForDayWithoutLimit:(NSDictionary *)stepsDictionary {
    NSArray *stringDates = [self.stepsForDay allKeys];
    NSArray *stepsDictionaryDates = [stepsDictionary allKeys];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [stepsDictionaryDates enumerateObjectsUsingBlock:^(NSString *strDate, NSUInteger idx, BOOL *stop) {
        NSDate *date = [dateFormatter dateFromString:strDate];
        NSDate *dateWithoutTime1 = [Utils dateWithOutTime:date];
        
        [stringDates enumerateObjectsUsingBlock:^(NSString *stringDate, NSUInteger i, BOOL *s) {
            NSDate *parameterDate = [dateFormatter dateFromString:stringDate];
            NSDate *dateWithoutTime2 = [Utils dateWithOutTime:parameterDate];
            if ([Utils isDate:dateWithoutTime1 sameDayAsDate:dateWithoutTime2]) {
                NSNumber *steps = stepsDictionary[strDate];
                
                //                [[CLUser user].stepsForDay setValue:steps forKey:stringDate];
                [[CLUser user].stepsForDayWithoutLimit removeObjectForKey:stringDate];
                
                [[CLUser user].stepsForDayWithoutLimit setValue:steps forKey:strDate];
                //            *stop = YES;
            }
        }];
    }];
}


+ (UIImage *)getDeviceIconImage:(CLUserDevice)device {
    switch (device) {
        case kCLUserDeviceFitbit: {
            return HOME_VIEW_CONTROLLER_DEVICE_ICON_IMAGE_FITBIT;
        }
        case kCLUserDeviceJawbone: {
            return HOME_VIEW_CONTROLLER_DEVICE_ICON_IMAGE_JAWBONE;
        }
        case kCLUserDeviceHealthKit: {
            return HOME_VIEW_CONTROLLER_DEVICE_ICON_IMAGE_HEALTHKIT;
        }
        case kCLUserDeviceNoDevice: {
            return HOME_VIEW_CONTROLLER_DEVICE_ICON_IMAGE_NO_DEVICE;
        }
    }
}

+ (UIImage *)getDeviceImage:(CLUserDevice)device {
    switch (device) {
        case kCLUserDeviceFitbit: {
            return HOME_VIEW_CONTROLLER_DEVICE_IMAGE_FITBIT;
        }
        case kCLUserDeviceJawbone: {
            return HOME_VIEW_CONTROLLER_DEVICE_IMAGE_JAWBONE;
        }
        case kCLUserDeviceHealthKit: {
            return HOME_VIEW_CONTROLLER_DEVICE_IMAGE_HEALTHKIT;
        }
        case kCLUserDeviceNoDevice: {
            return HOME_VIEW_CONTROLLER_DEVICE_IMAGE_NO_DEVICE;
        }
        default: {
            return nil;
        }
    }
}

- (void)fetchProfilePictureWithCompletionBlock:(CLUserPhotoCompletion)completionBlock {
    if ([CLUser user].profilePictureURL) {
        [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:[CLUser user].profilePictureURL]
                                                      options:SDWebImageRefreshCached
                                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                     }
                                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                        if (image) {
                                                            completionBlock(image, nil);
                                                        }
                                                    }];
    } else {
        completionBlock(nil, nil);
    }
}

+ (void)saveUserDataToUserDefaults:(CLUser *)user {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:kUserDefaultsUserDataKey];
    [userDefaults synchronize];

    NSLog(@"saving %.2f kb of user data to user defaults", (float) (data.length / 1024.0f));
}

+ (CLUser *)loadUserFromUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:kUserDefaultsUserDataKey];

    // Check if we have valid data
    if (!data) {
        return nil;
    }

    // Unarchive the data
    CLUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    NSLog(@"loading %.2f kb of data from user defaults", (float) (data.length / 1024.0f));

    return user;
}

- (void)setZeroStepsForStartDate:(NSDate *)startDate toDate:(NSDate *)toDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSMutableArray *dateList = [NSMutableArray array];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [dateList addObject:startDate];
    NSDate *currentDate = startDate;
    currentDate = [currentCalendar dateByAddingComponents:comps toDate:currentDate options:0];

    while ([toDate compare:currentDate] != NSOrderedAscending) {
        [dateList addObject:currentDate];

        currentDate = [currentCalendar dateByAddingComponents:comps toDate:currentDate options:0];
    }

    for (NSDate *date in dateList) {
        NSString *dateString = [dateFormatter stringFromDate:date];
        [[CLUser user].stepsForDay setValue:@(0)
                                     forKey:dateString];
    }
}

- (void)checkRulesForCurrentMiniGame {
    [[CLUser user].currentMiniGame.setOfRules enumerateObjectsUsingBlock:^(CLMiniGameRule *rule, BOOL *stop) {
        [rule evaluateForCurrentUser];
    }];
}

- (void)clearUserInfo {
    self.accessToken = nil;
    self.device = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.facebookID = nil;
    self.linkedInID = nil;
    self.age = nil;
    self.birthdate = nil;
    self.email = nil;
    self.gender = nil;
    self.heightFeet = nil;
    self.heightInches = nil;
    self.weight = nil;
    self.password = nil;
    self.phoneNumber = nil;
    self.profilePicture = nil;
    self.profilePictureURL = nil;
    self.lastSyncDate = nil;
    self.isHourlyRulePassed = YES;
    self.isMaxStepsRulePassed = YES;
    self.isDailyRulePassed = YES;
    self.isDisqualified = NO;
    self.stepsForDay = nil;
    self.stepsForCurrentDay = nil;
    self.stepsForDayWithoutLimit = nil;
    self.userId = nil;
}

- (void)logOut {
    [[CLFacebookHandler sharedInstance] logout];
    [[CLUser user] clearUserInfo];
    [CLUser saveUserDataToUserDefaults:[CLUser user]];
}

@end
