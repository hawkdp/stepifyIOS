//
//  CLHomeViewController.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/4/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLUser.h"
#import "CLUser+API.h"
#import "CLIntroSegue.h"
#import "CLSideMenuViewController.h"

@interface CLHomeViewController : UIViewController <CLIntroSegueDelegate,
                                                    /*CLUserNotificationProtocol,*/
                                                    CLSideMenuViewControllerDelegate>

- (void)syncUserStepsWithComplitionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

@end
