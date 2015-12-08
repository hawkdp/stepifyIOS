//
//  CLFacebookHandler.h
//  NSBE
//
//  Created by Iulian Corcoja on 1/30/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

#pragma mark - Constant defines

#define kCLFacebookDefaultPermissions @[@"email", @"public_profile"]
#define kCLFacebookDefaultUserInfo @{@"fields" : @"id, first_name, last_name, gender, email"}

#define kCLFacebookParameterID @"id"
#define kCLFacebookParameterFirstName @"first_name"
#define kCLFacebookParameterLastName @"last_name"
#define kCLFacebookParameterEmail @"email"
#define kCLFacebookParameterGender @"gender"
#define kCLFacebookParameterBirthday @"birthday"
#define kCLFacebookParameterPicture @"picture"

#pragma mark - Type defines

typedef void (^CLFacebookHandlerLoginSuccessBlock)();
typedef void (^CLFacebookHandlerLoginFailureBlock)(NSError *error);
typedef void (^CLFacebookHandlerRequestSuccessBlock)(id data);
typedef void (^CLFacebookHandlerRequestFailureBlock)(id data, NSError *error);


@interface CLFacebookHandler : NSObject

#pragma mark - Facebook handler properties

@property (atomic, copy) CLFacebookHandlerLoginSuccessBlock loginSuccessBlock;

@property (atomic, copy) CLFacebookHandlerLoginFailureBlock loginFailureBlock;

#pragma mark - Facebook handler singleton

+ (CLFacebookHandler *)sharedInstance;

#pragma mark - Facebook handling methods

- (void)login:(CLFacebookHandlerLoginSuccessBlock)successBlock failure:(CLFacebookHandlerLoginFailureBlock)failureBlock;

- (void)logout;

- (void)getUserInfo:(CLFacebookHandlerRequestSuccessBlock)successBlock failure:(CLFacebookHandlerRequestFailureBlock)failureBlock;

- (void)getUserPicture:(CGSize)pictureSize success:(CLFacebookHandlerRequestSuccessBlock)successBlock failure:(CLFacebookHandlerRequestFailureBlock)failureBlock;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end
