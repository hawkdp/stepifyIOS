//
//  CLWelcomeScreenViewController.m
//  NSBE
//

#import "CLWelcomeScreenViewController.h"
#import "CLJoinStepsViewController.h"
#import "CLLoginToStepsViewController.h"
#import "CLUser.h"
#import "CLFadeAnimationController.h"
#import "CLPushAnimationController.h"
#import "CLUser+API.h"
#import "DDPageControl.h"
#import "CLTextBoxView.h"

@interface CLWelcomeScreenViewController () <UIScrollViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *persistentView;
@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) IBOutlet UIButton *signUpButton;

@property (nonatomic, strong) DDPageControl *pageControl;

@property(nonatomic, weak) IBOutlet UIView *videoSubview;

@property(nonatomic, strong) CLFadeAnimationController *fadeAnimationController;
@property(nonatomic, strong) CLPushAnimationController *pushAnimationController;

@end

@implementation CLWelcomeScreenViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _fadeAnimationController = [CLFadeAnimationController new];
        _pushAnimationController = [CLPushAnimationController new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([CLUser user].accessToken) {
        int timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT] / 3600);
        [[NSUserDefaults standardUserDefaults] setObject:@(timezoneoffset) forKey:USER_REST_PARAMETER_TIME_OFFSET];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSDictionary *parameters = @{USER_REST_PARAMETER_TIME_OFFSET : @(timezoneoffset)};
        [CLUser updateUserProfileWithParameters:parameters
                                completionBlock:^(id ok) {
                                    // The user was saved locally and has the necessary data, segue to home view controller
                                    if ([ok[@"usr_device_id"] integerValue] == 0) {
                                        [self performSegueWithIdentifier:@"SegueToSelectDevice" sender:self];
                                    } else
                                    {
                                        [self performSegueWithIdentifier:@"SegueToHome" sender:self];
                                    }
                                }
                                   failureBlock:^(id failResponse, NSError *error) {
                                       NSLog(@"Failed %s", __PRETTY_FUNCTION__);
                                   }];
    }

    self.signUpButton.layer.borderColor = [UIColor colorWithRed:186.0/255.0 green:191.0/255.0 blue:16.0/255.0 alpha:1.0].CGColor;
    self.signUpButton.layer.borderWidth = 1.0;
    self.signUpButton.layer.cornerRadius = 22.0;

    self.navigationController.delegate = self;
    
    [self configurePageControl];
}

#pragma mark - UIPageControl actions

- (IBAction)changePage:(UIPageControl *)sender {
    [self.scrollView setContentOffset:CGPointMake(sender.currentPage * self.scrollView.frame.size.width, 0.0f) animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = lround(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    self.pageControl.currentPage = page;
}

#pragma mark - Helpers

- (void)configurePageControl
{
    self.pageControl = [[DDPageControl alloc] initWithType:DDPageControlTypeOnFullOffFull];
    self.pageControl.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 74.0);
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.onColor = [UIColor whiteColor];
    self.pageControl.offColor = [UIColor colorWithRed:0.0/255.0 green:145.0/255.0 blue:179.0/255.0 alpha:0.5];
    self.pageControl.indicatorDiameter = 5.0;
    self.pageControl.indicatorSpace = 6.0;
    [self.persistentView addSubview:self.pageControl];
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush && [fromVC class] == [CLWelcomeScreenViewController class]) {
        return self.fadeAnimationController;
    }
    else if (operation == UINavigationControllerOperationPop && [toVC class] == [CLWelcomeScreenViewController class]) {
        return self.fadeAnimationController;
    }
    else if (operation == UINavigationControllerOperationPush && [toVC class] == [CLLoginToStepsViewController class]) {
        self.pushAnimationController.reverse = NO;
        return self.pushAnimationController;
    }
    else if (operation == UINavigationControllerOperationPop && [fromVC class] == [CLLoginToStepsViewController class]) {
        self.pushAnimationController.reverse = YES;
        return self.pushAnimationController;
    }
    else {
        return nil;
    }
}

@end
