//
//  CLEditProfileScreensViewController.m
//  UPMC
//
//  Created by Alexey Titov on 28.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLEditProfileScreensViewController.h"
#import "CLUser.h"
#import "CLUser+API.h"
#import "CLActivityIndicator.h"
#import "Stylesheet.h"
#import "Constants.h"
#import "Utils.h"
#import "CLGenderModalViewController.h"
#import "CLBirthdateModalViewController.h"
#import "CLHeightModalViewController.h"
#import "CLWeightModalViewController.h"
#import "CLPresentAnimationController.h"
#import "CLDismissAnimationController.h"
#import "CLProfilePicturePicker.h"
#import "CLTextBoxView.h"

#define BORDER_ENABLED_COLOR [UIColor colorWithRed:0.0/255.0 green:145.0/255.0 blue:179.0/255.0 alpha:1.0]
#define BORDER_DISABLED_COLOR [UIColor colorWithRed:0.0/255.0 green:145.0/255.0 blue:179.0/255.0 alpha:0.2]
#define TEXT_ENABLED_COLOR [UIColor colorWithRed:100.0/255.0 green:103.0/255.0 blue:105.0/255.0 alpha:1.0]
#define TEXT_DISABLED_COLOR [UIColor colorWithRed:100.0/255.0 green:103.0/255.0 blue:105.0/255.0 alpha:0.4]

@interface CLEditProfileScreensViewController () <UITextFieldDelegate, CLGenderModalViewControllerDelegate, CLHeightModalViewControllerDelegate, CLWeightModalViewControllerDelegate, CLBirthdateModalViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactInformationHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *emailImageView;
@property (weak, nonatomic) IBOutlet UIView *emailLineView;

@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ageImageView;
@property (weak, nonatomic) IBOutlet UIImageView *heightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *weightImageView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *enterPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *oldPasswordImageView;
@property (weak, nonatomic) IBOutlet UIImageView *enterPasswordImageView;
@property (weak, nonatomic) IBOutlet UIImageView *repeatPasswordImageView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (nonatomic, weak) UITextField *activeField;

@property (nonatomic, assign) BOOL isValidOld;
@property (nonatomic, assign) BOOL isValidNew;
@property (nonatomic, assign) BOOL isValidRepeat;

@property (nonatomic, strong) CLPresentAnimationController *presentAnimationController;
@property (nonatomic, strong) CLDismissAnimationController *dismissAnimationController;

@property (nonatomic, strong) NSString *backing;
@property (nonatomic, strong) NSString *oldPassword;
@property (nonatomic, strong) NSString *realPassword;
@property (nonatomic, strong) NSString *repeatPassword;
@property (nonatomic, strong) NSString *userGender;
@property (nonatomic, strong) NSDate *userBirthdate;
@property (nonatomic, strong) NSNumber *userAge;
@property (nonatomic, strong) NSNumber *userHeightFeet;
@property (nonatomic, strong) NSNumber *userHeightInches;
@property (nonatomic, strong) NSString *userWeight;

@end

@implementation CLEditProfileScreensViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _presentAnimationController = [CLPresentAnimationController new];
        _dismissAnimationController = [CLDismissAnimationController new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLUser *user = [CLUser user];
    
    if (user.facebookID || user.linkedInID)
    {
        self.contactInformationHeightConstraint.constant -= 52;
        self.emailImageView.hidden = YES;
        self.emailLineView.hidden = YES;
        self.emailTextField.hidden = YES;
        self.oldPasswordTextField.enabled = NO;
        self.enterPasswordTextField.enabled = NO;
        self.repeatPasswordTextField.enabled = NO;
    }
    
    if (user.profilePicture)
    {
        self.profilePhotoImageView.image = user.profilePicture;
    }
    
    if (user.firstName)
    {
//        self.nameTextField.text = [NSString stringWithFormat:@"%@%@%@", user.firstName, user.lastName ? @" " : @"", user.lastName];
        self.nameTextField.text = [NSString stringWithFormat:@"%@ %@", user.firstName ?: @"", user.lastName?:@""];
    }
    
    if (user.email)
    {
        self.emailTextField.text = user.email;
    }
    
    if (user.gender)
    {
        self.userGender = user.gender;
        [self setGenderImage:user.gender];
    }
    
    if (user.age)
    {
        self.userAge = user.age;
        self.userBirthdate = user.birthdate;
        self.ageImageView.hidden = YES;
        self.ageLabel.text = [user.age stringValue];
    }
    
    if (user.heightFeet && user.heightInches)
    {
        self.userHeightFeet = user.heightFeet;
        self.userHeightInches = user.heightInches;
        self.heightImageView.hidden = YES;
        self.heightLabel.text = [NSString stringWithFormat:@"%td%@%td%@", [user.heightFeet integerValue], HEIGHT_PICKER_FEET_SUFFIX,
                                 [user.heightInches integerValue], HEIGHT_PICKER_INCHES_SUFFIX];
    }
    
    if (user.weight)
    {
        self.userWeight = user.weight;
        
        self.weightImageView.hidden = YES;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:user.weight];
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:self.weightLabel.font.fontName size:self.weightLabel.font.pointSize * WEIGHT_PICKER_LBS_SUFFIX_FONT_RATIO]
                                 range:NSMakeRange(user.weight.length - [WEIGHT_PICKER_LBS_SUFFIX length], [WEIGHT_PICKER_LBS_SUFFIX length])];
        self.weightLabel.attributedText = attributedString;
    }
    
    UIColor *placeholderTextColor = [UIColor colorWithRed:100.0/255.0 green:103.0/255.0 blue:105.0/255.0 alpha:0.4];
    [self.oldPasswordTextField setValue:placeholderTextColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.enterPasswordTextField setValue:placeholderTextColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.repeatPasswordTextField setValue:placeholderTextColor forKeyPath:@"_placeholderLabel.textColor"];
    
    self.confirmButton.layer.borderColor = BORDER_DISABLED_COLOR.CGColor;
    self.confirmButton.layer.borderWidth = 1.0;
    self.confirmButton.layer.cornerRadius = 18.0;
    [self.confirmButton setTitleColor:TEXT_ENABLED_COLOR forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:TEXT_DISABLED_COLOR forState:UIControlStateDisabled];
    self.confirmButton.enabled = NO;
}

#pragma mark - Getters

- (NSString *)oldPassword
{
    if (!_oldPassword)
    {
        _oldPassword = [[NSString alloc] init];
    }
    return _oldPassword;
}

- (NSString *)realPassword
{
    if (!_realPassword)
    {
        _realPassword = [[NSString alloc] init];
    }
    return _realPassword;
}

- (NSString *)repeatPassword
{
    if (!_repeatPassword)
    {
        _repeatPassword = [[NSString alloc] init];
    }
    return _repeatPassword;
}

#pragma mark - Helpers

- (void)setGenderImage:(NSString *)gender
{
    if ([gender isEqualToString:GENDER_PICKER_MALE_NAME])
    {
        self.genderImageView.image = [UIImage imageNamed:@"signupst2_male"];
    }
    if ([gender isEqualToString:GENDER_PICKER_FEMALE_NAME])
    {
        self.genderImageView.image = [UIImage imageNamed:@"signupst2_female"];
    }
}

#pragma mark - IBActions

- (IBAction)profilePictureTapGesture:(UITapGestureRecognizer *)sender
{
    [[CLProfilePicturePicker sharedInstance] pickProfilePictureInViewController:self
                                                               showDeleteOption:self.profilePhotoImageView.image != nil
                                                                     completion:^(UIImage *image, BOOL deleted) {
        if (deleted)
        {
            self.profilePhotoImageView.image = nil;
            [self.delegate editProfileScreensViewController:self didChangeProfilePicture:nil];
        }
        else
        {
            self.profilePhotoImageView.image = image;
            [self.delegate editProfileScreensViewController:self didChangeProfilePicture:image];
        }
    }];
}

- (IBAction)selectGenderTap:(UITapGestureRecognizer *)sender
{
    CLGenderModalViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GenderModalID"];
    modalViewController.delegate = self;
    modalViewController.transitioningDelegate = self;
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if ([self.userGender isEqualToString:GENDER_PICKER_FEMALE_NAME])
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
    
    if (self.userAge)
    {
        modalViewController.age = self.userAge;
        modalViewController.birthdate = self.userBirthdate;
    }
    
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (IBAction)selectHeightTap:(UITapGestureRecognizer *)sender
{
    CLHeightModalViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HeightModalID"];
    modalViewController.delegate = self;
    modalViewController.transitioningDelegate = self;
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (self.userHeightFeet && self.userHeightInches)
    {
        modalViewController.heightFeet = self.userHeightFeet;
        modalViewController.heightInches = self.userHeightInches;
    }
    
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (IBAction)selectWeightTap:(UITapGestureRecognizer *)sender
{
    CLWeightModalViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WeightModalID"];
    modalViewController.delegate = self;
    modalViewController.transitioningDelegate = self;
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (self.userWeight)
    {
        modalViewController.weight = self.userWeight;
    }
    
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.activeField resignFirstResponder];
}

- (IBAction)confirmButtonPressed:(id)sender
{
    [CLActivityIndicator showInView:self.navigationController.view title:NSLocalizedString(@"Changing password", nil) animated:YES];
    
    [CLUser changePasswordOld:self.oldPassword
                          new:self.realPassword
              completionBlock:^(id data) {
                  NSLog(@"success: %@", data);
                  [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{
                      [CLTextBoxView showWithTitle:@"Success!" message:@"You have successfukky changed your password."];
                  }];
              }
                 failureBlock:^(id data, NSError *error) {
                     NSLog(@"error: %@", [error localizedDescription]);
                     [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{
                         NSString *errorMessage = [error localizedDescription];
                         [CLTextBoxView showWithTitle:@"Error" message:errorMessage];
                     }];
                 }];
}

#pragma mark - CLGenderModalViewControllerDelegate

- (void)genderModalViewController:(CLGenderModalViewController *)genderModalViewController didSelectMaleOption:(BOOL)maleOption
{
    NSString *gender = maleOption ? GENDER_PICKER_MALE_NAME : GENDER_PICKER_FEMALE_NAME;
    [self setGenderImage:gender];
    self.userGender = gender;
    [self.delegate editProfileScreensViewController:self didChangeGender:gender];
//    self.isGenderSelected = YES;
}

#pragma mark - CLBirthdateModalViewControllerDelegate

- (void)birthdateModalViewController:(CLBirthdateModalViewController *)birthdateModalViewController didSelectAge:(NSNumber *)age birthdate:(NSDate *)birthdate
{
    self.userAge = age;
    self.userBirthdate = birthdate;
    self.ageImageView.hidden = YES;
    self.ageLabel.text = [age stringValue];
    [self.delegate editProfileScreensViewController:self didChangeAge:age birthdate:birthdate];
//    self.isAgeSelected = YES;
}

#pragma mark - CLHeightModalViewControllerDelegate

- (void)heightModalViewController:(CLHeightModalViewController *)heightModalViewController didSelectHeightFeet:(NSNumber *)heightFeet heightInches:(NSNumber *)heightInches
{
    self.userHeightFeet = heightFeet;
    self.userHeightInches = heightInches;
    self.heightImageView.hidden = YES;
    self.heightLabel.text = [NSString stringWithFormat:@"%td%@%td%@", [heightFeet integerValue], HEIGHT_PICKER_FEET_SUFFIX, [heightInches integerValue], HEIGHT_PICKER_INCHES_SUFFIX];
    [self.delegate editProfileScreensViewController:self didChangeHeightFeet:heightFeet inches:heightInches];
//    self.isHeightSelected = YES;
}

#pragma mark - CLWeightModalViewControllerDelegate

- (void)weightModalViewController:(CLWeightModalViewController *)weightModalViewController didSelectWeight:(NSString *)weight
{
    self.userWeight = weight;
    self.weightImageView.hidden = YES;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:weight];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:self.weightLabel.font.fontName size:self.weightLabel.font.pointSize * WEIGHT_PICKER_LBS_SUFFIX_FONT_RATIO]
                             range:NSMakeRange(weight.length - [WEIGHT_PICKER_LBS_SUFFIX length], [WEIGHT_PICKER_LBS_SUFFIX length])];
    self.weightLabel.attributedText = attributedString;
    [self.delegate editProfileScreensViewController:self didChangeWeight:weight];
//    self.isWeightSelected = YES;
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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    [self.delegate editProfileScreensViewController:self activateTextField:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.nameTextField)
    {
        NSArray *nameItems = [[self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@" "];
        if (nameItems.count > 1)
        {
            NSString *firstName = [nameItems firstObject];
            NSMutableString *lastName = [NSMutableString string];
            for (int i = 1; i < nameItems.count; i++) {
                [lastName appendString:nameItems[i]];
                [lastName appendString:i != nameItems.count - 1 ? @" " : @""];
            }
            [self.delegate editProfileScreensViewController:self didChangeFirstName:firstName lastName:lastName];
        }
        else
        {
            if (![nameItems[0] isEqualToString:@""])
            {
                [self.delegate editProfileScreensViewController:self didChangeFirstName:nameItems[0] lastName:@""];
            }
            else
            {
                [CLTextBoxView showWithTitle:@"Error" message:@"Please enter your first name and last name"];
            }
        }
    }
    
    if (textField == self.emailTextField)
    {
        if ([Utils isValidEmail:self.emailTextField.text])
        {
            [self.delegate editProfileScreensViewController:self didChangeEmail:self.emailTextField.text];
        }
        else
        {
            [CLTextBoxView showWithTitle:@"Error" message:@"You entered incorrect email"];
        }
    }
    
    if (textField == self.oldPasswordTextField)
    {
        if (self.oldPasswordTextField.text.length > 0)
        {
            self.oldPasswordImageView.image = [UIImage imageNamed:@"text_check"];
            self.isValidOld = YES;
        }
        else
        {
            self.oldPasswordImageView.image = [UIImage imageNamed:@"text_clear"];
            self.isValidOld = NO;
        }
    }
    
    if (textField == self.enterPasswordTextField)
    {
        if (self.enterPasswordTextField.text.length > 0)
        {
            self.enterPasswordImageView.image = [UIImage imageNamed:@"text_check"];
            self.isValidNew = YES;
        }
        else
        {
            self.enterPasswordImageView.image = [UIImage imageNamed:@"text_clear"];
            self.isValidNew = NO;
        }
    }
    
    if (textField == self.repeatPasswordTextField)
    {
//        if ([self.repeatPasswordTextField.text isEqualToString:self.enterPasswordTextField.text])
        if ([self.repeatPassword isEqualToString:self.realPassword])
        {
            self.repeatPasswordImageView.image = [UIImage imageNamed:@"text_check"];
            self.isValidRepeat = YES;
        }
        else
        {
            self.repeatPasswordImageView.image = [UIImage imageNamed:@"text_clear"];
            self.isValidRepeat = NO;
        }
    }
    
    if (textField == self.oldPasswordTextField || textField == self.enterPasswordTextField || textField == self.repeatPasswordTextField)
    {
        if (self.isValidOld && self.isValidNew && self.isValidRepeat)
        {
            self.confirmButton.enabled = YES;
            self.confirmButton.layer.borderColor = BORDER_ENABLED_COLOR.CGColor;
        }
        else
        {
            self.confirmButton.enabled = NO;
            self.confirmButton.layer.borderColor = BORDER_DISABLED_COLOR.CGColor;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.activeField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.oldPasswordTextField)
    {
        self.oldPassword = [[self.oldPassword stringByAppendingString:string] stringByReplacingOccurrencesOfString:@"*" withString:@""];
        
        if ([string isEqualToString:@""])
        {
            if (self.oldPassword.length > 0)
            {
                self.oldPassword = [self.oldPassword substringToIndex:[self.oldPassword length] - 1];
            }
            else
            {
                self.oldPassword = @"";
            }
        }
        
        self.backing = textField.text;
        if (self.backing == nil) self.backing = @"";
        static BOOL pasting = false;
        
        if (!pasting)
        {
            self.backing = [self.backing stringByReplacingCharactersInRange:range withString:string];
            NSLog(@"backing: %@", self.backing);
            if ([string length] == 0) return YES; // early bail out when just deleting chars
            
            NSString *sec = @"";
            for (int i = 0; i < [string length]; i++) sec = [sec stringByAppendingFormat:@"*"];
            
            pasting = true;
            [[UIPasteboard generalPasteboard] setString:sec];
            [textField paste:self];
            
            return NO;
        }
        else
        {
            pasting = false;
            return YES;
        }
    }
    
    if (textField == self.enterPasswordTextField)
    {
        self.realPassword = [[self.realPassword stringByAppendingString:string] stringByReplacingOccurrencesOfString:@"*" withString:@""];
        
        if ([string isEqualToString:@""])
        {
            if (self.realPassword.length > 0)
            {
                self.realPassword = [self.realPassword substringToIndex:[self.realPassword length] - 1];
            }
            else
            {
                self.realPassword = @"";
            }
        }
        
        self.backing = textField.text;
        if (self.backing == nil) self.backing = @"";
        static BOOL pasting = false;
        
        if (!pasting)
        {
            self.backing = [self.backing stringByReplacingCharactersInRange:range withString:string];
            NSLog(@"backing: %@", self.backing);
            if ([string length] == 0) return YES; // early bail out when just deleting chars
            
            NSString *sec = @"";
            for (int i = 0; i < [string length]; i++) sec = [sec stringByAppendingFormat:@"*"];
            
            pasting = true;
            [[UIPasteboard generalPasteboard] setString:sec];
            [textField paste:self];
            
            return NO;
        }
        else
        {
            pasting = false;
            return YES;
        }
    }
    
    if (textField == self.repeatPasswordTextField)
    {
        self.repeatPassword = [[self.repeatPassword stringByAppendingString:string] stringByReplacingOccurrencesOfString:@"*" withString:@""];
        
        if ([string isEqualToString:@""])
        {
            if (self.repeatPassword.length > 0)
            {
                self.repeatPassword = [self.repeatPassword substringToIndex:[self.repeatPassword length] - 1];
            }
            else
            {
                self.repeatPassword = @"";
            }
        }
        
        self.backing = textField.text;
        if (self.backing == nil) self.backing = @"";
        static BOOL pasting = false;
        
        if (!pasting)
        {
            self.backing = [self.backing stringByReplacingCharactersInRange:range withString:string];
            NSLog(@"backing: %@", self.backing);
            if ([string length] == 0) return YES; // early bail out when just deleting chars
            
            NSString *sec = @"";
            for (int i = 0; i < [string length]; i++) sec = [sec stringByAppendingFormat:@"*"];
            
            pasting = true;
            [[UIPasteboard generalPasteboard] setString:sec];
            [textField paste:self];
            
            return NO;
        }
        else
        {
            pasting = false;
            return YES;
        }
    }
    
    return YES;
}

@end
