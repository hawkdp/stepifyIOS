//
//  CLFacebookHandler.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/30/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLFacebookHandler.h"
#import "CLUser.h"

@implementation CLFacebookHandler

#pragma mark - Facebook handler singleton

+ (CLFacebookHandler *)sharedInstance {
    static CLFacebookHandler *sharedInstance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        // Create a shared instace of Facebook handler
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark - Facebook handling methods

- (void)login:(CLFacebookHandlerLoginSuccessBlock)successBlock failure:(CLFacebookHandlerLoginFailureBlock)failureBlock {
    if (FBSession.activeSession.state != FBSessionStateOpen && FBSession.activeSession.state != FBSessionStateOpenTokenExtended) {

        // Assign login success and failure block
        self.loginSuccessBlock = successBlock;
        self.loginFailureBlock = failureBlock;

        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:kCLFacebookDefaultPermissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          NSString *fbAccessToken = [FBSession activeSession].accessTokenData.accessToken;
                                          [CLUser user].accessToken = fbAccessToken;
                                          // Call the  facebookSessionStateChanged:state:error method to handle session state changes
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    } else {
        NSString *fbAccessToken = [FBSession activeSession].accessTokenData.accessToken;
        [CLUser user].accessToken = fbAccessToken;
        // Already logged in, call success block if available
        if (successBlock) {
            successBlock();
        }
    }
}

- (void)logout {
    if (FBSession.activeSession.state == FBSessionStateOpen ||
            FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {

        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void)getUserInfo:(CLFacebookHandlerRequestSuccessBlock)successBlock
            failure:(CLFacebookHandlerRequestFailureBlock)failureBlock {
    [FBRequestConnection startWithGraphPath:@"/me"
                                 parameters:kCLFacebookDefaultUserInfo
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              NSString *fbAccessToken = [FBSession activeSession].accessTokenData.accessToken;
                              [CLUser user].accessToken = fbAccessToken;
                              // Check for errors
                              if (!error) {

                                  // No errors have occured, call success block if available
                                  if (successBlock) {
                                      successBlock(result);
                                  }
                              } else {

                                  // An error has occured, call failure block if available
                                  if (failureBlock) {
                                      failureBlock(result, error);
                                  }
                              }
                          }];
}

- (void)getUserPicture:(CGSize)pictureSize
               success:(CLFacebookHandlerRequestSuccessBlock)successBlock
               failure:(CLFacebookHandlerRequestFailureBlock)failureBlock {

}

// This method will handle ALL the facebook session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen) {
        NSLog(@"facebook session opened");

        // Call success block if available
        if (self.loginSuccessBlock) {
            self.loginSuccessBlock();
            self.loginSuccessBlock = nil;
        }
    }

    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
        NSLog(@"facebook session closed");

        if (self.loginFailureBlock) {
            self.loginFailureBlock([NSError errorWithDomain:@"FBSessionErrorDomain"
                                                       code:FBSessionStateClosedLoginFailed
                                                   userInfo:@{NSLocalizedDescriptionKey : @"Facebook session closed"}]);
            self.loginFailureBlock = nil;
        }
    }

    // Handle errors
    if (error) {
        NSLog(@"Error");

        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {

            NSLog(@"something went wrong while establishing a facebook session: %@",
                    [FBErrorUtility userMessageForError:error]);

        } else {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"user cancelled facebook login");

                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {

                NSLog(@"facebook session error: Your current session is no longer valid. Please log in again");

                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/

            } else {
                // Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
                        objectForKey:@"body"] objectForKey:@"error"];

                // Show an error message
                NSLog(@"something went wrong while establishing a facebook session: Please retry. If the problem persists "
                        "contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]);
            }
        }

        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];

        // Call failure block if available
        if (self.loginFailureBlock) {
            self.loginFailureBlock(error);
            self.loginSuccessBlock = nil;
        }
    }
}

@end
