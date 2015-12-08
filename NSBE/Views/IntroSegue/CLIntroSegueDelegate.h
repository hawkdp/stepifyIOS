//
//  CLIntroSegueDelegate.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/17/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLIntroSegue;

@protocol CLIntroSegueDelegate <NSObject>

@optional

- (void)introSegueDidFinishAnimation:(CLIntroSegue *)introSegue;

@end
