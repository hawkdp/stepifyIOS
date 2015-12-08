//
//  CLTimelineView.m
//  NSBE
//

#import "CLTimelineView.h"

@interface CLTimelineView ()

@property (nonatomic, assign) int currentDay;
@property (nonatomic, strong) UIImageView *currentDot;
@property (nonatomic, strong) UIImageView *firstDot;
@property (nonatomic, strong) UIImageView *lastDot;

@end

@implementation CLTimelineView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _durationDays = 1;
        _startDate = [NSDate date];
        _showCurrentDateOnly = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //remove old dot images
    
    if (self.currentDot)
    {
        [self.currentDot removeFromSuperview];
    }
    if (self.firstDot)
    {
        [self.firstDot removeFromSuperview];
    }
    if (self.lastDot)
    {
        [self.lastDot removeFromSuperview];
    }
    
    
    //Show labels with dates
    
    UIColor *baseColor = [UIColor colorWithRed:186.0/255.0 green:191.0/255.0 blue:16.0/255.0 alpha:1.0];
    UIFont *baseFontBold = [UIFont fontWithName:@"Geomanist-Bold" size:8.0];
    UIFont *baseFontRegular = [UIFont fontWithName:@"Geomanist" size:8.0];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay fromDate:self.startDate toDate:[NSDate date] options:0];
    self.currentDay = (int)dateComponents.day + 1;
    
    dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = self.durationDays - 1;
    NSDate *endDate = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d"];
    
    NSString *firstString = [[dateFormatter stringFromDate:self.startDate] uppercaseString];
    NSString *lastString = [[dateFormatter stringFromDate:endDate] uppercaseString];
    NSString *currentString = [NSString stringWithFormat:@"%@, ", [[dateFormatter stringFromDate:[NSDate date]] uppercaseString]];
    
    NSAttributedString *firstDate = [[NSAttributedString alloc] initWithString:firstString
                                                                    attributes:@{NSFontAttributeName: baseFontRegular, NSForegroundColorAttributeName: baseColor}];
    
    NSAttributedString *lastDate = [[NSAttributedString alloc] initWithString:lastString
                                                                   attributes:@{NSFontAttributeName: baseFontRegular, NSForegroundColorAttributeName: baseColor}];
    
    NSMutableAttributedString *currentDate = [[NSMutableAttributedString alloc] initWithString:currentString
                                                                                    attributes:@{NSFontAttributeName: baseFontRegular,
                                                                                                 NSForegroundColorAttributeName: [UIColor whiteColor]}];
    NSAttributedString *dayString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"DAY %i/%i", self.currentDay, self.durationDays]
                                                                        attributes:@{NSFontAttributeName: baseFontBold,
                                                                                     NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [currentDate appendAttributedString:dayString];
    
    if (self.durationDays == 1)
    {
        [currentDate drawAtPoint:CGPointMake(CGRectGetMidX(self.bounds) - currentDate.size.width / 2, CGRectGetMidY(self.bounds) - currentDate.size.height / 2)];
        return;
    }
    
    if (self.showCurrentDateOnly)
    {
        [currentDate drawAtPoint:CGPointMake(CGRectGetMidX(self.bounds) - currentDate.size.width / 2, CGRectGetMidY(self.bounds) - currentDate.size.height / 2)];
        return;
    }
    
    float start = 0.0;
//    if (self.currentDay == 1)
//    {
//        start = currentDate.size.width / 2;
//    }
//    else
//    {
//        start = firstDate.size.width / 2;
//    }
    
    float end = 0.0;
//    if (self.currentDay == self.durationDays)
//    {
//        end = currentDate.size.width / 2;
//    }
//    else
//    {
//        end = lastDate.size.width / 2;
//    }
    
    float length = CGRectGetWidth(self.bounds) - start - end;
    float delta = length / (self.durationDays - 1);
    
//    [firstDate drawAtPoint:CGPointMake(start - firstDate.size.width / 2, CGRectGetMidY(self.bounds) - firstDate.size.height - 10)];
//    [lastDate drawAtPoint:CGPointMake(CGRectGetWidth(self.bounds) - end - lastDate.size.width / 2, CGRectGetMidY(self.bounds) - lastDate.size.height - 10)];
//    [currentDate drawAtPoint:CGPointMake(start + (self.currentDay - 1) * delta - currentDate.size.width / 2, CGRectGetMidY(self.bounds) + 10)];
    [firstDate drawAtPoint:CGPointMake(start, CGRectGetMidY(self.bounds) - firstDate.size.height - 10)];
    [lastDate drawAtPoint:CGPointMake(CGRectGetWidth(self.bounds) - end - lastDate.size.width, CGRectGetMidY(self.bounds) - lastDate.size.height - 10)];
    float xPosition = start + (self.currentDay - 1) * delta - currentDate.size.width / 2;
    if (xPosition < start)
    {
        xPosition = start;
    }
    if (xPosition + currentDate.size.width > length)
    {
        xPosition = length - currentDate.size.width;
    }
    [currentDate drawAtPoint:CGPointMake(xPosition, CGRectGetMidY(self.bounds) + 10)];
    
    
    // Draw timeline with gradient
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:CGRectMake(start, CGRectGetMidY(self.bounds), length, 1.0)];
    
    for (int i = 0; i < self.durationDays; i++)
    {
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(start + i * delta - 1, CGRectGetMidY(self.bounds) - 1, 3, 3)];
        [rectanglePath appendPath:circlePath];
    }
    
    CGContextAddPath(context, rectanglePath.CGPath);
    CGContextClip(context);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    UIColor *gradientStartColor = baseColor;
    UIColor *gradientMiddleColor = baseColor; //[UIColor colorWithRed:141.0/255.0 green:193.0/255.0 blue:255.0/255.0 alpha:1.0];
    UIColor *gradientEndColor = [UIColor whiteColor];
    NSArray *gradientColors = @[(id)gradientStartColor.CGColor, (id)gradientMiddleColor.CGColor, (id)gradientEndColor.CGColor];
    float endLocation = (self.currentDay - 1.0) / (self.durationDays - 1.0);
    CGFloat gradientLocations[3] = {0.0, 0.5 * endLocation, endLocation};
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
    
    CGPoint startPoint = CGPointMake(start, CGRectGetMidY(self.bounds));
    CGPoint endPoint = CGPointMake(CGRectGetWidth(self.bounds) - end, CGRectGetMidY(self.bounds));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRestoreGState(context);
    
    
    //add new dot images
    
    self.currentDot = [[UIImageView alloc] initWithFrame:CGRectMake(start + (self.currentDay - 1) * delta - 10, CGRectGetMidY(self.bounds) - 10, 21, 21)];
    self.currentDot.image = [UIImage imageNamed:@"tm_dot2"];
    [self addSubview:self.currentDot];
    
    self.firstDot = [[UIImageView alloc] initWithFrame:CGRectMake(start - 4, CGRectGetMidY(self.bounds) - 4, 9, 9)];
    self.firstDot.image = [UIImage imageNamed:@"tl_dot1"];
    [self addSubview:self.firstDot];
    
    self.lastDot = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - end - 4, CGRectGetMidY(self.bounds) - 4, 9, 9)];
    self.lastDot.image = [UIImage imageNamed:@"tl_dot1"];
    [self addSubview:self.lastDot];
}

@end
