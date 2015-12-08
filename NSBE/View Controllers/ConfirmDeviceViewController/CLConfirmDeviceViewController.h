//
//  CLConfirmDeviceViewController.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/1/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLUser.h"
#import "CLUser+API.h"

@interface CLConfirmDeviceViewController : UIViewController
@property (nonatomic, assign) BOOL isSignInWithFacebook;
@property (nonatomic, assign) BOOL isSignInWithLinkedIn;
@end
