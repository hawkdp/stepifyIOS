//
//  CLHistoryManager.h
//  NSBE
//

#import <Foundation/Foundation.h>

@class CLStepSyncHistoryRecord;

@interface CLHistoryManager : NSObject

@property (nonatomic, assign, readonly) double maxStepsCountForObservingPeriod;

@property (nonatomic, strong) NSNumber *numberOfHoursForObserve;

+ (id)sharedManager;

- (void)addStepSyncRecord:(CLStepSyncHistoryRecord *)stepSyncHistoryRecord;

- (void)checkStepsArray:(NSArray *)stepsArray;

- (void)needsToZeroStepsCount;

@end
