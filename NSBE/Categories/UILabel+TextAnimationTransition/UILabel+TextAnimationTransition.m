//
//  UILabel+TextAnimationTransition.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/13/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "UILabel+TextAnimationTransition.h"

@implementation UILabel (TextAnimationTransition)

- (void)setText:(NSString *)text animationDuration:(NSTimeInterval)duration
{
	[UIView transitionWithView:self duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[self setText:text];
	} completion:nil];
}

@end
