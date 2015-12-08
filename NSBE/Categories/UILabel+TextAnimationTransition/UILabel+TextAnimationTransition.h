//
//  UILabel+TextAnimationTransition.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/13/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (TextAnimationTransition)

- (void)setText:(NSString *)text animationDuration:(NSTimeInterval)duration;

@end
