//
//  CLMiniGame.h
//  NSBE

#import <Foundation/Foundation.h>

@interface CLMiniGame : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *minigameId;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic) int durationDays;
@property (nonatomic, strong) NSSet *setOfRules;
@end
