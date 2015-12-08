//
//  CLEditProfileContainerViewController.m
//  UPMC
//

#import "CLEditProfileContainerViewController.h"
#import "CLEditProfileScreensViewController.h"
#import "CLUser.h"
#import "CLUser+API.h"
#import "CLActivityIndicator.h"
#import "Stylesheet.h"
#import "CLTextBoxView.h"
#import "DDPageControl.h"

#define ENABLED_COLOR [[UIColor whiteColor] colorWithAlphaComponent:1.0]
#define DISABLED_COLOR [[UIColor whiteColor] colorWithAlphaComponent:0.2]
#define ENABLED_BORDER_COLOR [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:1.0]
#define DISABLED_BORDER_COLOR [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:0.4]

@interface CLEditProfileContainerViewController () <UIScrollViewDelegate, CLEditProfileScreensViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *persistentView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
//@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) DDPageControl *pageControl;

@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray *menuImageViews;
@property (nonatomic, strong) UIImage *userProfilePicture;
@property (nonatomic, strong) NSString *userProfilePictureURL;
@property (nonatomic, strong) NSString *userFirstName;
@property (nonatomic, strong) NSString *userLastName;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userGender;
@property (nonatomic, strong) NSNumber *userAge;
@property (nonatomic, strong) NSDate *userBirthdate;
@property (nonatomic, strong) NSNumber *userHeightFeet;
@property (nonatomic, strong) NSNumber *userHeightInches;
@property (nonatomic, strong) NSString *userWeight;

@property (nonatomic, weak) UITextField *activeField;

@end

@implementation CLEditProfileContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self readUserData];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.navigationController
                                                                            action:@selector(popViewControllerAnimated:)];
    
    self.saveButton.layer.borderWidth = 1.0;
    self.saveButton.layer.cornerRadius = self.saveButton.frame.size.height / 2.0;
    [self.saveButton setTitleColor:ENABLED_COLOR forState:UIControlStateNormal];
    [self.saveButton setTitleColor:DISABLED_COLOR forState:UIControlStateDisabled];
    self.saveButton.enabled = NO;
    self.saveButton.layer.borderColor = DISABLED_BORDER_COLOR.CGColor;
    
    [self selectMenuItem:0];
    
    [self configurePageControl];
}

#pragma mark - UIPageControl actions

- (IBAction)changePage:(UIPageControl *)sender
{
    [self.scrollView setContentOffset:CGPointMake(sender.currentPage * self.scrollView.frame.size.width, 0.0f) animated:YES];
}

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSInteger page = lround(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
//    self.pageControl.currentPage = page;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.activeField resignFirstResponder];
    NSInteger page = lround(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    self.pageControl.currentPage = page;
    [self selectMenuItem:page];
}

#pragma mark - IBActions

- (IBAction)editMenuElementTap:(UITapGestureRecognizer *)sender
{
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * (sender.view.tag - 1), 0.0) animated:NO];
}

- (IBAction)saveChanges:(id)sender
{
    CLUser *user = [CLUser user];
    
    [self writeUserData];
    [CLUser saveUserDataToUserDefaults:user];
    
    [CLActivityIndicator showInView:self.navigationController.view title:NSLocalizedString(@"Editing", nil) animated:YES];
    
    [CLUser editUserProfile:user
            completionBlock:^(id data) {
                NSLog(@"success: %@", data);
                [CLActivityIndicator hideForView:self.navigationController.view animated:YES completion:^{
                    [CLTextBoxView showWithTitle:@"Success!" message:@"You have successfully changed your profile."];
                    self.saveButton.enabled = NO;
                    self.saveButton.layer.borderColor = DISABLED_BORDER_COLOR.CGColor;
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

#pragma mark - Helpers

- (void)selectMenuItem:(NSInteger)item
{
    for (UIImageView *imageView in self.menuImageViews)
    {
        imageView.alpha = imageView.tag - 1 == item ? 1.0 : 0.2;
    }
}

- (void)configurePageControl
{
    self.pageControl = [[DDPageControl alloc] initWithType:DDPageControlTypeOnFullOffFull];
    self.pageControl.center = CGPointMake(self.persistentView.center.x, 18.0);
    self.pageControl.numberOfPages = 4;
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.onColor = [UIColor whiteColor];
    self.pageControl.offColor = [UIColor colorWithRed:0.0/255.0 green:145.0/255.0 blue:179.0/255.0 alpha:0.5];
    self.pageControl.indicatorDiameter = 5.0;
    self.pageControl.indicatorSpace = 6.0;
    [self.persistentView addSubview:self.pageControl];
}

- (void)readUserData
{
    CLUser *user = [CLUser user];
    self.userProfilePicture = user.profilePicture;
    self.userProfilePictureURL = user.profilePictureURL;
    self.userFirstName = user.firstName;
    self.userLastName = user.lastName;
    self.userEmail = user.email;
    self.userGender = user.gender;
    self.userAge = user.age;
    self.userBirthdate = user.birthdate;
    self.userHeightFeet = user.heightFeet;
    self.userHeightInches = user.heightInches;
    self.userWeight = user.weight;
}

- (void)writeUserData
{
    CLUser *user = [CLUser user];
    user.profilePicture = self.userProfilePicture;
    user.profilePictureURL = self.userProfilePictureURL;
    user.firstName = self.userFirstName;
    user.lastName = self.userLastName;
    user.email = self.userEmail;
    user.gender = self.userGender;
    user.age = self.userAge;
    user.birthdate = self.userBirthdate;
    user.heightFeet = self.userHeightFeet;
    user.heightInches = self.userHeightInches;
    user.weight = self.userWeight;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToEditProfileScreens"])
    {
        CLEditProfileScreensViewController *destination = (CLEditProfileScreensViewController *)segue.destinationViewController;
        destination.delegate = self;
    }
}

#pragma mark - CLEditProfileScreensViewControllerDelegate

- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeProfilePicture:(UIImage *)profilePicture
{
    self.userProfilePicture = profilePicture;
    if (profilePicture == nil)
    {
        self.userProfilePictureURL = nil;
    }
    
    if (!self.saveButton.enabled)
    {
        self.saveButton.enabled = YES;
        self.saveButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
    }
}

- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    self.userFirstName = firstName;
    self.userLastName = lastName;
    
    if (![self.userFirstName isEqualToString:[CLUser user].firstName] || ![self.userLastName isEqualToString:[CLUser user].lastName])
    {
        if (!self.saveButton.enabled)
        {
            self.saveButton.enabled = YES;
            self.saveButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
        }
    }
}

- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeEmail:(NSString *)email
{
    self.userEmail = email;
    
    if (![self.userEmail isEqualToString:[CLUser user].email] && !self.saveButton.enabled)
    {
        self.saveButton.enabled = YES;
        self.saveButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
    }
}

- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeGender:(NSString *)gender
{
    self.userGender = gender;
    
    if (!self.saveButton.enabled)
    {
        self.saveButton.enabled = YES;
        self.saveButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
    }
}

- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeAge:(NSNumber *)age birthdate:(NSDate *)birthdate
{
    self.userAge = age;
    self.userBirthdate = birthdate;
    
    if (!self.saveButton.enabled)
    {
        self.saveButton.enabled = YES;
        self.saveButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
    }
}

- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeHeightFeet:(NSNumber *)feet inches:(NSNumber *)inches
{
    self.userHeightFeet = feet;
    self.userHeightInches = inches;
    
    if (!self.saveButton.enabled)
    {
        self.saveButton.enabled = YES;
        self.saveButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
    }
}

- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeWeight:(NSString *)weight
{
    self.userWeight = weight;
    
    if (!self.saveButton.enabled)
    {
        self.saveButton.enabled = YES;
        self.saveButton.layer.borderColor = ENABLED_BORDER_COLOR.CGColor;
    }
}

- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller activateTextField:(UITextField *)field
{
    self.activeField = field;
}

@end
