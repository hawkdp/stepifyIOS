//
//  CLSyncingStepsViewController.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLSyncingStepsViewControllerDelegate.h"

@interface CLSyncingStepsViewController : UIViewController

@property (nonatomic, weak) id<CLSyncingStepsViewControllerDelegate> delegate;

@end
