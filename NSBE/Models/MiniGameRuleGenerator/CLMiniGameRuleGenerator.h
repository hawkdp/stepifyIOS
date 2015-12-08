//
//  CLMiniGameRuleGenerator.h
//  NSBE
//


@import Foundation;

@class CLMiniGameRule;

@interface CLMiniGameRuleGenerator : NSObject

- (CLMiniGameRule *)generateMiniGameRuleWithParameters:(NSDictionary *)parameters;

@end
