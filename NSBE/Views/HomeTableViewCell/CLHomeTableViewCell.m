//
//  CLHomeTableViewCell.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/18/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLHomeTableViewCell.h"
#import "Stylesheet.h"
#import "Constants.h"
#import "CLUser.h"

@interface CLHomeTableViewCell ()

@property (nonatomic, readonly, strong) NSDateFormatter *dateFormatter;

@end

@implementation CLHomeTableViewCell

@dynamic dateFormatter;

#pragma mark - View's lifecycle methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		// Initialization code
	}
	return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
	}
	return self;
}

#pragma mark - Setters and getter

- (NSDateFormatter *)dateFormatter
{
	static NSDateFormatter *dateFormatter;
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		if (!dateFormatter) {
			
			// Create and set up date formatter
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:DATE_FORMAT_DAY_MONTH_YEAR];
		}
	});
	
	return dateFormatter;
}

#pragma mark - Home table view cell methods

- (void)setDeviceImage:(CLUserDevice)device
{
	self.deviceIconImageView.image = [CLUser getDeviceIconImage:device];
}

- (void)setDateLabelDate:(NSDate *)date
{
	self.dateLabel.text = [self.dateFormatter stringFromDate:date];
}

@end
