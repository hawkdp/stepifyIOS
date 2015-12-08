//
//  CLConfirmDeviceViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/1/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#define ENABLED_COLOR [[UIColor whiteColor] colorWithAlphaComponent:1.0]
#define DISABLED_COLOR [[UIColor whiteColor] colorWithAlphaComponent:0.2]
#define ENABLED_BORDER_COLOR [UIColor colorWithRed:186.0/255.0 green:191.0/255.0 blue:16.0/255.0 alpha:1.0]
#define DISABLED_BORDER_COLOR [UIColor colorWithRed:186.0/255.0 green:191.0/255.0 blue:16.0/255.0 alpha:0.4]

#import "CLConfirmDeviceViewController.h"
#import "CLProfilePicturePicker.h"
#import "CLColorStateButton.h"
#import "CLActivityIndicator.h"
#import "UIAlertView+Blocks.h"
#import "Stylesheet.h"
#import "Constants.h"
#import "Utils.h"
#import "CLTextBoxView.h"
#import "CLPresentAnimationController.h"
#import "CLDismissAnimationController.h"
#import "CLAgreementViewController.h"

@interface CLConfirmDeviceViewController () <UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIView *deviceInfoView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UIImageView *profilePictureImageView;
@property(nonatomic, weak) IBOutlet UIImageView *deviceImageView;
@property(nonatomic, weak) IBOutlet UILabel *deviceTypeLabel;
@property(nonatomic, weak) IBOutlet UILabel *deviceNameLabel;
@property(nonatomic, weak) IBOutlet UIImageView *checkboxImageView;
@property(nonatomic, weak) IBOutlet CLColorStateButton *nextButton;
@property(nonatomic, weak) IBOutlet CLColorStateButton *backButton;

@property(nonatomic, assign) BOOL termsAccepted;

@property (nonatomic, strong) CLPresentAnimationController *presentAnimationController;
@property (nonatomic, strong) CLDismissAnimationController *dismissAnimationController;

@property (weak, nonatomic) IBOutlet UILabel *healthInfoLabel;
@end

@implementation CLConfirmDeviceViewController

#pragma mark - View controller's lifecycle methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _presentAnimationController = [CLPresentAnimationController new];
        _dismissAnimationController = [CLDismissAnimationController new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.navigationController
                                                                            action:@selector(popViewControllerAnimated:)];
    self.deviceInfoView.layer.cornerRadius = 5.0f;
    // Do any additional setup after loading the view.
    NSLog(@"user: %@", [CLUser user]);

    // Terms and conditions and privacy policy are not accepted by default
    self.termsAccepted = NO;

    self.backButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
    self.backButton.layer.borderWidth = 1.0;
    self.backButton.layer.cornerRadius = 18.0;

    self.nextButton.layer.borderColor = DISABLED_BORDER_COLOR.CGColor;
    self.nextButton.layer.borderWidth = 1.0;
    self.nextButton.layer.cornerRadius = 18.0;
//    // Set control properties

    [self.nextButton setTitleColor:ENABLED_COLOR forState:UIControlStateNormal];
    [self.nextButton setTitleColor:DISABLED_COLOR forState:UIControlStateDisabled];
    [self.nextButton setEnabled:NO];

    // Set device type and name labels and image
    switch ([CLUser user].device) {
        case kCLUserDeviceFitbit: {
            self.deviceImageView.image = DEVICE_ICON_FITBIT_IMAGE;
            self.deviceTypeLabel.text = [NSString stringWithFormat:@"%@'s FitBit device",[CLUser user].firstName];
            self.deviceNameLabel.text = @"FitBit";
            self.healthInfoLabel.text = @"";
            break;
        }
        case kCLUserDeviceJawbone: {
            self.deviceImageView.image = DEVICE_ICON_JAWBONE_IMAGE;
            self.deviceTypeLabel.text = [NSString stringWithFormat:@"%@'s JawBone device",[CLUser user].firstName];
            self.deviceNameLabel.text = @"JawBone";
            self.healthInfoLabel.text = @"";
            break;
        }
        case kCLUserDeviceHealthKit: {
            self.deviceImageView.image = DEVICE_ICON_HEALTHKIT_IMAGE;
            self.deviceTypeLabel.text = [NSString stringWithFormat:@"%@'s iPhone",[CLUser user].firstName];
            self.deviceNameLabel.text = DEVICE_NAME_HEALTHKIT_TEXT;
            self.healthInfoLabel.text = @"Note: Only iPhone 5s and later models are supporting HealthKit auto-tracking!";
            break;
        }
        default: {
            self.deviceImageView.image = nil;
            self.deviceTypeLabel.text = nil;
            self.deviceNameLabel.text = nil;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set profile picture image
    CLUser *user = [CLUser user];
    if (user.profilePicture) {
        [self.profilePictureImageView setImage:user.profilePicture];
    }
}

#pragma mark - Gesture recognizers and actions

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signUpAction:(UIButton *)sender {
    // Ask the user if he's sure about device choice
    
    [CLTextBoxView showWithTitle:nil message:NSLocalizedString(@"ConfirmDeviceSelection", nil) completionBlock:^{
        [self signUpUser];
    }];
}

- (IBAction)profilePictureTapGesture:(UITapGestureRecognizer *)sender {
    [[CLProfilePicturePicker sharedInstance] pickProfilePictureInViewController:self
                                                               showDeleteOption:[CLUser user].profilePicture != nil
                                                                     completion:
                                                                             ^(UIImage *image, BOOL deleted) {

                                                                                 if (deleted) {

                                                                                     // Delete current profile picture
                                                                                     self.profilePictureImageView.image = nil;
                                                                                     [CLUser user].profilePicture = nil;
                                                                                 } else {

                                                                                     // Assign selected profile picture
                                                                                     self.profilePictureImageView.image = image;
                                                                                     [CLUser user].profilePicture = image;
                                                                                 }
                                                                             }];
}

- (IBAction)checkboxImageViewTapGesture:(UITapGestureRecognizer *)sender {
    if (!self.termsAccepted) {

        // Change checkbox image and enable next button
        self.checkboxImageView.image = CHECKBOX_CHECKED_IMAGE;
        self.nextButton.enabled = YES;
        self.nextButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
        self.termsAccepted = YES;
    } else {

        // Change checkbox image and disable next button
        self.checkboxImageView.image = CHECKBOX_UNCHECKED_IMAGE;
        self.nextButton.enabled = NO;
        self.nextButton.layer.borderColor = DISABLED_BORDER_COLOR.CGColor;
        self.termsAccepted = NO;
    }
}

- (IBAction)termsAndConditionsTapGesture:(UITapGestureRecognizer *)sender {
    NSLog(@"terms and conditions");

    CLAgreementViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CLAgreementViewController"];
    modalViewController.transitioningDelegate = self;
    modalViewController.displayMode = CLAgreementControllerModeConditions;
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (IBAction)privacyPolicyTapGesture:(UITapGestureRecognizer *)sender {
    NSLog(@"privacy policy");

    CLAgreementViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CLAgreementViewController"];
    modalViewController.transitioningDelegate = self;
    modalViewController.displayMode = CLAgreementControllerModePrivacy;
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:modalViewController animated:YES completion:nil];
}

#pragma mark - Network request methods

- (void)signUpUser {
    CLUser *user = [CLUser user];

    // Register new user
    NSLog(@"user: %@", [CLUser user]);

    // Show activity indicator
    [CLActivityIndicator showInView:self.navigationController.view title:NSLocalizedString(@"Registering", nil) animated:YES];

    if (!self.isSignInWithFacebook && !self.isSignInWithLinkedIn) {

        // Register user
        [CLUser registerUser:user successBlock:^(id data) {

            NSLog(@"success: %@", data);

            // Update user's access token
            if ([data isKindOfClass:[NSDictionary class]] && data[USER_REST_PARAMATER_ACCESS_TOKEN] &&
                    [data[USER_REST_PARAMATER_ACCESS_TOKEN] isKindOfClass:[NSString class]] &&
                    data[USER_REST_PARAMATER_ACCESS_TOKEN] != [NSNull null]) {
                [[CLUser user] setAccessToken:data[USER_REST_PARAMATER_ACCESS_TOKEN]];
                [CLUser user].userId = data[USER_REST_PARAMATER_USER_ID];
            }

            // Hide activity indicator
            [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{

                // Show success indicator
//                [CLActivityIndicator showSuccessInView:self.navigationController.view
//                                                 title:NSLocalizedString(@"Success", nil)
//                                              animated:YES
//                                           forInterval:ACTIVITY_INDICATOR_NOTIFICATION_PERIOD_SHORT
//                                            completion:
//                                                    ^{
//                                                        // Segue to the welcome screen
//                                                        [self performSegueWithIdentifier:@"SegueToWelcome" sender:self];
//                                                    }];
                
                [CLTextBoxView showWithTitle:@"Success!" message:@"You have successfully signed up."];
                [self performSegueWithIdentifier:@"SegueToWelcome" sender:self];
            }];

        }       failureBlock:^(id data, NSError *error) {

            NSLog(@"%@", error.userInfo[@"com.alamofire.serialization.response.error.data"]);
            NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];

            // Hide activity indicator
            [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{

                // Get error message
                NSString *errorMessage = [error localizedDescription];

                if (data && data[@"error_code"] && [data[@"error_code"] isKindOfClass:[NSNumber class]]) {
                    switch ([data[@"error_code"] intValue]) {
                        case kCLUserAPIErrorUserAlreadyExists:
                            errorMessage = NSLocalizedString(@"UserAlreadyExists", nil);
                            break;
                        case kCLUserAPIErrorEmailNotProvided:
                            errorMessage = NSLocalizedString(@"EmailNotProvided", nil);
                            break;
                        default:
                            errorMessage = NSLocalizedString(@"UnknownError", nil);
                            break;
                    }
                } else  if (errorData) {
                    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:errorData options:0 error:nil];
                    NSLog(@"jsondata %@", jsonData);
                    if (jsonData) {
                        errorMessage = jsonData[0][@"message"];
                    }
                }

                [CLTextBoxView showWithTitle:@"Error@" message:errorMessage];

                // Show failure indicator
            }];
        }];
    } else if (self.isSignInWithFacebook) {

        int timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);

        NSDictionary *parameters = @{
                USER_REST_PARAMATER_DEVICE_TYPE : @([CLUser user].device),
                USER_REST_PARAMETER_TIME_OFFSET : @(timezoneoffset)};

        [CLUser updateUserProfileWithParameters:parameters
                                completionBlock:^(id ok) {
                                    // Hide activity indicator
                                    [CLActivityIndicator hideForView:self.navigationController.view
                                                            animated:YES completion:^{

                                                // Show success indicator
//                                                [CLActivityIndicator showSuccessInView:self.navigationController.view
//                                                                                 title:NSLocalizedString(@"Success", nil)
//                                                                              animated:YES
//                                                                           forInterval:ACTIVITY_INDICATOR_NOTIFICATION_PERIOD_SHORT
//                                                                            completion:
//                                                                                    ^{
//                                                                                        // Segue to the welcome screen
//                                                                                        [self performSegueWithIdentifier:@"SegueToWelcome" sender:self];
//                                                                                    }];
                                                                [CLTextBoxView showWithTitle:@"Success!" message:@"You have successfully signed up."];
                                                                [self performSegueWithIdentifier:@"SegueToWelcome" sender:self];
                                            }];

                                } failureBlock:^(id data, NSError *error) {

                    // Hide activity indicator
                    [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{

                        // Get error message
                        NSString *errorMessage = [error localizedDescription];

                        if (data && data[@"error_code"] && [data[@"error_code"] isKindOfClass:[NSNumber class]]) {
                            switch ([data[@"error_code"] intValue]) {
                                case kCLUserAPIErrorUserAlreadyExists:
                                    errorMessage = NSLocalizedString(@"UserAlreadyExists", nil);
                                    break;
                                case kCLUserAPIErrorEmailNotProvided:
                                    errorMessage = NSLocalizedString(@"EmailNotProvided", nil);
                                    break;
                                default:
                                    errorMessage = NSLocalizedString(@"UnknownError", nil);
                                    break;
                            }
                        }

                        // Show failure indicator
//                        [CLActivityIndicator showFailureInView:self.navigationController.view
//                                                         title:errorMessage
//                                                      animated:YES
//                                                   forInterval:ACTIVITY_INDICATOR_NOTIFICATION_PERIOD_LONG
//                                                    completion:nil];
                        [CLTextBoxView showWithTitle:@"Error@" message:errorMessage];
                    }];
                }];


    } else if (self.isSignInWithLinkedIn) {

        int timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);

        NSDictionary *parameters = @{
                USER_REST_PARAMATER_DEVICE_TYPE : @([CLUser user].device),
                USER_REST_PARAMETER_TIME_OFFSET : @(timezoneoffset)};

        [CLUser updateUserProfileWithParameters:parameters
                                completionBlock:^(id ok) {
                                    // Hide activity indicator
                                    [CLActivityIndicator hideForView:self.navigationController.view
                                                            animated:YES
                                                          completion:^{

                                                              // Show success indicator
//                                                              [CLActivityIndicator showSuccessInView:self.navigationController.view
//                                                                                               title:NSLocalizedString(@"Success", nil)
//                                                                                            animated:YES
//                                                                                         forInterval:ACTIVITY_INDICATOR_NOTIFICATION_PERIOD_SHORT
//                                                                                          completion:
//                                                                                                  ^{
//                                                                                                      // Segue to the welcome screen
//                                                                                                      [self performSegueWithIdentifier:@"SegueToWelcome" sender:self];
//                                                                                                  }];
                                                              [CLTextBoxView showWithTitle:@"Success!" message:@"You have successfully signed up."];
                                                              [self performSegueWithIdentifier:@"SegueToWelcome" sender:self];
                                                          }];

                                } failureBlock:^(id data, NSError *error) {

                    // Hide activity indicator
                    [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{

                        // Get error message
                        NSString *errorMessage = [error localizedDescription];

                        if (data && data[@"error_code"] && [data[@"error_code"] isKindOfClass:[NSNumber class]]) {
                            switch ([data[@"error_code"] intValue]) {
                                case kCLUserAPIErrorUserAlreadyExists:
                                    errorMessage = NSLocalizedString(@"UserAlreadyExists", nil);
                                    break;
                                case kCLUserAPIErrorEmailNotProvided:
                                    errorMessage = NSLocalizedString(@"EmailNotProvided", nil);
                                    break;
                                default:
                                    errorMessage = NSLocalizedString(@"UnknownError", nil);
                                    break;
                            }
                        }

                        // Show failure indicator
//                        [CLActivityIndicator showFailureInView:self.navigationController.view
//                                                         title:errorMessage
//                                                      animated:YES
//                                                   forInterval:ACTIVITY_INDICATOR_NOTIFICATION_PERIOD_LONG
//                                                    completion:nil];
                        [CLTextBoxView showWithTitle:@"Error@" message:errorMessage];
                    }];
                }];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return self.presentAnimationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.dismissAnimationController;
}

@end
