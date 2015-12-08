//
//  CLRegisterViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLRegisterViewController.h"
#import "CLProfilePicturePicker.h"
#import "CLColorStateButton.h"
#import "UIAlertView+Blocks.h"
#import "Stylesheet.h"
#import "Constants.h"
#import "Utils.h"
#import "UIImage+RoundedCorner.h"
#import "CLTextBoxView.h"

#pragma mark Picker view tags

#define LIGHT_BLUE_COLOR [UIColor colorWithRed:118.0/255.0 green:177.0/255.0 blue:252.0/255.0 alpha:1.0]
#define DARK_BLUE_COLOR [UIColor colorWithRed:78.0/255.0 green:111.0/255.0 blue:193.0/255.0 alpha:1.0]
#define AVATAR_BORDER_COLOR [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.1]
#define ENABLED_COLOR [[UIColor whiteColor] colorWithAlphaComponent:1.0]
#define DISABLED_COLOR [[UIColor whiteColor] colorWithAlphaComponent:0.2]
#define ENABLED_BORDER_COLOR [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:1.0]
#define DISABLED_BORDER_COLOR [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:0.4]

#define PICKER_VIEW_GENDER_TAG 100
#define PICKER_VIEW_BIRTHDATE_TAG 101
#define PICKER_VIEW_HEIGHT_TAG 102
#define PICKER_VIEW_WEIGHT_TAG 103

typedef NS_ENUM(NSUInteger, CLRegistrationFieldType) {
    CLRegistrationFieldTypeName = 1,
    CLRegistrationFieldTypeEmail = 2,
    CLRegistrationFieldTypePassword = 3,
    CLRegistrationFieldTypeRepeatPassword = 4
};

@interface CLRegisterViewController ()
@property(nonatomic, weak) IBOutlet UITextField *nameTextField;
@property(nonatomic, weak) IBOutlet UITextField *emailTextField;
@property(weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property(nonatomic, weak) IBOutlet UITextField *passwordRepeatTextField;
@property(weak, nonatomic) IBOutlet UIView *avatarContainerView;
@property(weak, nonatomic) IBOutlet UIScrollView *registerScrollView;
@property(weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property(weak, nonatomic) IBOutlet UIImageView *nameValidationImage;
@property(weak, nonatomic) IBOutlet UIImageView *emailValidationImage;
@property(weak, nonatomic) IBOutlet UIImageView *passwordValidationImage;
@property(weak, nonatomic) IBOutlet UIImageView *repeatPasswordValidationImage;
@property(weak, nonatomic) IBOutlet UIButton *nextStepButton;


@property(nonatomic, weak) IBOutlet UITextField *genderTextField;
@property(nonatomic, weak) IBOutlet UITextField *ageTextField;
@property(nonatomic, weak) IBOutlet UITextField *heightTextField;
@property(nonatomic, weak) IBOutlet UITextField *weightTextField;
@property(nonatomic, weak) IBOutlet UIImageView *genderImageView;
@property(nonatomic, weak) IBOutlet UIImageView *ageImageView;
@property(nonatomic, weak) IBOutlet UIImageView *heightImageView;
@property(nonatomic, weak) IBOutlet UIImageView *weightImageView;
@property(nonatomic, weak) IBOutlet UIImageView *profilePictureImageView;
@property(nonatomic, weak) IBOutlet CLColorStateButton *nextButton;
@property(nonatomic, weak) IBOutlet CLColorStateButton *backButton;
@property(nonatomic, weak) IBOutlet CLColorStateButton *sigUpButton;

@property(nonatomic, strong) NSArray *dateYearsArray;
@property(nonatomic, strong) NSArray *dateMonthsArray;
@property(nonatomic, strong) NSArray *dateDaysArray;
@property(nonatomic, strong) NSArray *heightFeetArray;
@property(nonatomic, strong) NSArray *heightInchesArray;
@property(nonatomic, strong) NSArray *weightLbsArray;


@property(nonatomic, assign) BOOL isNameValid;
@property(nonatomic, assign) BOOL isEmailValid;
@property(nonatomic, assign) BOOL isPasswordValid;
@property(nonatomic, assign) BOOL isPasswordCopyValid;

@property(nonatomic, strong) NSString *backing;
@property(nonatomic, strong) NSString *realPassword;
@property(nonatomic, strong) NSString *realPasswordСopy;

@property (nonatomic, weak) UITextField *activeField;

@end

@implementation CLRegisterViewController

#pragma mark - View controller's lifecycle methods

- (NSString *)realPassword {
    if (!_realPassword) {
        _realPassword = [[NSString alloc] init];
    }
    return _realPassword;
}

- (NSString *)realPasswordСopy {
    if (!_realPasswordСopy) {
        _realPasswordСopy = [[NSString alloc] init];
    }
    return _realPasswordСopy;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customize];

    // Set control properties
    [self.backButton setBackgroundColor:COLOR_STATE_BUTTON_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    [self.nextButton setBackgroundColor:COLOR_STATE_BUTTON_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    [self.nextButton setBackgroundColor:COLOR_STATE_BUTTON_DISABLED_COLOR forState:UIControlStateDisabled];
    [self.nextButton setEnabled:NO];
    [self.sigUpButton setBackgroundColor:COLOR_STATE_BUTTON_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    [self.sigUpButton setBackgroundColor:COLOR_STATE_BUTTON_DISABLED_COLOR forState:UIControlStateDisabled];
    [self.sigUpButton setEnabled:NO];
    
    UIColor *placeholderTextColor = [UIColor colorWithRed:100.0/255.0 green:103.0/255.0 blue:105.0/255.0 alpha:0.4];
    [self.nameTextField setValue:placeholderTextColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.emailTextField setValue:placeholderTextColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordTextField setValue:placeholderTextColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordRepeatTextField setValue:placeholderTextColor forKeyPath:@"_placeholderLabel.textColor"];

    // Set controls depending on registration step
    if (self.type == CLRegisterViewControllerTypeStep1) {

        CLUser *user = [CLUser user];
//        NSLog(@"CLRegisterViewControllerTypeStep1");
//
//        // Fill data for fields that we have, first is name
//        if (user.firstName || user.lastName) {
//            self.nameTextField.text = [NSString stringWithFormat:@"%@%@%@",
//                                                                 user.firstName,
//                                                                 user.firstName && user.lastName ? @" " : @"",
//                                                                 user.lastName];
//        }
//
//        // Second is user's email
//        if (user.email) {
//            self.emailTextField.text = user.email;
//
//            // Disable email text field if this is registration with Facebook
//            if (self.facebookRegistration) {
//                self.emailTextField.enabled = NO;
//                self.emailTextField.alpha = TEXT_FIELD_DISABLED_ALPHA;
//            }
//        }

        // Third is phone number
        if (user.phoneNumber) {
//			self.phoneNumberTextField.text = user.phoneNumber;
        }

        // Set text fields placeholder color
//		self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.nameTextField.placeholder
//                                                                                   attributes:@{NSForegroundColorAttributeName : self.nameTextField.textColor}];
//		self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailTextField.placeholder
//                                                                                    attributes:@{NSForegroundColorAttributeName : self.emailTextField.textColor}];
//		self.phoneNumberTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.phoneNumberTextField.placeholder
//                                                                                          attributes:@{NSForegroundColorAttributeName : self.phoneNumberTextField.textColor}];
//        self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder
//                                                                                       attributes:@{NSForegroundColorAttributeName : self.passwordTextField.textColor}];
        // Mark that text fields have been changed
        [self textFieldDidChange:nil];

    } else if (self.type == CLRegisterViewControllerTypeStep2) {

        CLUser *user = [CLUser user];
        NSLog(@"CLRegisterViewControllerTypeStep2");

        // Set years, months and days for birthdate picker view
        self.dateYearsArray = [[[Utils getPastYears:DATE_PICKER_PAST_YEAR_COUNT includeCurrentYear:YES]
                reverseObjectEnumerator] allObjects];
        self.dateMonthsArray = [Utils getAllMonths];
        self.dateDaysArray = [Utils getAllDaysInMonth:[Utils getCurrentMonth] year:[Utils getCurrentYear]];

        // Set height and weight arrays
        self.heightFeetArray = HEIGHT_PICKER_FEET_ARRAY;
        self.heightInchesArray = HEIGHT_PICKER_INCHES_ARRAY;
        self.weightLbsArray = WEIGHT_PICKER_LBS_ARRAY;

        // Fill data for fields that we have, first is gender
        if (user.gender) {
            [self.genderTextField setEnabled:YES];

            // Update gender image view
            self.genderImageView.image = [UIImage imageNamed:
                    [user.gender caseInsensitiveCompare:GENDER_PICKER_MALE_NAME] == NSOrderedSame ?
                            GENDER_PICKER_MALE_IMAGE_PATH : GENDER_PICKER_FEMALE_IMAGE_PATH];
        }

        // Second is user's age
        if (user.age) {
            [self.ageTextField setEnabled:YES];
            [self.ageImageView setUserInteractionEnabled:NO];
            [self.ageImageView setHidden:YES];

            // Update aget text field
            self.ageTextField.text = [user.age stringValue];
        }

        // Third is height
        if (user.heightFeet && user.heightInches) {
            [self.heightTextField setEnabled:YES];
            [self.heightImageView setUserInteractionEnabled:NO];
            [self.heightImageView setHidden:YES];

            // Update height text field
            self.heightTextField.text = [NSString stringWithFormat:@"%td%@%td%@", [user.heightFeet integerValue],
                            HEIGHT_PICKER_FEET_SUFFIX, [user.heightInches integerValue],
                            HEIGHT_PICKER_INCHES_SUFFIX];
        }

        // Fourth is weight
        if (user.weight) {
            [self.weightTextField setEnabled:YES];
            [self.weightImageView setUserInteractionEnabled:NO];
            [self.weightImageView setHidden:YES];

            // Update weight text field
            self.weightTextField.text = user.weight;
        }

        // And fifth, test if all necessary fields are completed
        self.sigUpButton.enabled = user.gender && user.birthdate && user.age ? YES : NO;

        // Set picker views
        NSArray *pickerInputViews = @[self.genderTextField, self.ageTextField, self.heightTextField, self.weightTextField];
        NSArray *pickerInputTags = @[@(PICKER_VIEW_GENDER_TAG), @(PICKER_VIEW_BIRTHDATE_TAG), @(PICKER_VIEW_HEIGHT_TAG), @(PICKER_VIEW_WEIGHT_TAG)];

        for (int i = 0; i < pickerInputViews.count; i++) {
            UIPickerView *pickerView = [[UIPickerView alloc] init];
            [pickerView setDataSource:self];
            [pickerView setDelegate:self];
            [pickerView setShowsSelectionIndicator:YES];
            [pickerView setBackgroundColor:PICKER_VIEW_BACKGROUND_COLOR];
            [pickerView setTag:[pickerInputTags[i] intValue]];
            [pickerInputViews[i] setInputView:pickerView];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([CLUser user].profilePicture)
    {
        self.profilePictureImageView.image = [CLUser user].profilePicture;
    }
    
    [[UPPlatform sharedPlatform] endCurrentSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Update layout
    [self.view setNeedsLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
}

#pragma mark - Layout delegate methods

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // Set content offset position when keyboard appears on the screen
    switch (self.type) {
        case CLRegisterViewControllerTypeStep1: {
//			self.contentOffsetKeyboardVisible = CGPointMake(0.0f, self.phoneNumberTextField.superview.frame.origin.y +
//															self.phoneNumberTextField.superview.frame.size.height);
//            self.contentOffsetFromBottom = YES;
            break;
        }
        case CLRegisterViewControllerTypeStep2: {
            self.contentOffsetKeyboardVisible = CGPointMake(0.0f, self.sigUpButton.frame.origin.y +
                    self.sigUpButton.frame.size.height);
            self.contentOffsetFromBottom = YES;
            break;
        }
    }
}

#pragma mark - Gesture recognizers and actions

//- (IBAction)tapOnAvatarContainerView:(UITapGestureRecognizer *)sender {
//    [[CLProfilePicturePicker sharedInstance] pickProfilePictureInViewController:self
//                                                               showDeleteOption:[CLUser user].profilePicture != nil
//                                                                     completion:
//                                                                             ^(UIImage *image, BOOL deleted) {
//
//                                                                                 if (deleted) {
//
//                                                                                     // Delete current profile picture
//                                                                                     self.avatarContainerView.alpha = 0.5;
//                                                                                     self.avatarImageView.contentMode = UIViewContentModeCenter;
//                                                                                     self.avatarImageView.image = [UIImage imageNamed:@"camera"];
//                                                                                     [CLUser user].profilePicture = nil;
//                                                                                 } else {
//
//                                                                                     // Assign selected profile picture
//                                                                                     self.avatarContainerView.alpha = 1;
//                                                                                     self.avatarImageView.contentMode = UIViewContentModeScaleToFill;
//                                                                                     self.avatarImageView.image = [image roundedCornerImage:125 borderSize:0];
//
//                                                                                     [CLUser user].profilePicture = image;
//                                                                                 }
//                                                                             }];
//}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)profilePictureTapGesture:(UITapGestureRecognizer *)sender
{
    [[CLProfilePicturePicker sharedInstance] pickProfilePictureInViewController:self
                                                               showDeleteOption:[CLUser user].profilePicture != nil
                                                                     completion:^(UIImage *image, BOOL deleted) {
        if (deleted)
        {
            self.profilePictureImageView.image = nil;
            [CLUser user].profilePicture = nil;
        }
        else
        {
            self.profilePictureImageView.image = image;
            [CLUser user].profilePicture = image;
        }
    }];
}

- (IBAction)genderImageViewTapGesture:(UITapGestureRecognizer *)sender {
    [self.genderTextField setEnabled:YES];
    [self.genderTextField becomeFirstResponder];

    // Update gender image view
    self.genderImageView.image = [UIImage imageNamed:[((UIPickerView *) sender.view.inputView) selectedRowInComponent:0] == 0
            ? GENDER_PICKER_MALE_IMAGE_PATH : GENDER_PICKER_FEMALE_IMAGE_PATH];

    // Set selected default gender
    [CLUser user].gender = GENDER_PICKER_MALE_NAME;

    // Test if all the fields are completed
    self.sigUpButton.enabled = [CLUser user].gender && [CLUser user].birthdate && [CLUser user].age ? YES : NO;
}

- (IBAction)ageImageViewTapGesture:(UITapGestureRecognizer *)sender {
    [self.ageTextField setEnabled:YES];
    [self.ageTextField becomeFirstResponder];
    [sender.view setUserInteractionEnabled:NO];
    [sender.view setHidden:YES];

    // Set picker view default year, month and day to current date
    UIPickerView *pickerView = (UIPickerView *) self.ageTextField.inputView;
    NSInteger currentMonth = [Utils getCurrentMonth];
    NSInteger currentDay = [Utils getCurrentDay];

    [pickerView selectRow:currentMonth - 1 inComponent:DATE_PICKER_MONTH_POSITION animated:NO];
    [pickerView selectRow:currentDay - 1 inComponent:DATE_PICKER_DAY_POSITION animated:NO];
    [pickerView selectRow:self.dateYearsArray.count - 1 inComponent:DATE_PICKER_YEAR_POSITION animated:NO];

    // Set default birthdate and age
    [CLUser user].birthdate = [NSDate date];
    [CLUser user].age = @([Utils getYearCountFromDate:[CLUser user].birthdate]);

    // Update age text field
    self.ageTextField.text = [[[CLUser user] age] stringValue];

    // Test if all the fields are completed
    self.sigUpButton.enabled = [CLUser user].gender && [CLUser user].birthdate && [CLUser user].age ? YES : NO;
}

- (IBAction)heightImageViewTapGesture:(UITapGestureRecognizer *)sender {
    [self.heightTextField setEnabled:YES];
    [self.heightTextField becomeFirstResponder];

    // Set picker view default feet and inches
    UIPickerView *pickerView = (UIPickerView *) self.heightTextField.inputView;
    [pickerView selectRow:HEIGHT_PICKER_DEFAULT_FEET_INDEX inComponent:HEIGHT_PICKER_FEET_POSITION animated:NO];
    [pickerView selectRow:HEIGHT_PICKER_DEFAULT_INCHES_INDEX inComponent:HEIGHT_PICKER_INCHES_POSITION animated:NO];
}

- (IBAction)weightImageViewTapGesture:(UITapGestureRecognizer *)sender {
    [self.weightTextField setEnabled:YES];
    [self.weightTextField becomeFirstResponder];

    // Set picker view default pounds
    UIPickerView *pickerView = (UIPickerView *) self.weightTextField.inputView;
    [pickerView selectRow:WEIGHT_PICKER_DEFAULT_LBS_INDEX inComponent:0 animated:NO];
}

- (IBAction)nextRegistrationStepAction:(UIButton *)sender {
    // First, end editing
    [self.view endEditing:YES];

    // Second, test if all the fields are completed
//    if ([self.nameTextField.text length] == 0 ||
//            [self.emailTextField.text length] == 0) {
//        [UIAlertView showWithTitle:nil message:NSLocalizedString(@"CompleteAllFields", nil)
//                 cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil tapBlock:nil];
//        return;
//    }
//
//    // Third, check if the phone number has exactly 10 digits
////	if ([self.phoneNumberTextField.text length] != TEXT_FIELD_PHONE_NUMBER_CHARACTER_LIMIT) {
////		[UIAlertView showWithTitle:nil message:NSLocalizedString(@"CompletePhoneNumberDigits", nil)
////				 cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil tapBlock:nil];
////		return;
////	}
//
//    // Fourth, test email for validity
//    if (![Utils isValidEmail:self.emailTextField.text]) {
//        [UIAlertView showWithTitle:nil message:NSLocalizedString(@"InvalidEmail", nil)
//                 cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil tapBlock:nil];
//        return;
//    }
//
//    // Data is valid, fill user's details and segue to the next registration screen
    CLUser *user = [CLUser user];

    // First and last name
    NSArray *nameItems = [[self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
            componentsSeparatedByString:@" "];
    if (nameItems.count > 1) {

        // First name and last name
        user.firstName = [[nameItems subarrayWithRange:NSMakeRange(0, nameItems.count - 1)]
                componentsJoinedByString:@" "];
        user.lastName = nameItems.lastObject;
    } else {

        // First name only
        user.firstName = self.nameTextField.text;
        user.lastName = nil;
    }

    // Email
    user.email = self.emailTextField.text;
    // Password
    user.password = self.realPassword;
    // Phone number
//	user.phoneNumber = self.phoneNumberTextField.text;

    // Segue to the next registration screen
    [self performSegueWithIdentifier:@"SegueToPersonalInfo" sender:self];
}

- (IBAction)nextDeviceSelectionAction:(UIButton *)sender {
    CLUser *user = [CLUser user];

    // First, end editing
    [self.view endEditing:YES];

    // Second, test if all the fields are completed
    if (!user.gender || !user.birthdate || !user.age) {
        [CLTextBoxView showWithTitle:nil message:NSLocalizedString(@"CompleteAllFields", nil)];
        return;
    }

    // Input data is valid - segue to the select device screen
    [self performSegueWithIdentifier:@"SegueToSelectDevice" sender:self];
}

#pragma mark - Picker view data source methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    switch (pickerView.tag) {
        case PICKER_VIEW_GENDER_TAG: {
            // 1 columns for genders
            return 1;
        }
        case PICKER_VIEW_BIRTHDATE_TAG: {
            // 3 columns for birthdate - month, day and year
            return 3;
        }
        case PICKER_VIEW_HEIGHT_TAG: {
            // 2 columns for height - feet and inches
            return 2;
        }
        case PICKER_VIEW_WEIGHT_TAG: {
            // 1 columns for weight - pounds
            return 1;
        }
        default: {
            return 1;
        }
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case PICKER_VIEW_GENDER_TAG: {
            return 2;
        }
        case PICKER_VIEW_BIRTHDATE_TAG: {
            switch (component) {
                case DATE_PICKER_MONTH_POSITION: {
                    return self.dateMonthsArray.count;
                }
                case DATE_PICKER_DAY_POSITION: {
                    return self.dateDaysArray.count;
                }
                case DATE_PICKER_YEAR_POSITION: {
                    return self.dateYearsArray.count;
                }
            }
        }
        case PICKER_VIEW_HEIGHT_TAG: {
            switch (component) {
                case HEIGHT_PICKER_FEET_POSITION: {
                    return self.heightFeetArray.count;
                }
                case HEIGHT_PICKER_INCHES_POSITION: {
                    return self.heightInchesArray.count;
                }
            }
        }
        case PICKER_VIEW_WEIGHT_TAG: {
            return self.weightLbsArray.count;
        }
        default: {
            return 0;
        }
    }
}

#pragma mark - Picker view delegate methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return pickerView.tag == PICKER_VIEW_GENDER_TAG ? PICKER_VIEW_GENDER_ROW_HEIGHT : PICKER_VIEW_ROW_HEIGHT;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case PICKER_VIEW_BIRTHDATE_TAG: {
            switch (component) {
                case DATE_PICKER_MONTH_POSITION: {
                    return pickerView.frame.size.width * PICKER_VIEW_BIRTHDATE_MONTH_WIDTH_RATIO;
                }
                case DATE_PICKER_DAY_POSITION: {
                    return pickerView.frame.size.width * PICKER_VIEW_BIRTHDATE_DAY_WIDTH_RATIO;
                }
                case DATE_PICKER_YEAR_POSITION: {
                    return (pickerView.frame.size.width - (pickerView.frame.size.width *
                            PICKER_VIEW_BIRTHDATE_MONTH_WIDTH_RATIO) -
                            (pickerView.frame.size.width * PICKER_VIEW_BIRTHDATE_DAY_WIDTH_RATIO));
                }
            }
        }
        case PICKER_VIEW_HEIGHT_TAG: {
            return pickerView.frame.size.width / 2.0f;
        }
        default: {
            return pickerView.frame.size.width;
        }
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (view) NSLog(@"view %@", view);

    // Create a new label
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = PICKER_VIEW_LABEL_TEXT_ALIGNMENT;
    label.font = pickerView.tag == PICKER_VIEW_GENDER_TAG ? PICKER_VIEW_GENDER_LABEL_FONT : PICKER_VIEW_LABEL_FONT;
    label.textColor = PICKER_VIEW_LABEL_TEXT_COLOR;
    label.backgroundColor = PICKER_VIEW_LABEL_BACKGROUND_COLOR;

    // Set label's text
    switch (pickerView.tag) {
        case PICKER_VIEW_GENDER_TAG: {
            label.text = row == 0 ? GENDER_PICKER_MALE_CHARACTER : GENDER_PICKER_FEMALE_CHARACTER;
            break;
        }
        case PICKER_VIEW_BIRTHDATE_TAG: {

            // Set birthdate picker month, day and year text values
            switch (component) {
                case DATE_PICKER_MONTH_POSITION: {
                    label.text = self.dateMonthsArray[row];
                    break;
                }
                case DATE_PICKER_DAY_POSITION: {
                    label.text = [self.dateDaysArray[row] stringValue];
                    break;
                }
                case DATE_PICKER_YEAR_POSITION: {
                    label.text = [self.dateYearsArray[row] stringValue];
                    break;
                }
            }
            break;
        }
        case PICKER_VIEW_HEIGHT_TAG: {

            // Set height picker feet and inches text values
            switch (component) {
                case HEIGHT_PICKER_FEET_POSITION: {
                    label.text = [NSString stringWithFormat:@"%@%@", self.heightFeetArray[row], HEIGHT_PICKER_FEET_SUFFIX];
                    break;
                }
                case HEIGHT_PICKER_INCHES_POSITION: {
                    label.text = [NSString stringWithFormat:@"%@%@", self.heightInchesArray[row], HEIGHT_PICKER_INCHES_SUFFIX];
                    break;
                }
            }
            break;
        }
        case PICKER_VIEW_WEIGHT_TAG: {
            label.text = [NSString stringWithFormat:@"%@%@", self.weightLbsArray[row], WEIGHT_PICKER_LBS_SUFFIX];
            break;
        }
    }

    // Return the label
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    CLUser *user = [CLUser user];

    switch (pickerView.tag) {
        case PICKER_VIEW_GENDER_TAG: {

            // Update gender image view
            self.genderImageView.image = [UIImage imageNamed:row == 0 ? GENDER_PICKER_MALE_IMAGE_PATH : GENDER_PICKER_FEMALE_IMAGE_PATH];

            // Update user's gender
            user.gender = row == 0 ? GENDER_PICKER_MALE_NAME : GENDER_PICKER_FEMALE_NAME;
            break;
        }
        case PICKER_VIEW_BIRTHDATE_TAG: {
            switch (component) {
                case DATE_PICKER_MONTH_POSITION: {

                    // Update days for selected month and year
                    self.dateDaysArray = [Utils                                   getAllDaysInMonth:
                            [pickerView selectedRowInComponent:DATE_PICKER_MONTH_POSITION] + 1 year:
                            [self.dateYearsArray[[pickerView selectedRowInComponent:DATE_PICKER_YEAR_POSITION]] integerValue]];
                    [pickerView reloadComponent:DATE_PICKER_DAY_POSITION];
                    break;
                }
                case DATE_PICKER_DAY_POSITION: {
                    break;
                }
                case DATE_PICKER_YEAR_POSITION: {

                    // Update days for selected month and year
                    self.dateDaysArray = [Utils                                   getAllDaysInMonth:
                            [pickerView selectedRowInComponent:DATE_PICKER_MONTH_POSITION] + 1 year:
                            [self.dateYearsArray[[pickerView selectedRowInComponent:DATE_PICKER_YEAR_POSITION]] integerValue]];
                    [pickerView reloadComponent:DATE_PICKER_DAY_POSITION];
                    break;
                }
            }

            // Update user's birthdate month, day and year and age
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setYear:[self.dateYearsArray[[pickerView selectedRowInComponent:DATE_PICKER_YEAR_POSITION]] integerValue]];
            [dateComponents setMonth:[pickerView selectedRowInComponent:DATE_PICKER_MONTH_POSITION] + 1];
            [dateComponents setDay:[self.dateDaysArray[[pickerView selectedRowInComponent:DATE_PICKER_DAY_POSITION]] integerValue]];
            [dateComponents setHour:0];
            [dateComponents setMinute:0];
            [dateComponents setSecond:0];
            [dateComponents setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            user.birthdate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
            user.age = @([Utils getYearCountFromDate:user.birthdate]);

            // Update age text field
            self.ageTextField.text = [user.age stringValue];
            break;
        }
        case PICKER_VIEW_HEIGHT_TAG: {

            // Hide height image view if case
            if (!self.heightImageView.hidden) {
                [self.heightImageView setUserInteractionEnabled:NO];
                [self.heightImageView setHidden:YES];
            }

            // Update selected height feet and inches
            user.heightFeet = self.heightFeetArray[[pickerView selectedRowInComponent:HEIGHT_PICKER_FEET_POSITION]];
            user.heightInches = self.heightInchesArray[[pickerView selectedRowInComponent:HEIGHT_PICKER_INCHES_POSITION]];

            // Update height text field
            self.heightTextField.text = [NSString stringWithFormat:@"%td%@%td%@", [user.heightFeet integerValue],
                            HEIGHT_PICKER_FEET_SUFFIX, [user.heightInches integerValue],
                            HEIGHT_PICKER_INCHES_SUFFIX];
            break;
        }
        case PICKER_VIEW_WEIGHT_TAG: {

            // Hide weight image view if case
            if (!self.weightImageView.hidden) {
                [self.weightImageView setUserInteractionEnabled:NO];
                [self.weightImageView setHidden:YES];
            }

            // Update weight text field
            NSString *weight = [NSString stringWithFormat:@"%@%@",
                                                          self.weightLbsArray[[pickerView selectedRowInComponent:0]], WEIGHT_PICKER_LBS_SUFFIX];

            // Create attributed string
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:weight];
            [attributedString addAttribute:NSFontAttributeName
                                     value:self.weightTextField.font
                                     range:NSMakeRange(0, weight.length - [WEIGHT_PICKER_LBS_SUFFIX length])];
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont fontWithName:self.weightTextField.font.fontName
                                                           size:self.weightTextField.font.pointSize *
                                                                   WEIGHT_PICKER_LBS_SUFFIX_FONT_RATIO]
                                     range:NSMakeRange(weight.length - [WEIGHT_PICKER_LBS_SUFFIX length],
                                             [WEIGHT_PICKER_LBS_SUFFIX length])];

            // Set attributed string
            [self.weightTextField setAttributedText:attributedString];

            // Update selected weight
            user.weight = weight;
            break;
        }
    }

    // Test if all the fields are completed
    self.sigUpButton.enabled = user.gender && user.birthdate && user.age ? YES : NO;
}

#pragma mark - Text field delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    self.activeField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    NSInteger nextTag = textField.tag + 1;
//    UIResponder *nextResponder = [self.view viewWithTag:nextTag];
//
//    // If next responder is email text field and it's registration with Facebook, go to responder after email text field
//    if (nextResponder == self.emailTextField && self.facebookRegistration) {
//        nextResponder = [self.view viewWithTag:nextTag + 1];
//    }
//
//    if (nextResponder) {
//        // Found next responder, so set it
//        [nextResponder becomeFirstResponder];
//    } else {
//
//        // Responder not found - last text field
//        [textField resignFirstResponder];
//
//        // Go to next registration steps
//        [self nextRegistrationStepAction:nil];
//    }
//
//    // We do not want text field to insert line-breaks
//    [textField resignFirstResponder];
//    return YES;

    if (textField == self.nameTextField) {
        [self.nameTextField becomeFirstResponder];
    }
    else if (textField == self.emailTextField) {
        [self.emailTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordRepeatTextField) {
        [self.passwordRepeatTextField becomeFirstResponder];
    }
    [self.view endEditing:YES];
    return YES;

}

- (IBAction)textFieldDidChange:(id)sender {
//    self.nextButton.enabled = [self.nameTextField.text length] != 0 && [self.emailTextField.text length] != 0 && [self.passwordTextField.text length] != 0 /*&& [self.phoneNumberTextField.text length] <= TEXT_FIELD_PHONE_NUMBER_CHARACTER_LIMIT*/;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    static NSString *password;
    if (textField.tag == CLRegistrationFieldTypeName) {
        if (textField.text.length > 0) {
            self.nameValidationImage.image = [UIImage imageNamed:@"text_check"];
            self.isNameValid = YES;
        } else {
            self.nameValidationImage.image = [UIImage imageNamed:@"text_clear"];
            self.isNameValid = NO;
        }
    } else if (textField.tag == CLRegistrationFieldTypeEmail) {
        if ([Utils isValidEmail:textField.text]) {
            self.emailValidationImage.image = [UIImage imageNamed:@"text_check"];
            self.isEmailValid = YES;
        } else {
            self.emailValidationImage.image = [UIImage imageNamed:@"text_clear"];
            self.isEmailValid = NO;
        }
    } else if (textField.tag == CLRegistrationFieldTypePassword) {
        if (textField.text.length > 0) {
            self.passwordValidationImage.image = [UIImage imageNamed:@"text_check"];
            self.isPasswordValid = YES;
            password = textField.text;
        } else {
            self.passwordValidationImage.image = [UIImage imageNamed:@"text_clear"];
            self.isPasswordValid = NO;
        }

    } else if (textField.tag == CLRegistrationFieldTypeRepeatPassword) {
        if ([self.realPassword isEqualToString:self.realPasswordСopy]) {
            self.repeatPasswordValidationImage.image = [UIImage imageNamed:@"text_check"];
            self.isPasswordCopyValid = YES;
        } else {
            self.repeatPasswordValidationImage.image = [UIImage imageNamed:@"text_clear"];
            self.isPasswordCopyValid = NO;
        }
    }
    
    if (self.isNameValid && self.isEmailValid && self.isPasswordValid && self.isPasswordCopyValid)
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger textFieldLength = textField.text.length + string.length - range.length;
    if (textField.tag == CLRegistrationFieldTypePassword) {

        self.realPassword = [[self.realPassword stringByAppendingString:string] stringByReplacingOccurrencesOfString:@"*"
                                                                                                          withString:@""];

        if ([string isEqualToString:@""]) {
            if (self.realPassword.length > 0) {
                self.realPassword = [self.realPassword substringToIndex:[self.realPassword length] - 1];
            } else {
                self.realPassword = @"";
            }
        }

        self.backing = textField.text;
        if (self.backing == nil) self.backing = @"";
        static BOOL pasting = false;

        if (!pasting) {
            self.backing = [self.backing stringByReplacingCharactersInRange:range withString:string];
            NSLog(@"backing: %@", self.backing);
            if ([string length] == 0) return YES; // early bail out when just deleting chars

            NSString *sec = @"";
            for (int i = 0; i < [string length]; i++) sec = [sec stringByAppendingFormat:@"*"];

            pasting = true;
            [[UIPasteboard generalPasteboard] setString:sec];
            [textField paste:self];

            return NO;
        } else {
            pasting = false;
            return YES;
        }
    } else if (textField.tag == CLRegistrationFieldTypeRepeatPassword) {

        self.realPasswordСopy = [[self.realPasswordСopy stringByAppendingString:string] stringByReplacingOccurrencesOfString:@"*"
                                                                                                                  withString:@""];

        if ([string isEqualToString:@""]) {
            if (self.realPasswordСopy.length > 0) {
                self.realPasswordСopy = [self.realPasswordСopy substringToIndex:[self.realPasswordСopy length] - 1];
            } else {
                self.realPasswordСopy = @"";
            }
        }

        self.backing = textField.text;
        if (self.backing == nil) self.backing = @"";
        static BOOL pasting = false;

        if (!pasting) {
            self.backing = [self.backing stringByReplacingCharactersInRange:range withString:string];
            NSLog(@"backing: %@", self.backing);
            if ([string length] == 0) return YES; // early bail out when just deleting chars

            NSString *sec = @"";
            for (int i = 0; i < [string length]; i++) sec = [sec stringByAppendingFormat:@"*"];

            pasting = true;
            [[UIPasteboard generalPasteboard] setString:sec];
            [textField paste:self];

            return NO;
        } else {
            pasting = false;
            return YES;
        }
    } else {
        return YES;
    }

//    // Limit first and last name to 26 characters
//    if (textField == self.nameTextField && textFieldLength > TEXT_FIELD_NAME_CHARACTER_LIMIT) {
//
//        // Show a warning mesage
//        [UIAlertView showWithTitle:nil message:NSLocalizedString(@"EnterUserDigitLimit", nil)
//                 cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil tapBlock:nil];
//
//        // Prevent entering charachters
//        return NO;
//    }
//
//    // Limit email to 26 characters
//    if (textField == self.emailTextField && textFieldLength > TEXT_FIELD_EMAIL_CHARACTER_LIMIT) {
//
//        // Show a warning mesage
//        [UIAlertView showWithTitle:nil message:NSLocalizedString(@"EnterEmailDigitLimit", nil)
//                 cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil tapBlock:nil];
//
//        // Prevent entering charachters
//        return NO;
//    }
//
//    // Limit phone number to 10 characters
//    if (/*textField == self.phoneNumberTextField &&*/ textFieldLength > TEXT_FIELD_PHONE_NUMBER_CHARACTER_LIMIT) {
//
//        // Show a warning mesage
//        [UIAlertView showWithTitle:nil message:NSLocalizedString(@"EnterPhoneNumberDigitLimit", nil)
//                 cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil tapBlock:nil];
//
//        // Prevent entering charachters
//        return NO;
//    }
//    return YES;
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    return YES;
//}

#pragma mark - Storyboard navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"SegueToRegisterStep2"]) {
//
//        // Segue to register view controller (step 2)
////        [(CLRegisterViewController *) segue.destinationViewController setType:CLRegisterViewControllerTypeStep2];
//    }
//}

#pragma mark - View controller's memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    NSLog(@"memory warning received");
}

#pragma mark - Keyboard

- (void)keyboardWillBeShown:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.registerScrollView.contentInset = contentInsets;
    self.registerScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.registerScrollView.contentInset = contentInsets;
    self.registerScrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.activeField resignFirstResponder];
}

#pragma mark - Private Methods

- (void)customize {
    self.avatarContainerView.layer.cornerRadius = 55.0f;
    self.avatarContainerView.layer.borderColor = AVATAR_BORDER_COLOR.CGColor;
    self.avatarContainerView.layer.borderWidth = 10.0f;

    self.nextStepButton.layer.borderColor = DISABLED_BORDER_COLOR.CGColor;
    self.nextStepButton.layer.borderWidth = 1.0;
    self.nextStepButton.layer.cornerRadius = 18.0;
    [self.nextStepButton setTitleColor:ENABLED_COLOR forState:UIControlStateNormal];
    [self.nextStepButton setTitleColor:DISABLED_COLOR forState:UIControlStateDisabled];
    self.nextStepButton.enabled = NO;

    [self setNavigationBarOpacity];
    [self setCustomNavigationBackButton];
//    [self setCustomNavigationBarTitle];
}

- (void)setNavigationBarOpacity {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)setCustomNavigationBackButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrowIcon"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.navigationController
                                                                            action:@selector(popViewControllerAnimated:)];
}

//- (void)setCustomNavigationBarTitle {
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
//            NSFontAttributeName : [UIFont fontWithName:@"Geomanist-Regular"
//                                                  size:20.0f]
//    }];
//}

@end
