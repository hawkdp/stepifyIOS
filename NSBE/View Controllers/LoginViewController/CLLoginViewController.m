//
//  CLLoginViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLLoginViewController.h"
#import "CLRegisterViewController.h"
#import "CLFacebookHandler.h"
#import "CLColorStateButton.h"
#import "CLActivityIndicator.h"
#import "UIAlertView+Blocks.h"
#import "UIImage+Resize.h"
#import "Stylesheet.h"
#import "Constants.h"
#import "Utils.h"
#import "CLLinkedinHelper.h"
#import "CLConfirmDeviceViewController.h"
#import "CLTextBoxView.h"

@interface CLLoginViewController ()
@property (nonatomic, assign) BOOL isSignInWithFacebook;
@property (nonatomic, assign) BOOL isSignInWithLinkedIn;
@end

@implementation CLLoginViewController

#pragma mark - View controller's lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[CLUser user] clearUserInfo];
    // Change status bar color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

#pragma mark - Gesture recognizers and actions

- (IBAction)registerViewTapGesture:(UITapGestureRecognizer *)sender {
    // Go to register with email screen
    [self performSegueWithIdentifier:@"SegueToRegisterWithEmail" sender:self];
}

- (IBAction)signInWithEmailViewTapGesture:(UITapGestureRecognizer *)sender {
}

- (IBAction)signInWithFacebookViewTapGesture:(UITapGestureRecognizer *)sender {
    CLUser *user = [CLUser user];

    // Show activity indicator
    [CLActivityIndicator showInView:self.navigationController.view title:NSLocalizedString(@"SigningIn", nil) animated:YES];

    // Make a Facebook login request
    [[CLFacebookHandler sharedInstance] login:^{

        NSLog(@"facebook login success!");

        // Get user data
        [[CLFacebookHandler sharedInstance] getUserInfo:^(id data) {

            NSLog(@"get user info success: %@", data);

            // Fill user details
            user.facebookID = data[kCLFacebookParameterID];
            user.firstName = data[kCLFacebookParameterFirstName];
            user.lastName = data[kCLFacebookParameterLastName];
//            user.email = data[kCLFacebookParameterEmail];
            user.gender = data[kCLFacebookParameterGender];
//			user.birthdate = [Utils facebookStringDateToDate:data[kCLFacebookParameterBirthday]];
//			user.age = @([Utils getYearCountFromDate:user.birthdate]);
            user.profilePictureURL = [USER_REST_API_FACEBOOK_PROFILE_PICTURE_URL
                    stringByReplacingOccurrencesOfString:USER_REST_API_PARAMETER_ID
                                              withString:user.facebookID];
            self.isSignInWithFacebook = YES;
            self.isSignInWithLinkedIn = NO;
            // Create a block that will be executed if profile picture download request will succeed or not
            void (^signInUser)() = ^void() {
                [CLUser signInUserWithFacebookAndSuccessBlock:^(id fbResponse) {
                            [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{
                                // Show success indicator
                                [CLActivityIndicator showSuccessInView:self.navigationController.view
                                                                 title:NSLocalizedString(@"Success", nil)
                                                              animated:YES
                                                           forInterval:ACTIVITY_INDICATOR_NOTIFICATION_PERIOD_SHORT
                                                            completion:
                                                                    ^{
                                                                        if ([fbResponse[@"already_registered"] boolValue] && [fbResponse[@"usr_device_id"] integerValue] != 0) {
                                                                            UIViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewControllerStoryboardID"];
                                                                            [self.navigationController setViewControllers:@[loginViewController] animated:YES];
                                                                        } else {
                                                                            // Segue to the welcome screen
                                                                            [self performSegueWithIdentifier:@"SegueToSelectDevice" sender:self];
                                                                        }
                                                                    }];
                            }];
                        }
                                                 failureBlock:^(id failData, NSError *error) {
                                                     NSLog(@"FACEBOOK ERROR");
                                                 }];

            };

            // Download profile picture
            [CLUser getUserProfilePicture:user successBlock:^(id data) {
                NSLog(@"get user profile picture succeed!");

                // Resize and assign profile picture
                if ([data isKindOfClass:[UIImage class]]) {
                    UIImage *image = [UIImage imageWithCGImage:[data CGImage] scale:1.0f orientation:[data imageOrientation]];
                    image = [image thumbnailImage:PROFILE_PICTURE_THUMBNAIL_SIZE
                                transparentBorder:0
                                     cornerRadius:0
                             interpolationQuality:kCGInterpolationHigh];
                    user.profilePicture = image;
                }

                // Proceed to user sign in
                signInUser();

            }                failureBlock:^(id data, NSError *error) {
                NSLog(@"get user profile picture failed!");

                // Proceed to user sign in
                signInUser();
            }];
        }                                       failure:^(id data, NSError *error) {
            NSLog(@"an error occurred while retrieving user info: %@", [error localizedDescription]);

            // Hide activity indicator
            [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{

                [CLTextBoxView showWithTitle:nil message:NSLocalizedString(@"FacebookLoginError", nil)];

            }];
        }];
    }                                 failure:^(NSError *error) {
        NSLog(@"login failed!");

        // Hide activity indicator
        [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{

            [CLTextBoxView showWithTitle:nil message:NSLocalizedString(@"FacebookAccessNotGranted", nil)];

        }];
    }];
}

- (IBAction)signUpWithLinkedInTapGesture:(UITapGestureRecognizer *)sender {

    [[CLLinkedinHelper sharedHelper] loginWithCompletionBlock:^(id response, NSError *error) {
        if (!error) {
            [CLActivityIndicator showInView:self.navigationController.view
                                      title:NSLocalizedString(@"SigningIn", nil)
                                   animated:YES];

            CLUser *user = [CLUser user];
            user.firstName = response[@"firstName"];
            user.lastName = response[@"lastName"];
            user.linkedInID = response[@"id"];
            user.profilePicture = nil;
            user.profilePictureURL = nil;
            self.isSignInWithLinkedIn = YES;
            self.isSignInWithFacebook = NO;
            [CLUser signInUserWithLinkedInAndSuccessBlock:^(id lnkdInResponse) {
                        [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{
                            // Show success indicator
                            [CLActivityIndicator showSuccessInView:self.navigationController.view
                                                             title:NSLocalizedString(@"Success", nil)
                                                          animated:YES
                                                       forInterval:ACTIVITY_INDICATOR_NOTIFICATION_PERIOD_SHORT
                                                        completion:
                                                                ^{
                                                                    if ([lnkdInResponse[@"already_registered"] boolValue] && [lnkdInResponse[@"usr_device_id"] integerValue] != 0) {
                                                                        UIViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewControllerStoryboardID"];
                                                                        [self.navigationController setViewControllers:@[loginViewController] animated:YES];
                                                                    } else {
                                                                        // Segue to the welcome screen
                                                                        [self performSegueWithIdentifier:@"SegueToSelectDevice" sender:self];
                                                                    }
                                                                }];
                        }];
                    }
                                             failureBlock:^(id errorData, NSError *error) {
                                                 NSLog(@"");
                                                 [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{}];
                                                 if (!errorData && !error) {
                                                     [self.navigationController popViewControllerAnimated:YES];
                                                 }
                                             }];

        }
    }];
}

#pragma mark - Intro segue delegate methods

- (void)introSegueDidFinishAnimation:(CLIntroSegue *)introSegue {
    // Leave only this view controller on navigation stack
    [self.navigationController setViewControllers:@[self] animated:NO];

    NSLog(@"navigation stack: %@", self.navigationController.viewControllers);
}

#pragma mark - Storyboard navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueToRegisterWithEmail"]) {

        // Segue to register with email/facebook view controller (step 1)
        [(CLRegisterViewController *) segue.destinationViewController setType:CLRegisterViewControllerTypeStep1];

        // Set register with Facebook to YES
        if (sender == [CLUser user]) {
            [(CLRegisterViewController *) segue.destinationViewController setFacebookRegistration:YES];
        }
    }
}

#pragma mark - View controller's memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    NSLog(@"memory warning received");
}

@end
