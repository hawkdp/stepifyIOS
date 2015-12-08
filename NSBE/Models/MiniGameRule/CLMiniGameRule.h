//
//  CLMiniGameRule.h
//  NSBE
//


#define MINIGAME_RULE_TYPE_JSON_PARAMETER @"rules_type"
#define MINIGAME_RULE_STEPS_LIMIT_JSON_PARAMETER @"rules_steps"
#define MINIGAME_RULE_LOWER_RATIO_JSON_PARAMETER @"rule_from"
#define MINIGAME_RULE_UPPER_RATIO_JSON_PARAMETER @"rule_to"
#define MINIGAME_RULE_OBSERVABLE_DAYS_JSON_PARAMETER @"rule_days"

@import Foundation;

typedef NS_ENUM(NSInteger, CLMiniGameRuleType) {
    CLMiniGameRuleTypeDaily = 1,
    CLMiniGameRuleTypeHourly = 2,
    CLMiniGameRuleTypeMaxSteps = 3
};

//this is @abstract class
@interface CLMiniGameRule : NSObject
@property (nonatomic, assign) CLMiniGameRuleType ruleType;
@property (nonatomic, assign) NSInteger stepsCountLimit;
@property (nonatomic, assign) NSInteger lowerRatio;
@property (nonatomic, assign) NSInteger upperRatio;

- (instancetype)init;
- (instancetype)initWithParameters:(NSDictionary *)parameters;

- (void)evaluateForCurrentUser;
@end
