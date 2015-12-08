//
//  CLHistoryManager.m
//  NSBE
//

#import "CLHistoryManager.h"
#import "CLStepSyncHistoryRecord.h"
#import "Utils.h"
#import "CLUser.h"
#import "CLSteps.h"

#define kUserDefaultsStepSyncHistoryKey   @"kUserDefaultsStepSyncHistoryKey"
#define kUserDefaultsTotalStepsTodayKey   @"kUserDefaultsTotalStepsTodayKey"


@interface CLHistoryManager ()
@property (strong, nonatomic) NSMutableArray *stepsSyncronizationHistory;
@property (nonatomic, assign, readwrite) double maxStepsCountForObservingPeriod;
@property (nonatomic, assign, readwrite) double oldTotalStepsSyncedForLastHour;
@end

@implementation CLHistoryManager

#pragma mark Singleton Methods

+ (id)sharedManager {
    static CLHistoryManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        self.maxStepsCountForObservingPeriod = 0;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Public methods

- (void)addStepSyncRecord:(CLStepSyncHistoryRecord *)stepSyncHistoryRecord {
    
    self.maxStepsCountForObservingPeriod = 0;

    NSInteger collectingSyncHistoryMinutesCount = self.numberOfHoursForObserve.integerValue * 60;

    NSArray *stepsSyncCachedHistory = [CLHistoryManager loadCacheFromUserDefaults];
    self.stepsSyncronizationHistory = stepsSyncCachedHistory ? [stepsSyncCachedHistory mutableCopy] : [[NSMutableArray alloc] init];

    NSInteger hoursIntervalStored = 0;

    if (!stepsSyncCachedHistory.count)
    {
        self.maxStepsCountForObservingPeriod = stepSyncHistoryRecord.steps.integerValue;
        
        [self.stepsSyncronizationHistory addObject:stepSyncHistoryRecord];
        [CLHistoryManager saveCacheDataToUserDefaults:self.stepsSyncronizationHistory];
    }
    else
    {
        CLStepSyncHistoryRecord *lastHistoryRecord = [self.stepsSyncronizationHistory lastObject];
        hoursIntervalStored = [Utils minutesBetweenDate:lastHistoryRecord.date
                                                andDate:[NSDate date]];
        
        __block NSInteger newStepsCount = stepSyncHistoryRecord.steps.integerValue;
        [self.stepsSyncronizationHistory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                newStepsCount -= ((CLStepSyncHistoryRecord*)obj).steps.integerValue;
        }];
        
        CLStepSyncHistoryRecord *newHistoryRecord = [CLStepSyncHistoryRecord new];
        newHistoryRecord.steps = @(newStepsCount);
        newHistoryRecord.date = [NSDate date];
        [self.stepsSyncronizationHistory addObject:newHistoryRecord];

        BOOL moreThenCollectionTime = hoursIntervalStored >= collectingSyncHistoryMinutesCount / 60;

        if (moreThenCollectionTime)
        {
            self.maxStepsCountForObservingPeriod = newStepsCount;
        }
        else
        {
            NSDate *hourlEarlier = [NSDate dateWithTimeIntervalSinceNow:(-collectingSyncHistoryMinutesCount * 60)];
            NSArray *lastHourRecords = [self.stepsSyncronizationHistory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"date >= %@", hourlEarlier]];
            for (CLStepSyncHistoryRecord *record in lastHourRecords) {
                self.maxStepsCountForObservingPeriod += record.steps.integerValue;
            }
        }
        
        [CLHistoryManager saveCacheDataToUserDefaults:self.stepsSyncronizationHistory];
    }
}

- (void)checkStepsArray:(NSArray *)stepsArray
{
    double stepsCountForSelectedPeriod = 0;
    
    for (NSNumber *steps in stepsArray)
    {
        stepsCountForSelectedPeriod += steps.doubleValue;
    }
    
    if (self.maxStepsCountForObservingPeriod < stepsCountForSelectedPeriod)
    {
        self.maxStepsCountForObservingPeriod = stepsCountForSelectedPeriod;
    }
}

- (void)clearAllHistory {
    [CLHistoryManager saveCacheDataToUserDefaults:@[]];
    [CLHistoryManager saveToUserDefaultsTotalSteps:0];
}
- (void)needsToZeroStepsCount
{
    self.maxStepsCountForObservingPeriod = 0;
}

#pragma mark - NSUserDefaults methods

+ (NSArray *)loadCacheFromUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [kUserDefaultsStepSyncHistoryKey stringByAppendingString:[CLUser user].accessToken];
    NSData *data = [userDefaults objectForKey:key];
    NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return arr;
}

+ (void)saveCacheDataToUserDefaults:(NSArray *)history {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:history];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [kUserDefaultsStepSyncHistoryKey stringByAppendingString:[CLUser user].accessToken];
    [userDefaults setObject:data forKey:key];
    [userDefaults synchronize];
}

+ (double)loadTotalStepsFromUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [kUserDefaultsTotalStepsTodayKey stringByAppendingString:[CLUser user].accessToken];
    double steps = [[userDefaults objectForKey:key] doubleValue];
    return steps;
}

+ (void)saveToUserDefaultsTotalSteps:(double)totalSteps {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [kUserDefaultsTotalStepsTodayKey stringByAppendingString:[CLUser user].accessToken];
    [userDefaults setDouble:totalSteps forKey:key];
}

@end
