//
//  CLSyncingStepsViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLSyncingStepsViewController.h"

@implementation CLSyncingStepsViewController

#pragma mark - View controller's lifecycle methods

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - Gesture recognizers and actions

- (IBAction)fitbitAndJawboneAction:(UITapGestureRecognizer *)sender
{
	// Call delegate method
	if (self.delegate) {
		[self.delegate syncingStepsViewController:self fitbitAndJawbonePressed:sender];
	}
}

- (IBAction)healthKitAction:(UITapGestureRecognizer *)sender
{
	// Call delegate method
	if (self.delegate) {
		[self.delegate syncingStepsViewController:self healthKitPressed:sender];
	}
}

#pragma mark - View controller's memory management

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"memory warning received");
}

@end
