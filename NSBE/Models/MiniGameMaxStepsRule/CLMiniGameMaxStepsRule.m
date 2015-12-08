//
//  CLMiniGameMaxStepsRule.m
//  NSBE
//

#import "CLMiniGameMaxStepsRule.h"
#import "CLUser.h"
#import "CLHistoryManager.h"
#import "Utils.h"

@implementation CLMiniGameMaxStepsRule
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithParameters:(NSDictionary *)parameters {
    CLMiniGameRuleType value;
    [parameters[MINIGAME_RULE_TYPE_JSON_PARAMETER] getValue:&value];
    self.ruleType = value;
    self.stepsCountLimit = [[parameters valueForKey:MINIGAME_RULE_STEPS_LIMIT_JSON_PARAMETER] integerValue];
//    [CLUser user].maxSteps = @(self.stepsCountLimit);
    return self;
}

- (void)evaluateForCurrentUser {
}
@end
