//
//  CLSteps.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/10/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <UPPlatform/UP.h>

#pragma mark - Type defines and enums

#define kUserDefaultsFitbitTokenKey @"userDefaultsFitbitTokenKey"
#define kUserDefaultsFitbitTokenSecretKey @"userDefaultsFitbitTokenSecretKey"

typedef void (^CLStepsSuccessBlock)(NSArray *steps);
typedef void (^CLStepsFailureBlock)(id data, NSError *error);

typedef NS_ENUM(NSInteger, CLStepsFramework) {
	kCLStepsFrameworkNone							= 0,
	kCLStepsFrameworkFitbit							= 1,
	kCLStepsFrameworkJawbone						= 2,
	kCLStepsFrameworkHealthKit						= 3
};

#pragma mark - Steps retrieval errors

#define STEPS_RETRIEVAL_DOMAIN_ERROR @"CLStepsRetrievalErrorDomain"

typedef NS_ENUM(NSInteger, CLStepsRetrievalErrors) {
	kCLStepsRetrievalErrorDateNotProvided			= 1,
	kCLStepsRetrievalErrorFrameworkNotProvided		= 2,
	kCLStepsRetrievalErrorHealthDataNotAvailable	= 3,
	kCLStepsRetrievalErrorUnknownStatusCode			= 4,
	kCLStepsRetrievalErrorIncorrectDataType			= 5,
	kCLStepsRetrievalErrorUnknown					= 99
};

@interface CLSteps : NSObject

+ (void)getStepsFromDate:(NSDate *)startDate
				  toDate:(NSDate *)endDate
					from:(CLStepsFramework)framework
			successBlock:(CLStepsSuccessBlock)successBlock
			failureBlock:(CLStepsFailureBlock)failureBlock;

@end
