//
//  CLInfoViewController.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/22/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLHomeViewController.h"
#import "CLSideMenuViewController.h"
#import "CLSyncingStepsViewController.h"

#pragma mark - Type defines and enums

#define kSyncingStepsFitbitJawbonePage 1

#define kSyncingStepsHealthKitPage 2

@interface CLInfoViewController : UIViewController <UIScrollViewDelegate, CLSyncingStepsViewControllerDelegate>

@property (nonatomic, weak) CLHomeViewController *homeViewController;

@end
