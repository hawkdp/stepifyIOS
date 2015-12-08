//
//  CLOldMenuViewControllerDelegate.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/22/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLOldMenuViewController;

@protocol CLOldMenuViewControllerDelegate <NSObject>

@required

- (void)menuViewController:(CLOldMenuViewController *)menuViewController homeMenuPressed:(id)homeMenu;

- (void)menuViewController:(CLOldMenuViewController *)menuViewController challengeDetailsMenuPressed:(id)challengeDetailsMenu;

- (void)menuViewController:(CLOldMenuViewController *)menuViewController syncingStepsMenuPressed:(id)syncingStepsMenu;

- (void)menuViewController:(CLOldMenuViewController *)menuViewController prizesMenuPressed:(id)prizesMenu;

- (void)menuViewController:(CLOldMenuViewController *)menuViewController cardioLegendMenuPressed:(id)prizesMenu;

- (void)menuViewController:(CLOldMenuViewController *)menuViewController signOutButtonPressed:(id)signOutButton;
@end
