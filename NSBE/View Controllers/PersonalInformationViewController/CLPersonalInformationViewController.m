//
//  CLPersonalInformationViewController.m
//  NSBE
//
//  Created by Alexey Titov on 23.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLPersonalInformationViewController.h"
#import "CLGenderModalViewController.h"
#import "CLBirthdateModalViewController.h"
#import "CLHeightModalViewController.h"
#import "CLWeightModalViewController.h"
#import "CLPresentAnimationController.h"
#import "CLDismissAnimationController.h"
#import "Constants.h"
#import "CLUser.h"
#import "CLProfilePicturePicker.h"

#define ENABLED_COLOR [[UIColor whiteColor] colorWithAlphaComponent:1.0]
#define DISABLED_COLOR [[UIColor whiteColor] colorWithAlphaComponent:0.2]
#define ENABLED_BORDER_COLOR [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:1.0]
#define DISABLED_BORDER_COLOR [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:0.4]

@interface CLPersonalInformationViewController () <CLGenderModalViewControllerDelegate, CLHeightModalViewControllerDelegate, CLWeightModalViewControllerDelegate, CLBirthdateModalViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;

@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ageImageView;
@property (weak, nonatomic) IBOutlet UIImageView *heightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *weightImageView;

@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;

@property (nonatomic, assign) BOOL isGenderSelected;
@property (nonatomic, assign) BOOL isAgeSelected;
@property (nonatomic, assign) BOOL isHeightSelected;
@property (nonatomic, assign) BOOL isWeightSelected;

@property (nonatomic, strong) CLPresentAnimationController *presentAnimationController;
@property (nonatomic, strong) CLDismissAnimationController *dismissAnimationController;

@end

@implementation CLPersonalInformationViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _presentAnimationController = [CLPresentAnimationController new];
        _dismissAnimationController = [CLDismissAnimationController new];
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    return self;
}

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
    
    CLUser *user = [CLUser user];
    
    if (user.gender)
    {
        [self setGenderImage];
        self.isGenderSelected = YES;
    }
    
    if (user.age)
    {
        self.ageImageView.hidden = YES;
        self.ageLabel.text = [user.age stringValue];
        self.isAgeSelected = YES;
    }
    
    if (user.heightFeet && user.heightInches)
    {
        self.heightImageView.hidden = YES;
        self.heightLabel.text = [NSString stringWithFormat:@"%td%@%td%@", [user.heightFeet integerValue], HEIGHT_PICKER_FEET_SUFFIX,
                                 [user.heightInches integerValue], HEIGHT_PICKER_INCHES_SUFFIX];
        self.isHeightSelected = YES;
    }
    
    if (user.weight)
    {
        self.weightImageView.hidden = YES;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:user.weight];
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:self.weightLabel.font.fontName size:self.weightLabel.font.pointSize * WEIGHT_PICKER_LBS_SUFFIX_FONT_RATIO]
                                 range:NSMakeRange(user.weight.length - [WEIGHT_PICKER_LBS_SUFFIX length], [WEIGHT_PICKER_LBS_SUFFIX length])];
        self.weightLabel.attributedText = attributedString;
        
        self.isWeightSelected = YES;
    }
    
    [self checkForInfoCompleteness];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([CLUser user].profilePicture)
    {
        self.profilePhotoImageView.image = [CLUser user].profilePicture;
    }
}

#pragma mark - Helpers

- (void)setGenderImage
{
    if ([[CLUser user].gender isEqualToString:GENDER_PICKER_MALE_NAME])
    {
        self.genderImageView.image = [UIImage imageNamed:@"signupst2_male"];
    }
    if ([[CLUser user].gender isEqualToString:GENDER_PICKER_FEMALE_NAME])
    {
        self.genderImageView.image = [UIImage imageNamed:@"signupst2_female"];
    }
}

- (void)checkForInfoCompleteness
{
    if (self.isGenderSelected && self.isAgeSelected && self.isHeightSelected && self.isWeightSelected)
    {
        self.nextStepButton.enabled = YES;
        self.nextStepButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
    }
    else
    {
        self.nextStepButton.enabled = NO;
        self.nextStepButton.layer.borderColor = DISABLED_BORDER_COLOR.CGColor;
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

- (IBAction)previousButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextStepButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"SegueToSelectDevice" sender:self];
}

#pragma mark - Tap gestures

- (IBAction)selectGenderTap:(UITapGestureRecognizer *)sender
{
    CLGenderModalViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GenderModalID"];
    modalViewController.delegate = self;
    modalViewController.transitioningDelegate = self;
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if ([[CLUser user].gender isEqualToString:GENDER_PICKER_FEMALE_NAME])
    {
        modalViewController.isFemaleOptionSelected = YES;
    }
    
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (IBAction)selectAgeTap:(UITapGestureRecognizer *)sender
{
    CLBirthdateModalViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BirthdateModalID"];
    modalViewController.delegate = self;
    modalViewController.transitioningDelegate = self;
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (self.isAgeSelected)
    {
        modalViewController.age = [CLUser user].age;
        modalViewController.birthdate = [CLUser user].birthdate;
    }
    
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (IBAction)selectHeightTap:(UITapGestureRecognizer *)sender
{
    CLHeightModalViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HeightModalID"];
    modalViewController.delegate = self;
    modalViewController.transitioningDelegate = self;
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (self.isHeightSelected)
    {
        modalViewController.heightFeet = [CLUser user].heightFeet;
        modalViewController.heightInches = [CLUser user].heightInches;
    }
    
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (IBAction)selectWeightTap:(UITapGestureRecognizer *)sender
{
    CLWeightModalViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WeightModalID"];
    modalViewController.delegate = self;
    modalViewController.transitioningDelegate = self;
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (self.isWeightSelected)
    {
        modalViewController.weight = [CLUser user].weight;
    }
    
    [self presentViewController:modalViewController animated:YES completion:nil];
}

#pragma mark - CLGenderModalViewControllerDelegate

- (void)genderModalViewController:(CLGenderModalViewController *)genderModalViewController didSelectMaleOption:(BOOL)maleOption
{
    [CLUser user].gender = maleOption ? GENDER_PICKER_MALE_NAME : GENDER_PICKER_FEMALE_NAME;
    [self setGenderImage];
    self.isGenderSelected = YES;
    [self checkForInfoCompleteness];
}

#pragma mark - CLBirthdateModalViewControllerDelegate

- (void)birthdateModalViewController:(CLBirthdateModalViewController *)birthdateModalViewController didSelectAge:(NSNumber *)age birthdate:(NSDate *)birthdate
{
    [CLUser user].age = age;
    [CLUser user].birthdate = birthdate;
    self.ageImageView.hidden = YES;
    self.ageLabel.text = [age stringValue];
    self.isAgeSelected = YES;
    [self checkForInfoCompleteness];
}

#pragma mark - CLHeightModalViewControllerDelegate

- (void)heightModalViewController:(CLHeightModalViewController *)heightModalViewController didSelectHeightFeet:(NSNumber *)heightFeet heightInches:(NSNumber *)heightInches
{
    [CLUser user].heightFeet = heightFeet;
    [CLUser user].heightInches = heightInches;
    self.heightImageView.hidden = YES;
    self.heightLabel.text = [NSString stringWithFormat:@"%td%@%td%@", [heightFeet integerValue], HEIGHT_PICKER_FEET_SUFFIX, [heightInches integerValue], HEIGHT_PICKER_INCHES_SUFFIX];
    self.isHeightSelected = YES;
    [self checkForInfoCompleteness];
}

#pragma mark - CLWeightModalViewControllerDelegate

- (void)weightModalViewController:(CLWeightModalViewController *)weightModalViewController didSelectWeight:(NSString *)weight
{
    [CLUser user].weight = weight;
    self.weightImageView.hidden = YES;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:weight];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:self.weightLabel.font.fontName size:self.weightLabel.font.pointSize * WEIGHT_PICKER_LBS_SUFFIX_FONT_RATIO]
                             range:NSMakeRange(weight.length - [WEIGHT_PICKER_LBS_SUFFIX length], [WEIGHT_PICKER_LBS_SUFFIX length])];
    self.weightLabel.attributedText = attributedString;
    self.isWeightSelected = YES;
    [self checkForInfoCompleteness];
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
