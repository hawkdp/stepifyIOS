//
//  CLFitbitOAuthHandler.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/20/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLUser+API.h"
#import "DTOAuthClient.h"
#import "DTOAuthWebViewController.h"

#pragma mark - Type defines and enums

typedef void (^CLFitbitOAuthHandlerSuccessBlock)(DTOAuthClient *OAuthClient, NSString *token, NSString *verifier);
typedef void (^CLFitbitOAuthHandlerFailureBlock)(DTOAuthClient *OAuthClient, NSError *error);

#pragma mark - Fitbit OAuth handler errors

#define FITBIT_OAUTH_HANDLER_DOMAIN_ERROR @"CLFitbitOAuthHandlerErrorDomain"

typedef NS_ENUM(NSInteger, CLFitbitOAuthHandlerErrors) {
	kCLFitbitOAuthHandlerErrorAuthorizationDenied		= 1,
	kCLFitbitOAuthHandlerErrorAccessTokenNotProvided	= 2,
	kCLFitbitOAuthHandlerErrorTokensDoNotCorrespond		= 3,
	kCLFitbitOAuthHandlerErrorUnknown					= 99
};

@interface CLFitbitOAuthHandler : NSObject <OAuthResultDelegate>

#pragma mark - Fitbit OAuth handler properties

@property (nonatomic, assign, readonly) BOOL authorizationStarted;

#pragma mark - Initialize methods

- (instancetype)initWithOAuthClient:(DTOAuthClient *)OAuthClient
					   successBlock:(CLFitbitOAuthHandlerSuccessBlock)successBlock
					   failureBlock:(CLFitbitOAuthHandlerFailureBlock)failureBlock;

#pragma mark - Fitbit OAuth handler class methods

+ (CLFitbitOAuthHandler *)authorizeUserWithClient:(DTOAuthClient *)OAuthClient
									 successBlock:(CLFitbitOAuthHandlerSuccessBlock)successBlock
									 failureBlock:(CLFitbitOAuthHandlerFailureBlock)failureBlock;

#pragma mark - Fitbit OAuth handler intance methods

- (void)authorize;

@end
