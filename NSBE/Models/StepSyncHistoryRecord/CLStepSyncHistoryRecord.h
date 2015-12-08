//
//  CLStepSyncHistoryRecord.h
//  NSBE
//

@import Foundation;

@interface CLStepSyncHistoryRecord : NSObject <NSCoding>
@property (strong, nonatomic) NSNumber *steps;
@property (strong, nonatomic) NSDate *date;
@end
