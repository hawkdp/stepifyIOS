//
//  CLLinkedinHelper.m
//  NSBE
//

#define LINKEDIN_CLIENT_ID @"77ue1c5j0xyf64"
#define LINKEDIN_CLIENT_SECRET @"LnBfV9f7XRADuGNW"

#import "CLLinkedinHelper.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"
#import "CLUser.h"

@interface CLLinkedinHelper ()
@property(nonatomic, strong) LIALinkedInHttpClient *linkedInHttpClient;
@end

@implementation CLLinkedinHelper

- (LIALinkedInHttpClient *)linkedInHttpClient {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com/liaexample"
                                                                                    clientId:LINKEDIN_CLIENT_ID
                                                                                clientSecret:LINKEDIN_CLIENT_SECRET
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[]];
    return [LIALinkedInHttpClient clientForApplication:application
                              presentingViewController:nil];
}

+ (instancetype)sharedHelper {
    static CLLinkedinHelper *sharedLinkedInHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLinkedInHelper = [[self alloc] init];
    });
    return sharedLinkedInHelper;

}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)loginWithCompletionBlock:(LinkedInHelperResponseBlock)block {
    [self.linkedInHttpClient getAuthorizationCode:^(NSString *code) {
                [self.linkedInHttpClient getAccessToken:code
                                                success:^(NSDictionary *accessTokenData) {
                                                    NSString *accessToken = accessTokenData[@"access_token"];
                                                    [CLUser user].accessToken = accessToken;
                                                    [self.linkedInHttpClient GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken]
                                                                      parameters:nil
                                                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
                                                                             NSLog(@"current user %@", result);
                                                                             block(result, nil);
                                                                         }
                                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                             NSLog(@"failed to fetch current user %@", error);
                                                                             block(nil, error);
                                                                         }];
                                                }
                                                failure:^(NSError *error) {
                                                    NSLog(@"Quering accessToken failed %@", error);
                                                    block(nil, error);
                                                }];
            }
                                           cancel:^{
                                               NSLog(@"Authorization was cancelled by user");
                                               block(nil, nil);
                                           }
                                          failure:^(NSError *error) {
                                              NSLog(@"Authorization failed %@", error);
                                              block(nil, error);
                                          }];
}


@end
