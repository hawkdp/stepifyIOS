//
//  CLColorStateButton.h
//  NSBE
//
//  Created by Iulian Corcoja on 1/27/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLColorStateButton : UIButton

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

- (UIColor *)backgroundColorForState:(UIControlState)state;

@end
