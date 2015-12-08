//
//  CLLoginToStepsViewController.m
//  NSBE
//

#import <MessageUI/MessageUI.h>
#import "CLLoginToStepsViewController.h"
#import "CLUser+API.h"
#import "Utils.h"
#import "CLTextBoxView.h"

#define DISABLED_COLOR [UIColor colorWithRed:216.0/255.0 green:228.0/255.0 blue:255.0/255.0 alpha:0.2]
#define ENABLED_COLOR [UIColor colorWithRed:216.0/255.0 green:228.0/255.0 blue:255.0/255.0 alpha:1.0]

#define BORDER_ENABLED_COLOR [UIColor colorWithRed:0.0/255.0 green:145.0/255.0 blue:179.0/255.0 alpha:1.0]
#define BORDER_DISABLED_COLOR [UIColor colorWithRed:0.0/255.0 green:145.0/255.0 blue:179.0/255.0 alpha:0.2]
#define TEXT_ENABLED_COLOR [UIColor colorWithRed:100.0/255.0 green:103.0/255.0 blue:105.0/255.0 alpha:1.0]
#define TEXT_DISABLED_COLOR [UIColor colorWithRed:100.0/255.0 green:103.0/255.0 blue:105.0/255.0 alpha:0.4]

@interface CLLoginToStepsViewController ()

@property(nonatomic, weak) IBOutlet UITextField *emailField;
@property(nonatomic, weak) IBOutlet UITextField *passwordField;
@property(nonatomic, weak) IBOutlet UIButton *logInButton;
@property(nonatomic, weak) IBOutlet UIButton *forgotButton;

@property(nonatomic, weak) UITextField *activeField;
@property(nonatomic, assign) BOOL isValidEmail;
@property(nonatomic, assign) BOOL isPasswordEntered;
@property(nonatomic, assign) BOOL isLoginPerforming;

@property(nonatomic, weak) IBOutlet UIView *videoSubview;

@end

@implementation CLLoginToStepsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isValidEmail = NO;
    self.isPasswordEntered = NO;
    self.isLoginPerforming = NO;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.navigationController
                                                                            action:@selector(popViewControllerAnimated:)];
    
    self.logInButton.layer.borderColor = BORDER_DISABLED_COLOR.CGColor;
    self.logInButton.layer.borderWidth = 1.0;
    self.logInButton.layer.cornerRadius = 18.0;
    [self.logInButton setTitleColor:TEXT_ENABLED_COLOR forState:UIControlStateNormal];
    [self.logInButton setTitleColor:TEXT_DISABLED_COLOR forState:UIControlStateDisabled];
    self.logInButton.enabled = NO;

    UIColor *placeholderTextColor = [UIColor colorWithRed:100.0/255.0 green:103.0/255.0 blue:105.0/255.0 alpha:0.4];
    [self.emailField setValue:placeholderTextColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordField setValue:placeholderTextColor forKeyPath:@"_placeholderLabel.textColor"];

    NSAttributedString *forgotTitle = [[NSAttributedString alloc] initWithString:@"Forgot your password?" attributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    [self.forgotButton setAttributedTitle:forgotTitle forState:UIControlStateNormal];
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

- (IBAction)loginButtonPressed:(id)sender {
    [self.activeField resignFirstResponder];
    if (!self.isLoginPerforming) {
        self.isLoginPerforming = YES;
        self.logInButton.enabled = NO;
        self.logInButton.layer.borderColor = BORDER_DISABLED_COLOR.CGColor;
        [CLUser signInWithEmail:self.emailField.text
                       password:self.passwordField.text
                   successBlock:^(id response) {
                       self.isLoginPerforming = NO;
                       if (self.isValidEmail && self.isPasswordEntered) {
                           self.logInButton.enabled = YES;
                           self.logInButton.layer.borderColor = BORDER_ENABLED_COLOR.CGColor;
                       }
                       else {
                           self.logInButton.enabled = NO;
                           self.logInButton.layer.borderColor = BORDER_DISABLED_COLOR.CGColor;
                       }
                       [CLUser user].email = self.emailField.text;

                       int timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);

                       NSDictionary *parameters = @{USER_REST_PARAMETER_TIME_OFFSET : @(timezoneoffset)};

                       [CLUser updateUserProfileWithParameters:parameters
                                               completionBlock:^(id responseObject) {
                                                   [self performSegueWithIdentifier:@"SegueToHome" sender:self];
                                               }
                                                  failureBlock:^(id failedReponse, NSError *error) {\
                                                      
                                                      NSLog(@"%@", error.userInfo[@"com.alamofire.serialization.response.error.data"]);
                                                      NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                                                      NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:errorData options:0 error:nil];
                                                      NSLog(@"%@", jsonDict);
                                                      
                                                      NSLog(@"Failed %s", __PRETTY_FUNCTION__);
                                                  }];
                   }
                   failureBlock:^(id fail, NSError *error) {
                       
                       NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];

                       NSString *errorMessage = [error localizedDescription];
                       
                       if (fail && fail[@"error_code"] && [fail[@"error_code"] isKindOfClass:[NSNumber class]]) {
                           switch ([fail[@"error_code"] intValue]) {
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
                           errorMessage = jsonData[0][@"message"];
                       }
                       
                       [CLTextBoxView showWithTitle:nil message:errorMessage];

                       self.isLoginPerforming = NO;
                       if (self.isValidEmail && self.isPasswordEntered) {
                           self.logInButton.enabled = YES;
                           self.logInButton.layer.borderColor = BORDER_ENABLED_COLOR.CGColor;
                       }
                       else {
                           self.logInButton.enabled = NO;
                           self.logInButton.layer.borderColor = BORDER_DISABLED_COLOR.CGColor;
                       }
                   }];
    }
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.activeField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField; {
    self.activeField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    }
    else {
        [self loginButtonPressed:self];
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (textField == self.emailField) {
        if ([Utils isValidEmail:current]) {
            self.isValidEmail = YES;
        }
        else {
            self.isValidEmail = NO;
        }
    }
    else {
        if (![current isEqualToString:@""]) {
            self.isPasswordEntered = YES;
        }
        else {
            self.isPasswordEntered = NO;
        }
    }

    if (self.isValidEmail && self.isPasswordEntered && !self.isLoginPerforming) {
        self.logInButton.enabled = YES;
        self.logInButton.layer.borderColor = BORDER_ENABLED_COLOR.CGColor;
    }
    else {
        self.logInButton.enabled = NO;
        self.logInButton.layer.borderColor = BORDER_DISABLED_COLOR.CGColor;
    }

    textField.text = current;

    return NO;
}

@end
