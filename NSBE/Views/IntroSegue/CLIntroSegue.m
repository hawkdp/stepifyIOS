//
//  CLIntroSegue.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/17/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLIntroSegue.h"
#import "Stylesheet.h"
#import "Utils.h"

@implementation CLIntroSegue

- (void)perform
{
	// Perform a custom segue with fade animation using launch images
	UIViewController *sourceViewController = self.sourceViewController;
	UIViewController *destinationViewController = self.destinationViewController;
	
	// Create launch image view and add it to destination view controller's view
	UIImageView *launchImageView = [[UIImageView alloc] initWithImage:[Utils getDeviceLaunchScreenImage]];
	[launchImageView setContentMode:UIViewContentModeScaleAspectFill];
	[launchImageView setAlpha:1.0f];
	[destinationViewController.view addSubview:launchImageView];
	
	// Create and add constraints to launch image view
	NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:launchImageView attribute:
										 NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:
										 destinationViewController.view attribute:NSLayoutAttributeTop multiplier:1.0f
																	  constant:0.0f];
	NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:launchImageView attribute:
											NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:
											destinationViewController.view attribute:NSLayoutAttributeBottom multiplier:1.0f
																		 constant:0.0f];
	NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:launchImageView attribute:
										  NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:
										  destinationViewController.view attribute:NSLayoutAttributeLeading multiplier:1.0f
																	   constant:0.0f];
	NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:launchImageView attribute:
										   NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:
										   destinationViewController.view attribute:NSLayoutAttributeTrailing multiplier:1.0f
																		constant:0.0f];
	[destinationViewController.view addConstraints:@[topConstraint, bottomConstraint, leftConstraint, rightConstraint]];
	
	// Push destination view controller and layout it's subviews
	[sourceViewController.navigationController pushViewController:destinationViewController animated:NO];
	[destinationViewController.view layoutIfNeeded];
	[destinationViewController.view bringSubviewToFront:launchImageView];
	
	// Fade out launch image with animation
	[UIView animateWithDuration:INTRO_VIEW_CONTROLLER_CUSTOM_SEGUE_ANIMATION_DURATION animations:^{
		launchImageView.alpha = 0.0f;
	} completion:^(BOOL finished) {

		// Remove launch image view
		[launchImageView removeFromSuperview];

		// Call delagate method if destination view controller conform to the protocol
		if ([destinationViewController conformsToProtocol:@protocol(CLIntroSegueDelegate)] &&
			[destinationViewController respondsToSelector:@selector(introSegueDidFinishAnimation:)]) {
			[(id<CLIntroSegueDelegate>) destinationViewController introSegueDidFinishAnimation:self];
		}
	}];
}

@end
