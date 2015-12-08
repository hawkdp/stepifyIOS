//
//  CLSignInViewController.m
//  NSBE
//

#import "CLSignInViewController.h"
#import "CLUser+API.h"
#import "UIAlertView+Blocks.h"
#import "CLActivityIndicator.h"
#import "CLFacebookHandler.h"
#import "Constants.h"
#import "UIImage+Resize.h"
#import "CLLinkedinHelper.h"
#import "Stylesheet.h"
#import "CLTextBoxView.h"

@interface CLSignInViewController ()
@property(weak, nonatomic) IBOutlet UITextField *emailTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation CLSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)tapOnSignInButton:(UIButton *)sender {
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;

    [CLUser signInWithEmail:email
                   password:password
               successBlock:^(id response) {
                   UIViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewControllerStoryboardID"];
                   [self.navigationController setViewControllers:@[homeVC]
                                                        animated:YES];

               }
               failureBlock:^(id fail, NSError *error) {
               }];
}

- (IBAction)tapOnSignUpWithFacebook:(UIButton *)sender {

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

            // Create a block that will be executed if profile picture download request will succeed or not
            void (^signInUser)() = ^void() {
                [CLUser signInUserWithFacebookAndSuccessBlock:^(id data) {

                            [CLUser user].device = (CLUserDevice) [data[USER_REST_PARAMATER_DEVICE_TYPE] integerValue];
                            [CLActivityIndicator hideForView:self.navigationController.view
                                                    animated:YES
                                                  completion:^{
                                                      [self performSegueWithIdentifier:@"SegueToHome" sender:self];
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

            // Show failure error message
            [CLTextBoxView showWithTitle:nil message:NSLocalizedString(@"FacebookAccessNotGranted", nil)];
        }];
    }];
}

- (IBAction)tapOnSignUpWithLinkedIn:(UIButton *)sender {

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
//            self.isSignInWithLinkedIn = YES;

            [CLUser signInUserWithLinkedInAndSuccessBlock:^(id data) {
                        [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{
                            // Show success indicator
                            [CLActivityIndicator showSuccessInView:self.navigationController.view
                                                             title:NSLocalizedString(@"Success", nil)
                                                          animated:YES
                                                       forInterval:ACTIVITY_INDICATOR_NOTIFICATION_PERIOD_SHORT
                                                        completion:
                                                                ^{
                                                                    // Segue to the welcome screen
                                                                    [self performSegueWithIdentifier:@"SegueToHome" sender:self];
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

@end
