//
//  CLSyncingStepsViewControllerDelegate.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLSyncingStepsViewController;

@protocol CLSyncingStepsViewControllerDelegate <NSObject>

@required

- (void)syncingStepsViewController:(CLSyncingStepsViewController *)syncingStepsViewController
		   fitbitAndJawbonePressed:(id)fitbitAndJawbone;

- (void)syncingStepsViewController:(CLSyncingStepsViewController *)syncingStepsViewController
				  healthKitPressed:(id)healthKit;

@end

