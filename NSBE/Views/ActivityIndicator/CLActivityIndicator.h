//
//  CLActivityIndicator.h
//  NSBE
//
//  Created by Iulian Corcoja on 1/29/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRProgress.h"

#pragma mark - Type defines

typedef void (^CLActivityIndicatorCompletionBlock)();

#pragma mark - Activity indicator interface

@interface CLActivityIndicator : NSObject

+ (void)showInView:(UIView *)view
			 title:(NSString *)title
		  animated:(BOOL)animated;

+ (void)showInView:(UIView *)view
		  animated:(BOOL)animated;

+ (void)showSuccessInView:(UIView *)view
					title:(NSString *)title
				 animated:(BOOL)animated
			  forInterval:(NSTimeInterval)interval
			   completion:(CLActivityIndicatorCompletionBlock)completion;

+ (void)showFailureInView:(UIView *)view
					title:(NSString *)title
				 animated:(BOOL)animated
			  forInterval:(NSTimeInterval)interval
			   completion:(CLActivityIndicatorCompletionBlock)completion;

+ (void)hideForView:(UIView *)view
		   animated:(BOOL)animated;

+ (void)hideForView:(UIView *)view
		   animated:(BOOL)animated
		 completion:(CLActivityIndicatorCompletionBlock)completion;

@end
