//
//  CLActivityIndicator.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/29/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLActivityIndicator.h"

@implementation CLActivityIndicator

+ (void)showInView:(UIView *)view
			 title:(NSString *)title
		  animated:(BOOL)animated
{
	[MRProgressOverlayView showOverlayAddedTo:view
										title:title
										 mode:MRProgressOverlayViewModeIndeterminate
									 animated:animated];
}

+ (void)showInView:(UIView *)view
		  animated:(BOOL)animated
{
	[CLActivityIndicator showInView:view title:@"" animated:animated];
}

+ (void)showSuccessInView:(UIView *)view
					title:(NSString *)title
				 animated:(BOOL)animated
			  forInterval:(NSTimeInterval)interval
			   completion:(CLActivityIndicatorCompletionBlock)completion
{
	[MRProgressOverlayView showOverlayAddedTo:view
										title:title
										 mode:MRProgressOverlayViewModeCheckmark
									 animated:animated];
	
	// Dispatch after several time
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (((float) interval / 1000.0f) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[MRProgressOverlayView dismissOverlayForView:view animated:YES completion:^{
			if (completion){
				completion();
			}
		}];
	});
}

+ (void)showFailureInView:(UIView *)view
					title:(NSString *)title
				 animated:(BOOL)animated
			  forInterval:(NSTimeInterval)interval
			   completion:(CLActivityIndicatorCompletionBlock)completion
{
	[MRProgressOverlayView showOverlayAddedTo:view
										title:title
										 mode:MRProgressOverlayViewModeCross
									 animated:animated];
	
	// Dispatch after several time
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (((float) interval / 1000.0f) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[MRProgressOverlayView dismissOverlayForView:view animated:YES completion:^{
			if (completion){
				completion();
			}
		}];
	});
}

+ (void)hideForView:(UIView *)view
		   animated:(BOOL)animated
{
	[CLActivityIndicator hideForView:view animated:animated completion:nil];
}

+ (void)hideForView:(UIView *)view
		   animated:(BOOL)animated
		 completion:(CLActivityIndicatorCompletionBlock)completion
{
	[MRProgressOverlayView dismissOverlayForView:view animated:animated completion:^{
		if (completion){
			completion();
		}
	}];
}

@end
