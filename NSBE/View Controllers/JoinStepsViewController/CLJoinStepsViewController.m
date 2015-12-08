//
//  CLJoinStepsViewController.m
//  NSBE
//

#import <MessageUI/MessageUI.h>
#import "CLJoinStepsViewController.h"
#import "CLLoginToStepsViewController.h"
#import "CLActivityIndicator.h"
#import "CLUser+API.h"
#import "CLFacebookHandler.h"
#import "CLLinkedinHelper.h"
#import "Stylesheet.h"
#import "Constants.h"
#import "UIAlertView+Blocks.h"
#import "UIImage+Resize.h"
#import "CLTextBoxView.h"

@interface CLJoinStepsViewController ()

@property(nonatomic, weak) IBOutlet UIButton *logInButton;
@property(nonatomic, weak) IBOutlet UIButton *signUpButton;
@property(nonatomic, weak) IBOutlet UIButton *forgotButton;

@property(nonatomic, weak) IBOutlet UIView *videoSubview;

@end

@implementation CLJoinStepsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.navigationController
                                                                            action:@selector(popViewControllerAnimated:)];

    self.logInButton.layer.borderColor = [UIColor colorWithRed:186.0/255.0 green:191.0/255.0 blue:16.0/255.0 alpha:1.0].CGColor;
    self.logInButton.layer.borderWidth = 1.0;
    self.logInButton.layer.cornerRadius = self.logInButton.frame.size.height / 2.0;

    self.signUpButton.layer.borderColor = [UIColor colorWithRed:186.0/255.0 green:191.0/255.0 blue:16.0/255.0 alpha:1.0].CGColor;
    self.signUpButton.layer.borderWidth = 1.0;
    self.signUpButton.layer.cornerRadius = self.signUpButton.frame.size.height / 2.0;

    NSAttributedString *forgotTitle = [[NSAttributedString alloc] initWithString:@"Forgot your password?" attributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    [self.forgotButton setAttributedTitle:forgotTitle forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[CLUser user] clearUserInfo];
}

#pragma mark - IBActions

- (IBAction)tapOnForgotPassword:(UIButton *)sender {
    // Email Subject
    NSString *emailTitle = @"Stepify Info";
    // Email Content
//    NSString *messageBody = @"iOS programming is so fun!";
    // To address
    NSArray *toRecipents = @[@"joshua.hinderberger@gmail.com"];

    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    
    if ([MFMailComposeViewController canSendMail]) {
        [mc setSubject:emailTitle];
        //    [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    } else {
        NSLog(@"can't send Email!");
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
        NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
        NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
        NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
        NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }

    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)loginWithFacebook:(id)sender {
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
            user.profilePictureURL = [USER_REST_API_FACEBOOK_PROFILE_PICTURE_URL
                                      stringByReplacingOccurrencesOfString:USER_REST_API_PARAMETER_ID
                                      withString:user.facebookID];
            user.profilePicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user.profilePictureURL]]];
            //			user.birthdate = [Utils facebookStringDateToDate:data[kCLFacebookParameterBirthday]];
            //			user.age = @([Utils getYearCountFromDate:user.birthdate]);
            
            // Create a block that will be executed if profile picture download request will succeed or not

                [CLUser signInUserWithFacebookAndSuccessBlock:^(id fbResponse) {
                            [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{
                                // Show success indicator
                                [CLActivityIndicator showSuccessInView:self.navigationController.view
                                                                 title:NSLocalizedString(@"Success", nil)
                                                              animated:YES
                                                           forInterval:ACTIVITY_INDICATOR_NOTIFICATION_PERIOD_SHORT
                                                            completion:
                                                                    ^{
                                                                        user.userId = fbResponse[USER_REST_PARAMATER_USER_ID];
                                                                        if (![fbResponse[@"already_registered"] boolValue])
                                                                        {
                                                                            user.profilePictureURL = [USER_REST_API_FACEBOOK_PROFILE_PICTURE_URL
                                                                                                      stringByReplacingOccurrencesOfString:USER_REST_API_PARAMETER_ID
                                                                                                      withString:user.facebookID];
                                                                            
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
                                                                                
                                                                                
                                                                            }                failureBlock:^(id data, NSError *error) {
                                                                                NSLog(@"get user profile picture failed!");
                                                                            }];
                                                                        }
                                                                        
                                                                        if ([fbResponse[@"already_registered"] boolValue] && [fbResponse[@"usr_device_id"] integerValue] != 0) {
                                                                            int timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);
                                                                            NSDictionary *parameters = @{USER_REST_PARAMETER_TIME_OFFSET : @(timezoneoffset)};
                                                                            [CLUser updateUserProfileWithParameters:parameters
                                                                                                    completionBlock:^(id ok) {
                                                                                                        [self performSegueWithIdentifier:@"SegueToHome"
                                                                                                                                  sender:self];
                                                                                                    }
                                                                                                       failureBlock:^(id failed, NSError *error) {
                                                                                                           NSLog(@"Failed %s", __PRETTY_FUNCTION__);
                                                                                                       }];
                                                                        }
                                                                        else {
                                                                            [self performSegueWithIdentifier:@"SegueToSelectDevice" sender:self];
                                                                        }
                                                                    }];
                            }];
                        }
                                                 failureBlock:^(id failData, NSError *error) {
                                                     NSLog(@"FACEBOOK ERROR");
                                                 }];



            
        }                                       failure:^(id data, NSError *error) {
            NSLog(@"an error occurred while retrieving user info: %@", [error localizedDescription]);

            // Hide activity indicator
            [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{

                // Show failure error message
                [CLTextBoxView showWithTitle:nil message:NSLocalizedString(@"FacebookLoginError", nil)];
            }];
        }];
    }                                 failure:^(NSError *error) {
        NSLog(@"login failed!");

        // Hide activity indicator
        [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{

            // Show failure error message
            [CLTextBoxView showWithTitle:nil message:NSLocalizedString(@"FacebookAccessNotGranted", nil)];

        }];
    }];
}

- (IBAction)loginWithLinkedIn:(id)sender {
    [[CLLinkedinHelper sharedHelper] loginWithCompletionBlock:^(id response, NSError *error) {
        if (!error && response) {
            [CLActivityIndicator showInView:self.navigationController.view
                                      title:NSLocalizedString(@"SigningIn", nil)
                                   animated:YES];

            CLUser *user = [CLUser user];
            user.firstName = response[@"firstName"];
            user.lastName = response[@"lastName"];
            user.linkedInID = response[@"id"];
            user.profilePicture = nil;
            user.profilePictureURL = nil;
            
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
                                                                        int timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);
                                                                        NSDictionary *parameters = @{USER_REST_PARAMETER_TIME_OFFSET : @(timezoneoffset)};
                                                                        [CLUser updateUserProfileWithParameters:parameters
                                                                                                completionBlock:^(id ok)  {
                                                                                    [self performSegueWithIdentifier:@"SegueToHome"
                                                                                                              sender:self];
                                                                                }
                                                                                                        failureBlock:^(id failed, NSError *error) {
                                                                                                            NSLog(@"Failed %s", __PRETTY_FUNCTION__);
                                                                                                        }];
                                                                    }
                                                                    else {
                                                                        [self performSegueWithIdentifier:@"SegueToSelectDevice" sender:self];
                                                                    }
                                                                }];
                        }];
                    }
                                             failureBlock:^(id errorData, NSError *error) {
                                                 NSLog(@"");
                                                 [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{
                                                 }];
                                                 if (!errorData && !error) {
//                                                     [self.navigationController popViewControllerAnimated:YES];
                                                 }
                                             }];

        } else if (error) {
            [CLTextBoxView showWithTitle:@"" message:error ? [error localizedDescription] : @"The Internet connection appears to be offline."];
        }
    }];
}

#pragma mark - Unwind Segue

- (IBAction)unwindFromHome:(UIStoryboardSegue *)sender {

}

@end
