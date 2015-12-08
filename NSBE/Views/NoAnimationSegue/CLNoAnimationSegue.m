//
//  CLNoAnimationSegue.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLNoAnimationSegue.h"

@implementation CLNoAnimationSegue

- (void)perform
{
	// Just push destination view controller without any animations
	[[(UIViewController *) [self sourceViewController] navigationController]
	 pushViewController:[self destinationViewController] animated:NO];
}

@end
