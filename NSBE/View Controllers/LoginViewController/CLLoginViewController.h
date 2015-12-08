//
//  CLLoginViewController.h
//  NSBE
//
//  Created by Iulian Corcoja on 1/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLKeyboardViewController.h"
#import "CLUser.h"
#import "CLUser+API.h"
#import "CLIntroSegue.h"

@interface CLLoginViewController : CLKeyboardViewController <CLIntroSegueDelegate>

@end
