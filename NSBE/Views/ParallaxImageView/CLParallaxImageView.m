//
//  CLParallaxImageView.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/27/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLParallaxImageView.h"
#import "Constants.h"

@implementation CLParallaxImageView

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
	// Set vertical effect
	UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc]
														 initWithKeyPath:@"center.y"
														 type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalMotionEffect.minimumRelativeValue = @(-BACKGROUND_IMAGE_PARALLAX_OFFSET);
	verticalMotionEffect.maximumRelativeValue = @(BACKGROUND_IMAGE_PARALLAX_OFFSET);
	
	// Set horizontal effect
	UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc]
														   initWithKeyPath:@"center.x"
														   type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalMotionEffect.minimumRelativeValue = @(-BACKGROUND_IMAGE_PARALLAX_OFFSET);
	horizontalMotionEffect.maximumRelativeValue = @(BACKGROUND_IMAGE_PARALLAX_OFFSET);
	
	// Create group to combine both
	UIMotionEffectGroup *group = [UIMotionEffectGroup new];
	group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
	
	// Add both effects to your background image view
	[self addMotionEffect:group];
}

@end
