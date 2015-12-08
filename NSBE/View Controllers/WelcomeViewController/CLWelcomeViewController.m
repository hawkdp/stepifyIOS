//
//  CLWelcomeViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/4/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLWelcomeViewController.h"
#import "Stylesheet.h"

@interface CLWelcomeViewController ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topViewVerticalSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionViewVerticalSpaceConstraint;

@property (nonatomic, weak) IBOutlet UIView *topView;
@property (nonatomic, weak) IBOutlet UIView *descriptionView1;
@property (nonatomic, weak) IBOutlet UIView *descriptionView2;
@property (nonatomic, weak) IBOutlet UILabel *tapToContinueLabel;

@property (nonatomic, assign) BOOL performAnimation;

@property (weak, nonatomic) IBOutlet UIView *informationView;
@property (weak, nonatomic) IBOutlet UIButton *letsGoButton;
@end

@implementation CLWelcomeViewController

#pragma mark - View controller's lifecycle methods

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.informationView.layer.cornerRadius = 5.0f;
    self.letsGoButton.layer.borderColor = [UIColor colorWithRed:186.0/255.0 green:191.0/255.0 blue:16.0/255.0 alpha:1.0].CGColor;
    self.letsGoButton.layer.borderWidth = 1.0;
    self.letsGoButton.layer.cornerRadius = 18.0;
    self.navigationItem.hidesBackButton = YES;
	self.performAnimation = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Change status bar color
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (self.performAnimation) {
		
		// Welcome animation is performing
		self.performAnimation = NO;
		
		// Update views' constraints
		self.topViewVerticalSpaceConstraint.constant = 0.0f;
		self.descriptionViewVerticalSpaceConstraint.constant = 0.0f;
		
		// Start welcome animation
		[UIView animateWithDuration:WELCOME_VIEW_CONTROLLER_WELCOME_ANIMATION_DURATION
							  delay:WELCOME_VIEW_CONTROLLER_WELCOME_ANIMATION_DELAY
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:
		 ^{
			 // Make description view visible
			 self.descriptionView1.alpha = 1.0f;
			 self.descriptionView2.alpha = 1.0f;
			 
			 // Update layout
			 [self.view layoutIfNeeded];
			 
		 } completion:^(BOOL finished) {
			 
			 // Show tap anywhere to continue appearing animation
			 [UIView animateWithDuration:WELCOME_VIEW_CONTROLLER_BLINK_ANIMATION_DURATION animations:^{
				 
				 // Set tap to continue label alpha
				 self.tapToContinueLabel.alpha = 1.0f;
				 
			 } completion:^(BOOL finished) {
				 
				 // Start tap anywhere to continue blinking animation
				 [UIView animateWithDuration:WELCOME_VIEW_CONTROLLER_BLINK_ANIMATION_DURATION
									   delay:0.0f
									 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
								  animations:
				  ^{
					  // Set animation repeat count
					  [UIView setAnimationRepeatCount:WELCOME_VIEW_CONTROLLER_BLINK_ANIMATION_REPEAT_COUNT];
					  
					  // Set tap to continue label alpha
					  self.tapToContinueLabel.alpha = 0.0f;
					  
				  } completion:nil];
			 }];
		 }];
	}
}

#pragma mark - Layout delegate methods

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	// Prepare views for animation
	if (self.performAnimation) {
		self.topViewVerticalSpaceConstraint.constant = (self.view.frame.size.height - self.topView.frame.size.height) / 2.0f;
		self.descriptionViewVerticalSpaceConstraint.constant = -self.topViewVerticalSpaceConstraint.constant;
		self.descriptionView1.alpha = 0.0f;
		self.descriptionView2.alpha = 0.0f;
	}
}

#pragma mark - Gesture recognizers and actions

- (IBAction)viewTapGesture:(UITapGestureRecognizer *)sender
{
    [self performSegueWithIdentifier:@"SegueToHome" sender:self];
}

- (IBAction)tapOnLetsGoButton:(UIButton *)sender {
    [self performSegueWithIdentifier:@"SegueToHome" sender:self];
}

#pragma mark - View controller's memory management

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"memory warning received");
}

@end
