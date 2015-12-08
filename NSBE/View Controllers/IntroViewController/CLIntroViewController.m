//
//  CLIntroViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/17/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLIntroViewController.h"
#import "CLSlideshowViewController.h"
#import "CLUser.h"
#import "Stylesheet.h"
#import "CLUser+API.h"

#pragma mark - Type defines and enums

#define kUserDefaultsIntroAlreadyShownKey @"userDefaultsIntroAlreadyShown"

@interface CLIntroViewController ()

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property(nonatomic, weak) IBOutlet UIView *signUpView;
@property(nonatomic, weak) IBOutlet UIImageView *poweredByImageView;
@property(nonatomic, weak) IBOutlet UIImageView *cardioLegendLogoImageView;

@property(nonatomic, assign) BOOL performAnimation;

@end

@implementation CLIntroViewController

#pragma mark - View controller's lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];

    // Check if we have user data stored locally on the device. An access token must exist
    CLUser *user = [CLUser user];
    if (user.accessToken) {

        NSLog(@"user found, segue to home");
        int timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);
        NSDictionary *parameters = @{USER_REST_PARAMETER_TIME_OFFSET : @(timezoneoffset)};
        [CLUser updateUserProfileWithParameters:parameters
                                completionBlock:^(id ok) {
                                    // The user was saved locally and has the necessary data, segue to home view controller
                                    [self performSegueWithIdentifier:@"SegueToHome" sender:self];
                                }
                                   failureBlock:^(id failResponse, NSError *error) {
                                       NSLog(@"Failed %s", __PRETTY_FUNCTION__);
                                   }];

    } else {

        NSLog(@"user not found, segue to login");

        // The user was not found on the device, segue to login view controller
//			[self performSegueWithIdentifier:@"SegueToSignIn" sender:self];
    }

    // Do any additional setup after loading the view.

//	if ([self introAlreadyShown]) {
//
//
//	} else {
//
//		NSLog(@"show slideshow screens for the first time");
//
//		// Intro screen was not yet shown, perform animation
//		self.performAnimation = YES;
//
//		// Hide animated views
//		self.pageControl.alpha = 0.0f;
//		self.signUpView.alpha = 0.0f;
//		self.cardioLegendLogoImageView.alpha = 0.0f;
//	}

    self.performAnimation = YES;
    // Hide animated views
    self.pageControl.alpha = 0.0f;
    self.signUpView.alpha = 0.0f;
    self.cardioLegendLogoImageView.alpha = 0.0f;
    // Disable scroll view's scrolling until animation is completed
    self.scrollView.scrollEnabled = NO;

    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Change status bar color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.performAnimation) {

        // Animation is performing
        self.performAnimation = NO;

        // Start intro animation
        [UIView animateWithDuration:INTRO_VIEW_CONTROLLER_ANIMATION_DURATION
                              delay:INTRO_VIEW_CONTROLLER_ANIMATION_DELAY
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:
                                 ^{
                                     // Make page control, sign up view and Cardio Legend logo visible
                                     self.pageControl.alpha = 1.0f;
                                     self.signUpView.alpha = 1.0f;
                                     self.cardioLegendLogoImageView.alpha = 1.0f;

                                     // Hide powered by image view
                                     self.poweredByImageView.alpha = 0.0f;

                                 } completion:^(BOOL finished) {

                    // Enable scroll view's scroll
                    self.scrollView.scrollEnabled = YES;

                    // Set intro already shown
                    [self setIntroAlreadyShown:YES];
                }];

        // Animate the change of the first slideshow background image view
        for (UIViewController *viewController in self.childViewControllers) {
            if ([viewController isKindOfClass:[CLSlideshowViewController class]]) {
                CLSlideshowViewController *slideshowViewController = (CLSlideshowViewController *) viewController;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (INTRO_VIEW_CONTROLLER_ANIMATION_DELAY *
                        NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                    [UIView transitionWithView:slideshowViewController.slideshowBackgroundImageView1
                                      duration:INTRO_VIEW_CONTROLLER_ANIMATION_DURATION
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:
                                            ^{
                                                slideshowViewController.slideshowBackgroundImageView1.image =
                                                        INTRO_VIEW_CONTROLLER_SLIDESHOW_BACKGROUND_IMAGE1;
                                            } completion:NULL];
                });
                break;
            }
        }
    }
}

#pragma mark - Gesture recognizers and actions

- (IBAction)signUpTapGesture:(UITapGestureRecognizer *)sender {
    NSLog(@"sign up");

    // Get login view controller and set it as the only view controller to free the memory allocated to
    // intro view controller
    UIViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewControllerStoryboardID"];
    [self.navigationController setViewControllers:@[loginViewController] animated:YES];
}

- (IBAction)signInTapGesture:(UITapGestureRecognizer *)sender {
    UIViewController *signUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInViewControllerStoryboardID"];
    [self.navigationController setViewControllers:@[signUpViewController]
                                         animated:YES];
}


- (IBAction)pageChangedAction:(UIPageControl *)sender {
    // Set scroll view's content offset according to the current page
    [self.scrollView setContentOffset:CGPointMake(sender.currentPage * self.scrollView.frame.size.width, 0.0f) animated:YES];
}

#pragma mark - Scroll view delegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Set current page for page control view
    NSInteger page = lround(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    self.pageControl.currentPage = page;
}

#pragma mark - User defaults management methods

- (BOOL)introAlreadyShown {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kUserDefaultsIntroAlreadyShownKey];
}

- (void)setIntroAlreadyShown:(BOOL)shown {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:shown forKey:kUserDefaultsIntroAlreadyShownKey];
    [userDefaults synchronize];
}

#pragma mark - View controller's memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    NSLog(@"memory warning received");
}

@end
