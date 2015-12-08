//
//  CLCircularImageView.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/27/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLCircularImageView.h"

@implementation CLCircularImageView

#pragma mark - View's lifecycle methods

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		// Initialization code
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
}

#pragma mark - Layout delegate methods

- (void)layoutSubviews
{
	self.layer.cornerRadius = self.frame.size.height / 2.0;
	self.layer.borderWidth = 0.0f;
	self.clipsToBounds = YES;
}

@end
