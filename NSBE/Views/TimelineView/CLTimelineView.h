//
//  CLTimelineView.h
//  NSBE
//

#import <UIKit/UIKit.h>

@interface CLTimelineView : UIView

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) int durationDays;
@property (nonatomic, assign) BOOL showCurrentDateOnly;

@end
