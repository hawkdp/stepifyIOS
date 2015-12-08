//
//  CLActivityScreenTableSectionHeaderView.m
//  NSBE
//

#define DAYS_IN_WEEK 7

#import "CLActivityScreenTableSectionHeaderView.h"
#import "Utils.h"

@interface CLActivityScreenTableSectionHeaderView()
@property (nonatomic, strong) UILabel *headerLabel;
@end

@implementation CLActivityScreenTableSectionHeaderView

#pragma mark - NSObject

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Designated initializer

- (instancetype)initForTableView:(UITableView *)tableView{
    if (self = [super initWithFrame:CGRectMake(0, 5, tableView.frame.size.width, 20.0)]) {
        self.backgroundColor = [UIColor clearColor];
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, self.frame.size.width, 15.0)];
        self.headerLabel.backgroundColor = [UIColor clearColor];
        self.headerLabel.textAlignment = NSTextAlignmentCenter;
        [self.headerLabel setFont:[UIFont fontWithName:@"Geomanist-Regular" size:12.0]];
        self.headerLabel.textColor = [UIColor whiteColor];
        self.headerLabel.alpha = 0.5f;
        [self addSubview:self.headerLabel];
    }
    return self;
}

#pragma mark - Public methods

- (void)setLabelFormattedTextWithDateString:(NSString *)dateString {
    NSDateFormatter *yyy_MM_dd_dateFormatter = [[NSDateFormatter alloc] init];
    yyy_MM_dd_dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *dateParam = [yyy_MM_dd_dateFormatter dateFromString:dateString];

    if ([Utils isDate:dateParam sameDayAsDate:[NSDate date]]) {

        self.headerLabel.text = @"Today";

    } else if ([Utils daysBetweenDate:dateParam andDate:[NSDate date]] <= DAYS_IN_WEEK) {

        NSDateFormatter *MM_dd_dateFormatter = [[NSDateFormatter alloc] init];
        MM_dd_dateFormatter.dateFormat = @"M dd";
        MM_dd_dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        NSDateFormatter *weekDay_dateFormatter = [[NSDateFormatter alloc] init];
        weekDay_dateFormatter.dateFormat = @"EE";
        NSString *weekdayStr = [weekDay_dateFormatter stringFromDate:dateParam];
        NSString *dateStrWithYear = [MM_dd_dateFormatter stringFromDate:dateParam];
        NSArray *dateParams = [dateStrWithYear componentsSeparatedByString:@","];
        self.headerLabel.text = [NSString stringWithFormat:@"%@, %@", weekdayStr, [dateParams firstObject]];

    } else {

        NSDateFormatter *MM_dd_yyyydateFormatter = [[NSDateFormatter alloc] init];
        yyy_MM_dd_dateFormatter.dateFormat = @"MM dd, yyyy";
        self.headerLabel.text = [MM_dd_yyyydateFormatter stringFromDate:dateParam];

    }
}

@end
