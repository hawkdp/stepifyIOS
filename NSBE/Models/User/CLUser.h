//
//  CLUser.h
//  NSBE
//
//  Created by Iulian Corcoja on 1/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#define kUserDefaultsUserDataKey @"userDefaultsUserData"

@import Foundation;
@class CLMiniGame;

typedef void (^CLUserPhotoCompletion)(UIImage *profilePhoto, NSError *error);

typedef NS_ENUM(NSInteger, CLUserDevice) {
	kCLUserDeviceNoDevice	= 0,
	kCLUserDeviceFitbit		= 1,
	kCLUserDeviceJawbone	= 2,
	kCLUserDeviceHealthKit	= 3
};

@interface CLUser : NSObject <NSCoding>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *pushToken;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSDate *birthdate;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSNumber *heightFeet;
@property (nonatomic, strong) NSNumber *heightInches;
@property (nonatomic, strong) NSString *weight;
@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSString *linkedInID;
@property (nonatomic, strong) NSString *profilePictureURL;
@property (nonatomic, strong) UIImage *profilePicture;
@property (nonatomic, strong) NSMutableDictionary *stepsForDay;
@property (nonatomic, strong) NSMutableDictionary *stepsForDayWithoutLimit;
@property (nonatomic, strong) NSString *challengeName;
@property (nonatomic, strong) NSString *challengeId;
@property (nonatomic, strong) NSMutableArray *challengeMiniGames;
@property (nonatomic, strong) NSDate *challengeStartDate;
@property (nonatomic, strong) NSNumber *challengeDurationMonths;
@property (nonatomic, assign) NSInteger challengeDurationWeeks;
@property (nonatomic, strong) CLMiniGame *currentMiniGame;
@property (nonatomic, assign) CLUserDevice device;
@property (nonatomic, assign) BOOL isHourlyRulePassed;
@property (nonatomic, assign) BOOL isMaxStepsRulePassed;
@property (nonatomic, assign) BOOL isDailyRulePassed;
@property (nonatomic, assign) BOOL isDisqualified;
@property (nonatomic, strong) NSDictionary *stepsForCurrentDay;
@property (nonatomic, strong) NSDictionary *stepsForCurrentDayWithoutLimit;
@property (nonatomic, strong) NSNumber *maxSteps;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSDate *lastSyncDate;

+ (CLUser *)user;

+ (UIImage *)getDeviceIconImage:(CLUserDevice)device;
+ (UIImage *)getDeviceImage:(CLUserDevice)device;
- (void)updateStepsDataWithDictionary:(NSDictionary *)stepsDictionary;
- (void)updateStepsForDayWithoutLimit:(NSDictionary *)stepsDictionary;
+ (void)saveUserDataToUserDefaults:(CLUser *)user;
+ (CLUser *)loadUserFromUserDefaults;
- (void)setZeroStepsForStartDate:(NSDate *)startDate toDate:(NSDate *)toDate;
- (void)fetchProfilePictureWithCompletionBlock:(CLUserPhotoCompletion)completionBlock;
- (void)checkRulesForCurrentMiniGame;
- (void)clearUserInfo;
- (void)logOut;

@end
