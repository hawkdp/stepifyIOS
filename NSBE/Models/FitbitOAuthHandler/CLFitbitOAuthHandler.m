//
//  CLFitbitOAuthHandler.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/20/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLFitbitOAuthHandler.h"
#import "CLActivityIndicator.h"

@interface CLFitbitOAuthHandler ()

@property (nonatomic, strong) DTOAuthClient *OAuthClient;
@property (nonatomic, copy) CLFitbitOAuthHandlerSuccessBlock successBlock;
@property (nonatomic, copy) CLFitbitOAuthHandlerFailureBlock failureBlock;
@property (nonatomic, assign) BOOL authorizationStarted;

@end

@implementation CLFitbitOAuthHandler

#pragma mark - Initialize methods

- (instancetype)initWithOAuthClient:(DTOAuthClient *)OAuthClient
					   successBlock:(CLFitbitOAuthHandlerSuccessBlock)successBlock
					   failureBlock:(CLFitbitOAuthHandlerFailureBlock)failureBlock
{
	self = [super init];
	if (self) {
		
		// Set Fitbit OAuth handler properties
		self.OAuthClient = OAuthClient;
		self.successBlock = successBlock;
		self.failureBlock = failureBlock;
		self.authorizationStarted = NO;
	}
	return self;
}

#pragma mark - Fitbit OAuth handler class methods

+ (CLFitbitOAuthHandler *)authorizeUserWithClient:(DTOAuthClient *)OAuthClient
									 successBlock:(CLFitbitOAuthHandlerSuccessBlock)successBlock
									 failureBlock:(CLFitbitOAuthHandlerFailureBlock)failureBlock
{
	// Create an instance of Fitbit OAuth handler and start authorization process
	CLFitbitOAuthHandler *fitbitOAuthHandler = [[CLFitbitOAuthHandler alloc] initWithOAuthClient:OAuthClient
																					successBlock:successBlock
																					failureBlock:failureBlock];
	[fitbitOAuthHandler authorize];
	return fitbitOAuthHandler;
}

#pragma mark - Fitbit OAuth handler intance methods

- (void)authorize
{
	if (self.authorizationStarted) {
		// Prevent doing it again returning from web view
		return;
	}
	
	// Step 1 - Request access token
	[self.OAuthClient requestTokenWithCompletion:^(NSError *error) {
		
		// Check for errors
		if (error) {
			
			// Call failure block if available
			if (self.failureBlock) {
				self.failureBlock(self.OAuthClient, error);
			}
			return;
		}
		
		// Step 2 - Authorize the user
		// Get main queue for showing authorization web view controller
		dispatch_async(dispatch_get_main_queue(), ^{
			
			// Check if we have an access token
			if (self.OAuthClient.token) {
				
				// Create URL request
				NSURLRequest *request = [self.OAuthClient userTokenAuthorizationRequest:
										 @[USER_FITBIT_AUTHORIZE_PHONE_SCREEN_PARAMETER]];
				
				// Create authorization web view controller inside a navigation controller
				DTOAuthWebViewController *authWebViewController = [[DTOAuthWebViewController alloc] init];
				UINavigationController *navigationController = [[UINavigationController alloc]
																initWithRootViewController:authWebViewController];
				authWebViewController.authorizationDelegate = self;
				
				// Start authorization flow
				UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
				[authWebViewController startAuthorizationFlowWithRequest:request completion:nil];
				[window.rootViewController presentViewController:navigationController animated:YES completion:nil];
				
				// Set authorization started to YES
				self.authorizationStarted = YES;
				
			} else {
				
				// No access token, call failure block if available
				if (self.failureBlock) {
					self.failureBlock(self.OAuthClient,
									  [NSError errorWithDomain:FITBIT_OAUTH_HANDLER_DOMAIN_ERROR
														  code:kCLFitbitOAuthHandlerErrorAccessTokenNotProvided
													  userInfo:@{NSLocalizedDescriptionKey :
																	 NSLocalizedString(@"OAuthAccessTokenNotProvided", nil)}]);
				}
			}
		});
	}];
}

#pragma mark - Required OAuth result delagate methods

- (void)authorizationWasGranted:(DTOAuthWebViewController *)webViewController
					   forToken:(NSString *)token
				   withVerifier:(NSString *)verifier
{
	// Dismiss authorization web view controller and set authorization started to NO
	[webViewController dismissViewControllerAnimated:YES completion:nil];
	self.authorizationStarted = NO;
	
	// Check if the token is the same as OAuth token
	if ([token isEqualToString:self.OAuthClient.token]) {
		
		// Step 3 - Request token and token secret
		[self.OAuthClient authorizeTokenWithVerifier:verifier completion:^(NSError *error) {
			
			// Check for errors
			if (error) {
				
				// Call failure block if available
				if (self.failureBlock) {
					self.failureBlock(self.OAuthClient, error);
				}
				return;
			}
			
			// Get main queue and call success block if available
			dispatch_async(dispatch_get_main_queue(), ^{
				if (self.successBlock) {
					self.successBlock(self.OAuthClient, token, verifier);
				}
			});
		}];
	} else {
		
		NSLog(@"Received token \"%@\" does not correpond to access token \"%@\"", token, self.OAuthClient.token);
		
		// Received token does not correpond to access token, call failure block if available
		if (self.failureBlock) {
			self.failureBlock(self.OAuthClient,
							  [NSError errorWithDomain:FITBIT_OAUTH_HANDLER_DOMAIN_ERROR
												  code:kCLFitbitOAuthHandlerErrorTokensDoNotCorrespond
											  userInfo:@{NSLocalizedDescriptionKey :
															 NSLocalizedString(@"TokensDoNotCorrespond", nil)}]);
		}
	}
}

- (void)authorizationWasDenied:(DTOAuthWebViewController *)webViewController
{
	// Dismiss authorization web view controller and set authorization started to NO
	[webViewController dismissViewControllerAnimated:YES completion:nil];
	self.authorizationStarted = NO;
	
	// Authorization denied, call failure block if available
	if (self.failureBlock) {
		self.failureBlock(self.OAuthClient,
						  [NSError errorWithDomain:FITBIT_OAUTH_HANDLER_DOMAIN_ERROR
											  code:kCLFitbitOAuthHandlerErrorAuthorizationDenied
										  userInfo:@{NSLocalizedDescriptionKey :
														 NSLocalizedString(@"AuthorizationDenied", nil)}]);
	}
}

#pragma mark - Optional OAuth result delagate methods

- (void)authWebViewControllerDidStartLoad:(DTOAuthWebViewController *)webViewController
{
	[CLActivityIndicator showInView:webViewController.view animated:YES];
}

- (void)authWebViewControllerDidFinishLoad:(DTOAuthWebViewController *)webViewController
{
	[CLActivityIndicator hideForView:webViewController.view animated:YES];
}

@end
