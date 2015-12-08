//
//  CLLinkedinHelper.h
//  NSBE
//

typedef void (^LinkedInHelperResponseBlock)(id data, NSError *error);

@import Foundation;

@interface CLLinkedinHelper : NSObject

+ (instancetype)sharedHelper;

- (void)loginWithCompletionBlock:(LinkedInHelperResponseBlock)block;

@end
