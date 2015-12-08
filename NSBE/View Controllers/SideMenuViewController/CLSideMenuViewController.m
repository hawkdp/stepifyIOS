//
//  CLSideMenuViewController.m
//  NSBE
//

#import <MessageUI/MessageUI.h>
#import "CLSideMenuViewController.h"
#import "UIImage+BlurAndDarken.h"
#import "CLUser.h"
#import "UIImage+RoundedCorner.h"
#import "CLTextBoxView.h"
#import "CLUser+API.h"

@interface CLSideMenuViewController ()
@property(weak, nonatomic) IBOutlet UIView *rightContainerView;
@property(weak, nonatomic) IBOutlet UIView *leftContainerView;
@property(weak, nonatomic) IBOutlet UIView *menuItemsView;
@property(weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property(weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userHealthDeviceImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logOutImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gameRulesImageView;
@property (weak, nonatomic) IBOutlet UIImageView *editProfileImageView;
@property (strong, nonatomic)  CAGradientLayer *rightGradient;
@property (strong, nonatomic) CAGradientLayer *leftGradient;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contactUsImageView;

@end

@implementation CLSideMenuViewController

#pragma mark - View controller's lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    ///
    self.logOutImageView.layer.cornerRadius = 22.0f;
    self.logOutImageView.layer.borderWidth = 1.0f;
    self.logOutImageView.layer.borderColor = [UIColor colorWithRed:0.03f green:0.35f blue:0.45f alpha:0.7f].CGColor;
    ///
    self.gameRulesImageView.layer.cornerRadius = 22.0f;
    self.gameRulesImageView.layer.borderWidth = 1.0f;
    self.gameRulesImageView.layer.borderColor = [UIColor colorWithRed:0.03f green:0.35f blue:0.45f alpha:0.7f].CGColor;
    ///
    self.editProfileImageView.layer.cornerRadius = 22.0f;
    self.editProfileImageView.layer.borderWidth = 1.0f;
    self.editProfileImageView.layer.borderColor = [UIColor colorWithRed:0.03f green:0.35f blue:0.45f alpha:0.7f].CGColor;
    ///
    ///
    self.contactUsImageView.layer.cornerRadius = 22.0f;
    self.contactUsImageView.layer.borderWidth = 1.0f;
    self.contactUsImageView.layer.borderColor = [UIColor colorWithRed:0.03f green:0.35f blue:0.45f alpha:0.7f].CGColor;
    ///
    //gradient for right view
    self.rightGradient = [CAGradientLayer layer];

    self.rightGradient.frame = self.rightContainerView.bounds;

    UIColor *firefly = [UIColor colorWithRed:0.07f green:0.15f blue:0.17f alpha:1.0f];
    UIColor *godGray = [UIColor colorWithRed:0.02f green:0.04f blue:0.05f alpha:1.0f];
    self.rightGradient.colors = @[(id) [firefly CGColor], (id) [godGray CGColor]];

    [self.rightGradient setStartPoint:CGPointMake(0.5, 0)];
    [self.rightGradient setEndPoint:CGPointMake(0, 0.5)];

    [self.rightContainerView.layer insertSublayer:self.rightGradient atIndex:0];
    //
    //gradient for left view
    self.leftGradient = [CAGradientLayer layer];

    self.leftGradient.frame = self.leftContainerView.bounds;

    UIColor *hippieBlue = [UIColor colorWithRed:0.36f green:0.60f blue:0.69f alpha:0.0f];
    UIColor *hippieBlue1 = [UIColor colorWithRed:0.35f green:0.58f blue:0.67f alpha:0.0f];
    UIColor *hippieBlue2 = [UIColor colorWithRed:0.36f green:0.60f blue:0.69f alpha:0.1f];
    UIColor *bigStone1 = [UIColor colorWithRed:10.f/255.f green:26.f/255.f blue:40.f/255.f alpha:0.5f];
    UIColor *cyprus1 = [UIColor colorWithRed:0.02f green:0.21f blue:0.26f alpha:.95f];
    UIColor *cyprus = [UIColor colorWithRed:0.02f green:0.21f blue:0.26f alpha:1.f];
    UIColor *bigStone = [UIColor colorWithRed:10.f/255.f green:26.f/255.f blue:40.f/255.f alpha:1.0f];
    self.leftGradient.colors = @[(id) [hippieBlue CGColor],
            (id) [hippieBlue1 CGColor],
            (id) [hippieBlue2 CGColor],
            (id) [cyprus1 CGColor],
            (id) [cyprus CGColor],
            (id) [cyprus CGColor],
            (id) [cyprus CGColor],
            (id) [bigStone CGColor],
            (id) [bigStone CGColor],
            (id) [bigStone CGColor]];

    [self.leftGradient setStartPoint:CGPointMake(0, 0)];
    [self.leftGradient setEndPoint:CGPointMake(0, 1)];

    [self.menuItemsView.layer insertSublayer:self.leftGradient atIndex:0];

    //
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.leftGradient.frame = self.leftContainerView.bounds;
    self.rightGradient.frame = self.rightContainerView.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [CLUser user].firstName ?: @"", [CLUser user].lastName?:@""];
    self.userEmailLabel.text = [NSString stringWithFormat:@"%@", [CLUser user].email ?: @""];
    __weak typeof(self) weakSelf = self;
    self.userHealthDeviceImageView.image = [CLUser getDeviceIconImage:[CLUser user].device];
    if ([CLUser user].profilePicture) {
        self.profilePhotoImageView.layer.cornerRadius = 33.0f;
        self.profilePhotoImageView.clipsToBounds = YES;
//        self.profilePhotoImageView.layer.masksToBounds = YES;

        self.profilePhotoImageView.image = [CLUser user].profilePicture;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            UIImage *blurredBackgroundImage = [[CLUser user].profilePicture darkened:0.0f
                                                                     andBlurredImage:2.0f];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                weakSelf.backgroundImageView.image = blurredBackgroundImage;
            });
        });
    } else {
        [[CLUser user] fetchProfilePictureWithCompletionBlock:^(UIImage *profilePic, NSError *error) {
            if (profilePic) {
                weakSelf.profilePhotoImageView.layer.cornerRadius = 33.0f;
//                weakSelf.profilePhotoImageView.clipsToBounds = YES;
//                weakSelf.profilePhotoImageView.layer.masksToBounds = YES;
                weakSelf.profilePhotoImageView.image = profilePic;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    UIImage *blurredBackgroundImage = [weakSelf.profilePhotoImageView.image darkened:0.0f
                                                                                     andBlurredImage:2.0f];
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        weakSelf.backgroundImageView.image = blurredBackgroundImage;
                    });
                });
            }
        }];
    }
}

#pragma mark - Gesture recognizers and actions
- (IBAction)tapOnContactUsButton:(UIButton *)sender {
    // Email Subject
//    NSString *emailTitle = @"Test Email";
    // Email Content
    //    NSString *messageBody = @"iOS programming is so fun!";
    // To address
    NSArray *toRecipents = @[@"joshua.hinderberger@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
//    [mc setSubject:emailTitle];
    //    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
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


- (IBAction)closeAction:(UIButton *)sender {
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

- (IBAction)homeViewTapGesture:(UITapGestureRecognizer *)sender {
    // Call delegate method
    if (self.delegate) {
        [self.delegate menuViewController:self homeMenuPressed:sender];
    }
}

- (IBAction)challengeDetailsViewTapGesture:(UITapGestureRecognizer *)sender {
    // Call delegate method
    if (self.delegate) {
        [self.delegate menuViewController:self challengeDetailsMenuPressed:self];
    }
}

- (IBAction)syncingStepsViewTapGesture:(UITapGestureRecognizer *)sender {
    // Call delegate method
    if (self.delegate) {
        [self.delegate menuViewController:self syncingStepsMenuPressed:sender];
    }
}

- (IBAction)prizesViewTapGesture:(UITapGestureRecognizer *)sender {
    // Call delegate method
    if (self.delegate) {
        [self.delegate menuViewController:self prizesMenuPressed:sender];
    }
}

- (IBAction)cardioLegendViewTapGesture:(UITapGestureRecognizer *)sender {
    // Call delegate method
    if (self.delegate) {
        [self.delegate menuViewController:self cardioLegendMenuPressed:sender];
    }
}

- (IBAction)tapOnSignOutButton:(UIButton *)sender {
    [CLTextBoxView showWithTitle:@"Success." message:@"You have loged out."];
    [CLUser removeDeviceToken];
    
    if (self.delegate) {
        [self.delegate menuViewController:self signOutButtonPressed:sender];
    }
}


- (IBAction)gameRulesPressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate menuViewController:self gameRules:sender];
    }
}

- (IBAction)editProfilePressed:(UIButton *)sender
{
    if (self.delegate)
    {
        [self.delegate menuViewController:self editProfile:sender];
    }
}


#pragma mark - View controller's memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    NSLog(@"memory warning received");
}

@end
