//
//  CLOldMenuViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/14/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLOldMenuViewController.h"

@implementation CLOldMenuViewController

#pragma mark - View controller's lifecycle methods

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - Gesture recognizers and actions

- (IBAction)closeAction:(UIButton *)sender
{
	// Dismiss menu
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:transition forKey:nil];
//    [self dismissModalViewControllerAnimated:NO];
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)homeViewTapGesture:(UITapGestureRecognizer *)sender
{
	// Call delegate method
	if (self.delegate) {
		[self.delegate menuViewController:self homeMenuPressed:sender];
	}
}

- (IBAction)challengeDetailsViewTapGesture:(UITapGestureRecognizer *)sender
{
	// Call delegate method
	if (self.delegate) {
		[self.delegate menuViewController:self challengeDetailsMenuPressed:self];
	}
}

- (IBAction)syncingStepsViewTapGesture:(UITapGestureRecognizer *)sender
{
	// Call delegate method
	if (self.delegate) {
		[self.delegate menuViewController:self syncingStepsMenuPressed:sender];
	}
}

- (IBAction)prizesViewTapGesture:(UITapGestureRecognizer *)sender
{
	// Call delegate method
	if (self.delegate) {
		[self.delegate menuViewController:self prizesMenuPressed:sender];
	}
}

- (IBAction)cardioLegendViewTapGesture:(UITapGestureRecognizer *)sender
{
	// Call delegate method
	if (self.delegate) {
		[self.delegate menuViewController:self cardioLegendMenuPressed:sender];
	}
}

- (IBAction)tapOnSignOutButton:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate menuViewController:self signOutButtonPressed:sender];
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
