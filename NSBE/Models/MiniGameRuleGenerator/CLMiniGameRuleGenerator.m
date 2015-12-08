//
//  CLMiniGameRuleGenerator.m
//  NSBE
//


#import "CLMiniGameRuleGenerator.h"
#import "CLMiniGameDailyRule.h"
#import "CLMiniGameHourlyRule.h"
#import "CLMiniGameMaxStepsRule.h"

@implementation CLMiniGameRuleGenerator
- (CLMiniGameRule *)generateMiniGameRuleWithParameters:(NSDictionary *)parameters {
    CLMiniGameRuleType value;
    [parameters[MINIGAME_RULE_TYPE_JSON_PARAMETER] getValue:&value];
    CLMiniGameRuleType miniGameRuleType = value;
    switch (miniGameRuleType) {
        case CLMiniGameRuleTypeHourly: {
            CLMiniGameHourlyRule *hourlyRule = [[CLMiniGameHourlyRule alloc] initWithParameters:parameters];
            return hourlyRule;
        }
        case CLMiniGameRuleTypeDaily: {
            CLMiniGameDailyRule *dailyRule = [[CLMiniGameDailyRule alloc] initWithParameters:parameters];
            return dailyRule;
        }
        case CLMiniGameRuleTypeMaxSteps: {
            CLMiniGameMaxStepsRule *maxStepsRule = [[CLMiniGameMaxStepsRule alloc] initWithParameters:parameters];
            return maxStepsRule;
        }
        default: {
            return nil;
        }
    }
}
@end
