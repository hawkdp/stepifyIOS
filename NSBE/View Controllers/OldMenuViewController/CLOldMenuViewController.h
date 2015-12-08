//
//  CLOldMenuViewController.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/14/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLOldMenuViewControllerDelegate.h"

@interface CLOldMenuViewController : UIViewController

@property (nonatomic, weak) id<CLOldMenuViewControllerDelegate> delegate;

@end
