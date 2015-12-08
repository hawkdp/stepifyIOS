//
//  CLDeviceViewController.m
//  UPMC
//
//  Created by Alexey Titov on 30.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLDeviceViewController.h"
#import "CLUser.h"
#import "CLProfilePicturePicker.h"
#import "CLConfirmDeviceViewController.h"

#define ENABLED_COLOR [[UIColor whiteColor] colorWithAlphaComponent:1.0]
#define DISABLED_COLOR [[UIColor whiteColor] colorWithAlphaComponent:0.2]
#define ENABLED_BORDER_COLOR [UIColor colorWithRed:186.0/255.0 green:191.0/255.0 blue:16.0/255.0 alpha:1.0]
#define DISABLED_BORDER_COLOR [UIColor colorWithRed:186.0/255.0 green:191.0/255.0 blue:16.0/255.0 alpha:0.4]
#define BACKGROUND_ACTIVE_COLOR [UIColor colorWithRed:0.0/255.0 green:145.0/255.0 blue:179.0/255.0 alpha:0.2]
#define BACKGROUND_INACTIVE_COLOR [UIColor whiteColor]

@interface CLDeviceViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;

@property (weak, nonatomic) IBOutlet UIView *fitbitView;
@property (weak, nonatomic) IBOutlet UIView *jawboneView;
@property (weak, nonatomic) IBOutlet UIView *healthView;


@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;

@end

@implementation CLDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.navigationController
                                                                            action:@selector(popViewControllerAnimated:)];
    
    self.previousButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
    self.previousButton.layer.borderWidth = 1.0;
    self.previousButton.layer.cornerRadius = 18.0;
    
    self.nextStepButton.layer.borderWidth = 1.0;
    self.nextStepButton.layer.cornerRadius = 18.0;
    [self.nextStepButton setTitleColor:ENABLED_COLOR forState:UIControlStateNormal];
    [self.nextStepButton setTitleColor:DISABLED_COLOR forState:UIControlStateDisabled];
    self.nextStepButton.enabled = NO;
    self.nextStepButton.layer.borderColor = DISABLED_BORDER_COLOR.CGColor;
    
    switch ([CLUser user].device)
    {
        case kCLUserDeviceFitbit:
            self.fitbitView.backgroundColor = BACKGROUND_ACTIVE_COLOR;
            self.nextStepButton.enabled = YES;
            self.nextStepButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
            break;
            
        case kCLUserDeviceJawbone:
            self.jawboneView.backgroundColor = BACKGROUND_ACTIVE_COLOR;
            self.nextStepButton.enabled = YES;
            self.nextStepButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
            break;
            
        case kCLUserDeviceHealthKit:
            self.healthView.backgroundColor = BACKGROUND_ACTIVE_COLOR;
            self.nextStepButton.enabled = YES;
            self.nextStepButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
            break;
            
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([CLUser user].profilePicture)
    {
        self.profilePhotoImageView.image = [CLUser user].profilePicture;
    }
}

#pragma mark - IBActions

- (IBAction)profilePictureTapGesture:(UITapGestureRecognizer *)sender
{
    [[CLProfilePicturePicker sharedInstance] pickProfilePictureInViewController:self
                                                               showDeleteOption:[CLUser user].profilePicture != nil
                                                                     completion:^(UIImage *image, BOOL deleted) {
        if (deleted)
        {
            self.profilePhotoImageView.image = nil;
            [CLUser user].profilePicture = nil;
        }
        else
        {
            self.profilePhotoImageView.image = image;
            [CLUser user].profilePicture = image;
        }
    }];
}

- (IBAction)fitbitTap:(UITapGestureRecognizer *)sender
{
    [CLUser user].device = kCLUserDeviceFitbit;
    
    self.fitbitView.backgroundColor = BACKGROUND_ACTIVE_COLOR;
    self.jawboneView.backgroundColor = BACKGROUND_INACTIVE_COLOR;
    self.healthView.backgroundColor = BACKGROUND_INACTIVE_COLOR;
    
    self.nextStepButton.enabled = YES;
    self.nextStepButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
}

- (IBAction)jawboneTap:(UITapGestureRecognizer *)sender
{
    [CLUser user].device = kCLUserDeviceJawbone;
    
    self.jawboneView.backgroundColor = BACKGROUND_ACTIVE_COLOR;
    self.fitbitView.backgroundColor = BACKGROUND_INACTIVE_COLOR;
    self.healthView.backgroundColor = BACKGROUND_INACTIVE_COLOR;
    
    self.nextStepButton.enabled = YES;
    self.nextStepButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
}

- (IBAction)healthTap:(UITapGestureRecognizer *)sender
{
    [CLUser user].device = kCLUserDeviceHealthKit;
    
    self.healthView.backgroundColor = BACKGROUND_ACTIVE_COLOR;
    self.fitbitView.backgroundColor = BACKGROUND_INACTIVE_COLOR;
    self.jawboneView.backgroundColor = BACKGROUND_INACTIVE_COLOR;
    
    self.nextStepButton.enabled = YES;
    self.nextStepButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
}

- (IBAction)previousButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextStepButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"SegueToConfirmDevice" sender:self];
}

#pragma mark - Storyboard navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToConfirmDevice"])
    {
        
        CLConfirmDeviceViewController *destinationVC = segue.destinationViewController;
        if ([CLUser user].facebookID)
        {
            destinationVC.isSignInWithFacebook = YES;
        }
        if ([CLUser user].linkedInID)
        {
            destinationVC.isSignInWithLinkedIn = YES;
        }
    }
}

@end
