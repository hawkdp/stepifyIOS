//
//  CLInfoViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/22/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLInfoViewController.h"

@interface CLInfoViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end

@implementation CLInfoViewController

#pragma mark - View controller's lifecycle methods

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// Make transparent views to all view's child views and set the delegate to syncing steps
	// view controller
	for (UIViewController *viewController in self.childViewControllers) {
		[viewController.view setBackgroundColor:[UIColor clearColor]];
		
		// Set syncing steps delegate
		if ([viewController isKindOfClass:[CLSyncingStepsViewController class]]) {
			[(CLSyncingStepsViewController *) viewController setDelegate:self];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Change status bar color
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark - Gesture recognizers and actions

- (IBAction)menuAction:(UIButton *)sender
{
	NSLog(@"show menu");
	
	// Get menu view controller and present it modally
	CLSideMenuViewController *menuViewController = [self.storyboard
												instantiateViewControllerWithIdentifier:@"MenuViewControllerStoryboardID"];
	[menuViewController setDelegate:self.homeViewController];
	[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:menuViewController
																							 animated:YES
																						   completion:nil];
}

- (IBAction)pageChangedAction:(UIPageControl *)sender
{
	// Set scroll view's content offset according to the current page
	[self.scrollView setContentOffset:CGPointMake(sender.currentPage * self.scrollView.frame.size.width, 0.0f) animated:YES];
}

#pragma mark - Syncing steps view controller delegate methods

- (void)syncingStepsViewController:(CLSyncingStepsViewController *)syncingStepsViewController
		   fitbitAndJawbonePressed:(id)fitbitAndJawbone
{
	// Set scroll view's content offset and control page to Fitbit and Jawbone page
	self.pageControl.currentPage = kSyncingStepsFitbitJawbonePage;
	[self.scrollView setContentOffset:CGPointMake(kSyncingStepsFitbitJawbonePage * self.scrollView.frame.size.width, 0.0f)
							 animated:YES];
}

- (void)syncingStepsViewController:(CLSyncingStepsViewController *)syncingStepsViewController
				  healthKitPressed:(id)healthKit
{
	// Set scroll view's content offset and control page to HealthKit page
	self.pageControl.currentPage = kSyncingStepsHealthKitPage;
	[self.scrollView setContentOffset:CGPointMake(kSyncingStepsHealthKitPage * self.scrollView.frame.size.width, 0.0f)
							 animated:YES];
}

#pragma mark - Scroll view delegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	// Set current page for page control view
	NSInteger page = lround(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
	self.pageControl.currentPage = page;
}

#pragma mark - View controller's memory management

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"memory warning received");
}

@end
