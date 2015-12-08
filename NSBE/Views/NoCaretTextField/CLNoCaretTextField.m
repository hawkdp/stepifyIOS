//
//  CLNoCaretTextField.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/27/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLNoCaretTextField.h"

@implementation CLNoCaretTextField

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

#pragma mark - Text input delegate methods

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
	return CGRectZero;
}

@end
