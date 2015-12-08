//
//  CLSelectDeviceViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/30/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLSelectDeviceViewController.h"
#import "CLProfilePicturePicker.h"
#import "CLColorStateButton.h"
#import "UIAlertView+Blocks.h"
#import "Stylesheet.h"
#import "Constants.h"
#import "CLConfirmDeviceViewController.h"
#import "CLTextBoxView.h"

@interface CLSelectDeviceViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *profilePictureImageView;
@property (nonatomic, weak) IBOutlet CLColorStateButton *backButton;

@end

@implementation CLSelectDeviceViewController

#pragma mark - View controller's lifecycle methods

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// Set control properties
	[self.backButton setBackgroundColor:COLOR_STATE_BUTTON_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
	[self.backButton setBackgroundColor:COLOR_STATE_BUTTON_HIGHLIGHTED_COLOR forState:UIControlStateDisabled];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Set profile picture image
	CLUser *user = [CLUser user];
	if (user.profilePicture) {
		[self.profilePictureImageView setImage:user.profilePicture];
	}
}

#pragma mark - Gesture recognizers and actions

- (IBAction)backAction:(UIButton *)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)profilePictureTapGesture:(UITapGestureRecognizer *)sender
{
	[[CLProfilePicturePicker sharedInstance] pickProfilePictureInViewController:self
															   showDeleteOption:[CLUser user].profilePicture != nil
																	 completion:
	 ^(UIImage *image, BOOL deleted) {
		 
		 if (deleted) {
			 
			 // Delete current profile picture
			 self.profilePictureImageView.image = [UIImage imageNamed:@"AddPhoto"];
			 [CLUser user].profilePicture = nil;
		 } else {
			 
			 // Assign selected profile picture
			 self.profilePictureImageView.image = image;
			 [CLUser user].profilePicture = image;
		 }
	 }];
}

- (IBAction)fitbitImageViewTapGesture:(UITapGestureRecognizer *)sender
{
	NSLog(@"fitbit selected");
	
	// Set user's device
	[CLUser user].device = kCLUserDeviceFitbit;
	
	// Segue to the confirm device screen
	[self performSegueWithIdentifier:@"SegueToConfirmDevice" sender:self];
}

- (IBAction)jawboneImageViewTapGesture:(UITapGestureRecognizer *)sender
{
	NSLog(@"jawbone selected");
	
	// Set user's device
	[CLUser user].device = kCLUserDeviceJawbone;
	
	// Segue to the confirm device screen
	[self performSegueWithIdentifier:@"SegueToConfirmDevice" sender:self];
}

- (IBAction)healthKitImageViewTapGesture:(UITapGestureRecognizer *)sender
{
	NSLog(@"healthkit selected");
	
	// Set user's device
	[CLUser user].device = kCLUserDeviceHealthKit;
	
	// Segue to the confirm device screen
	[self performSegueWithIdentifier:@"SegueToConfirmDevice" sender:self];
}

- (IBAction)noDeviceImageViewTapGesture:(UITapGestureRecognizer *)sender
{
	NSLog(@"no device selected");
	
	// Set user's device
	[CLUser user].device = kCLUserDeviceNoDevice;

    // Show warning message - you can't participate to the challenge without any device
	[UIAlertView showWithTitle:NSLocalizedString(@"NoDeviceTitle", nil)
					   message:NSLocalizedString(@"NoDeviceMessage", nil)
			 cancelButtonTitle:NSLocalizedString(@"Ok", nil)
			 otherButtonTitles:nil
					  tapBlock:nil];
}

#pragma mark - Storyboard navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToConfirmDevice"]) {

        CLConfirmDeviceViewController *destinationVC = segue.destinationViewController;
        if ([CLUser user].facebookID) {
            destinationVC.isSignInWithFacebook = YES;
        }
        if ([CLUser user].linkedInID) {
            destinationVC.isSignInWithLinkedIn = YES;
        }

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
