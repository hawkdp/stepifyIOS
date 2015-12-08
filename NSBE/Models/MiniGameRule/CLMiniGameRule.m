//
//  CLMiniGameRule.m
//  NSBE
//


#import "CLMiniGameRule.h"

@implementation CLMiniGameRule
- (instancetype)init {
    if ([self class] == [CLMiniGameRule class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                     userInfo:nil];

        return nil;
    } else {
        return (CLMiniGameRule *) [super init];
    }
}

- (instancetype)initWithParameters:(NSDictionary *)parameters {
    if (self = [super init]) {
        CLMiniGameRuleType value;
        [parameters[MINIGAME_RULE_TYPE_JSON_PARAMETER] getValue:&value];
        self.ruleType = value;
        self.stepsCountLimit = [[parameters valueForKey:MINIGAME_RULE_STEPS_LIMIT_JSON_PARAMETER] integerValue];
        self.lowerRatio = [[parameters valueForKey:MINIGAME_RULE_LOWER_RATIO_JSON_PARAMETER] integerValue];
        self.upperRatio = [[parameters valueForKey:MINIGAME_RULE_UPPER_RATIO_JSON_PARAMETER] integerValue];
    }
    return self;
}

- (void)evaluateForCurrentUser {
}
@end
