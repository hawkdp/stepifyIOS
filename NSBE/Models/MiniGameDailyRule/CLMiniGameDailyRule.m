//
//  CLMiniGameDailyRule.m
//  NSBE
//


#import "CLMiniGameDailyRule.h"
#import "CLUser.h"

@implementation CLMiniGameDailyRule
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithParameters:(NSDictionary *)parameters {
    if (self = [super initWithParameters:parameters]) {
        self.obseverableDaysCount = [[parameters valueForKey:MINIGAME_RULE_OBSERVABLE_DAYS_JSON_PARAMETER] integerValue];
    }
    return self;
}

- (void)evaluateForCurrentUser {
    double lowerStepsCountValue = self.stepsCountLimit * self.lowerRatio / 100;
    NSArray *stepResults = [[CLUser user].stepsForDay allValues];
    
    __block NSUInteger numberOfCheatingDays = 0;
    [stepResults enumerateObjectsUsingBlock:^(NSNumber *stepsValue, NSUInteger idx, BOOL *stop) {
        if (stepsValue.doubleValue >= lowerStepsCountValue)
        {
            numberOfCheatingDays++;
        }
    }];
    [CLUser user].isDailyRulePassed = numberOfCheatingDays < self.obseverableDaysCount;
}
@end
