//
//  CLMiniGameHourlyRule.m
//  NSBE
//


#import "CLMiniGameHourlyRule.h"
#import "CLUser.h"
#import "CLHistoryManager.h"

@implementation CLMiniGameHourlyRule
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithParameters:(NSDictionary *)parameters {
    if (self = [super initWithParameters:parameters]) {
        [[CLHistoryManager sharedManager] setNumberOfHoursForObserve:@([parameters[@"rule_time"] integerValue] / 60)];
    }
    return self;
}

- (void)evaluateForCurrentUser {
    double lowerStepsCountValue = (self.stepsCountLimit * self.lowerRatio) / 100;
    double steps = [[CLHistoryManager sharedManager] maxStepsCountForObservingPeriod];

    [CLUser user].isHourlyRulePassed = steps < lowerStepsCountValue;
}
@end
