//
//  CLHomeViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/4/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLHomeViewController.h"
#import "CLInfoViewController.h"
#import "CLWebImageCache.h"
#import "CLWebServiceCache.h"
#import "UIAlertView+Blocks.h"
#import "UIImage+Download.h"
#import "NSArray+Shuffle.h"
#import "Stylesheet.h"
#import "Constants.h"
#import "CLTimelineView.h"
#import "CLActivitiesView.h"
#import "CLNotifications.h"
#import "CLFacebookHandler.h"
#import "UIImage+Resize.h"
#import "Utils.h"
#import "CLFloatingActionButton.h"
#import "CLGameRulesViewController.h"
#import "CLRulesShowAnimationController.h"
#import "CLDismissAnimationController.h"
#import "CLTextBoxView.h"
#import "CLWelcomeScreenViewController.h"
#import "CLLeaderboardViewController.h"

#pragma mark Paricipant view tags

#define PARTICIPANT_PHOTO_VIEW_START_TAG 0
#define PARTICIPANT_DEVICE_VIEW_START_TAG 100

@interface CLHomeViewController () <ActivitiesViewDataSource, ActivitiesViewDelegate, FloatMenuDelegate, UIViewControllerTransitioningDelegate>

@property(nonatomic, weak) IBOutlet CLTimelineView *timelineView;
@property(nonatomic, weak) IBOutlet UILabel *stepsLabel;
@property(nonatomic, weak) IBOutlet UIButton *playersButton;
@property(nonatomic, weak) IBOutlet UIView *participantsView;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *playersButtonTopConstraint;

@property(nonatomic, weak) IBOutlet CLActivitiesView *activitiesView;

@property(nonatomic, assign) int appearingsCount;

@property(nonatomic, strong) IBOutletCollection(UIImageView) NSArray *participantsThumbnails;
@property(nonatomic, strong) IBOutletCollection(UIImageView) NSArray *participantsDeviceIcons;

//@property(nonatomic, strong) NSMutableArray *notificationsArray;

@property (nonatomic, strong) CLRulesShowAnimationController *presentAnimationController;
@property (nonatomic, strong) CLDismissAnimationController *dismissAnimationController;

@property (nonatomic, assign) BOOL isSyncInProgress;
@property (nonatomic, assign) NSUInteger participantsArrayCount;

@end

@implementation CLHomeViewController

#pragma mark - View controller's lifecycle methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _presentAnimationController = [CLRulesShowAnimationController new];
        _dismissAnimationController = [CLDismissAnimationController new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([CLUser user].device != kCLUserDeviceNoDevice) {
        [self syncUserStepsWithComplitionHandler:nil];
    }

    self.appearingsCount = 0;
    self.timelineView.hidden = YES;
    self.participantsView.hidden = NO;

    self.playersButton.layer.cornerRadius = 15.0f;
    self.playersButton.layer.borderColor = [UIColor colorWithRed:186.0 / 255.0 green:191.0 / 255.0 blue:16.0 / 255.0 alpha:0.6].CGColor;
    [self expandPlayers];

    self.activitiesView.dataSource = self;
    self.activitiesView.delegate = self;

    // Reset total steps digits and participants count
    [self setTotalSteps:@0];
    [self setParticipantsCount:@"0"];

    // Delay execution for 2 seconds (to prevent receiving Application Did Become Active notification immediately
    // after application launch - this would result in syncing user's steps twice)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        // Add this view controller to observe when the application becomes active
        NSLog(@"home view controller added as an observer to notification center");

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    });

    // Save the user to user defaults
    [CLUser saveUserDataToUserDefaults:[CLUser user]];

    [self setNavigationBarOpacity];
    [self setCustomNavigationBarTitle];
    [self addFloatingButton];
}

- (void)addFloatingButton
{
    CGFloat buttonWidth = 69.f;
    CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - buttonWidth - 6, [UIScreen mainScreen].bounds.size.height - buttonWidth - 6, buttonWidth, buttonWidth);

    CLFloatingActionButton *floatingButton = [[CLFloatingActionButton alloc] initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"FloatingList"] andPressedImage:[UIImage imageNamed:@"FloatingClose"]];
    
    floatingButton.imagesArray = @[@"FloatingHome", @"FloatingGameBoard"];
    floatingButton.labelsArray = @[@"HOME", @"GAME BOARD"];
    
    floatingButton.delegate = self;
    
    [self.view addSubview:floatingButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.activitiesView updateActivityView];

    self.appearingsCount++;

    if (self.appearingsCount > 0) {
        self.participantsView.hidden = YES;
        [self turnPlayers];
    }

    if ([[CLUser user] currentMiniGame]) {
        self.timelineView.startDate = [[[CLUser user] currentMiniGame] startDate];
        self.timelineView.durationDays = [[[CLUser user] currentMiniGame] durationDays];
        if (self.appearingsCount == 1) {
            self.timelineView.showCurrentDateOnly = NO;
        }
        else {
            self.timelineView.showCurrentDateOnly = YES;
        }
        [self.timelineView setNeedsDisplay];
        self.timelineView.hidden = NO;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePushNotification:) name:kNotificationsUpdatedNotification object:nil];

    // Change status bar color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];

    // Get participants count and total total steps
    [self getTotalSteps];
	[self getParticipants];

    // Sync user steps if 15 minutes have passed since last sync operation

    NSTimeInterval timeSinceLastSync = [[NSDate date] timeIntervalSinceDate:[CLUser user].lastSyncDate];

    if (![CLUser user].lastSyncDate || timeSinceLastSync > WEB_SERVICE_CACHE_EXPIRATION_TIME_SHORT) {
        [self syncUserStepsWithComplitionHandler:nil];
        [CLUser user].lastSyncDate = [NSDate date];
    } else {
        NSLog(@"%g more seconds until user steps sync can be performed again",
                WEB_SERVICE_CACHE_EXPIRATION_TIME_SHORT - timeSinceLastSync);
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationsUpdatedNotification object:nil];
}

#pragma mark - Navigation bar customization

- (void)setNavigationBarOpacity {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)setCustomNavigationBarTitle {
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
            NSFontAttributeName : [UIFont fontWithName:@"Geomanist-Regular" size:16.0f]}];
}

#pragma mark - Receive push notification

- (void)receivePushNotification:(NSNotification *)notification {
    [self.activitiesView updateActivityView];
}

#pragma mark - Gesture recognizers and actions

- (IBAction)menuAction:(id)sender {
    NSLog(@"show menu");

    // Get menu view controller and present it modally
    CLSideMenuViewController *menuViewController = [self.storyboard
            instantiateViewControllerWithIdentifier:@"SideMenuViewControllerStoryboardID"];
    [menuViewController setDelegate:self];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];

    [self.navigationController presentViewController:menuViewController animated:NO completion:nil];
}

- (IBAction)gameRulesAction:(id)sender
{
    CLGameRulesViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameRulesModalID"];
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    modalViewController.transitioningDelegate = self;
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (IBAction)showLeaderboardAction:(id)sender {
    [self performSegueWithIdentifier:@"SegueToLeaderboard" sender:self];
}

- (IBAction)playersButtonPressed:(id)sender {
    [self expandPlayers];

    [UIView animateWithDuration:0.5f animations:^{
        [self.view layoutIfNeeded];
    }                completion:^(BOOL finished) {
        self.participantsView.hidden = NO;
    }];
}

- (IBAction)tapOnActivitiesView:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"showActivitiesSegue" sender:self];
}

#pragma mark - Players visibility

- (void)turnPlayers
{
    self.playersButtonTopConstraint.constant = 42.0f;
    self.playersButton.layer.borderWidth = 1.0f;
    self.playersButton.userInteractionEnabled = YES;
    
    NSMutableAttributedString *playersCount = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu", (unsigned long)self.participantsArrayCount]
                                                                                     attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Geomanist-Book" size:13.0]}];
    NSAttributedString *playersString = [[NSAttributedString alloc] initWithString:@" PLAYERS"
                                                                        attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Geomanist-Light" size:13.0]}];
    [playersCount appendAttributedString:playersString];
    
    [self.playersButton setAttributedTitle:playersCount forState:UIControlStateNormal];
}

- (void)expandPlayers
{
    self.playersButtonTopConstraint.constant = 0.0f;
    self.playersButton.layer.borderWidth = 0.0f;
    self.playersButton.userInteractionEnabled = NO;
    
    NSAttributedString *playersString = [[NSAttributedString alloc] initWithString:@"TOP PLAYERS"
                                                                        attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Geomanist-Light" size:13.0]}];
    [self.playersButton setAttributedTitle:playersString forState:UIControlStateNormal];
}

#pragma mark - View controller notifications

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    NSLog(@"application become active");
    
    long currentTimezoneoffset = [[NSTimeZone systemTimeZone] secondsFromGMT] / 3600;
    long prevTimeZoneOffset = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_REST_PARAMETER_TIME_OFFSET] integerValue];

    if (currentTimezoneoffset != prevTimeZoneOffset) {
        NSDictionary *parameters = @{USER_REST_PARAMETER_TIME_OFFSET : @(currentTimezoneoffset)};
        [CLUser updateUserProfileWithParameters:parameters
                                completionBlock:^(id ok) {
                                    [[NSUserDefaults standardUserDefaults] setObject:@(currentTimezoneoffset) forKey:USER_REST_PARAMETER_TIME_OFFSET];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                } failureBlock:^(id failResponse, NSError *error) {
                                    
                                }];
    }
    
    [self syncUserStepsWithComplitionHandler:nil];
}

#pragma mark - User interface management

- (void)setTotalSteps:(NSNumber *)stepsNumber {
    [self setTotalSteps:stepsNumber animated:NO];
}

- (void)setTotalSteps:(NSNumber *)stepsNumber animated:(BOOL)animated {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;

    NSString *numberString = [formatter stringFromNumber:stepsNumber];
    NSAttributedString *stepsCount = [[NSAttributedString alloc] initWithString:numberString attributes:@{NSKernAttributeName : @4}];

    self.stepsLabel.attributedText = stepsCount;
}

- (void)setParticipantsCount:(NSString *)countString {
    [self setParticipantsCount:countString animated:NO];
}

- (void)setParticipantsCount:(NSString *)countString animated:(BOOL)animated {
    self.participantsArrayCount = [countString integerValue];
}

- (void)setParticipantsThumbnailPictures:(NSArray *)participants
{
    self.participantsThumbnails = [self.participantsThumbnails sortedArrayUsingComparator:^NSComparisonResult(UIImageView *imageView1, UIImageView *imageView2) {
        if (imageView1.frame.origin.x < imageView2.frame.origin.x)
        {
            return NSOrderedAscending;
        }
        else if (imageView1.frame.origin.x > imageView2.frame.origin.x)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    
    for (int i = 0; i < participants.count && i < self.participantsThumbnails.count; i++)
    {
        UIImageView *participantImageView = self.participantsThumbnails[i];

        // Get participant's device type
        NSInteger participantDeviceType = [participants[i][USER_REST_PARAMATER_DEVICE_TYPE] integerValue];

        // Download the picture and assign it to the thumbnail
        NSString *URLString = participants[i][USER_REST_PARAMATER_PROFILE_PICTURE];
        [UIImage downloadImageFromURL:URLString completion:^(UIImage *image, NSError *error) {
            if (!error)
            {
                [[CLWebImageCache cache] addImage:image forURL:URLString];

                // Change image animated
                [UIView transitionWithView:participantImageView
                                  duration:HOME_VIEW_CONTROLLER_PARTICIPANT_THUMBNAIL_ANIMATION_DURATION
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:
                                        ^{
                                            if (image)
                                            {
                                                [participantImageView setImage:image];
                                            }
                                            else
                                            {
                                                [participantImageView setImage:nil];
                                            }
                                        }
                                completion:nil];

                // Change device icon animated
                [UIView transitionWithView:[self.view viewWithTag:PARTICIPANT_DEVICE_VIEW_START_TAG + participantImageView.tag]
                                  duration:HOME_VIEW_CONTROLLER_PARTICIPANT_THUMBNAIL_ANIMATION_DURATION
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:
                                        ^{
                                            [(UIImageView *) [self.view viewWithTag:PARTICIPANT_DEVICE_VIEW_START_TAG + participantImageView.tag]
                                                    setImage:[CLUser getDeviceIconImage:participantDeviceType]];
                                        } completion:nil];
            } else {
                [participantImageView setImage:[UIImage imageNamed:@"NoPhotoIcon"]];
                [UIView transitionWithView:[self.view viewWithTag:PARTICIPANT_DEVICE_VIEW_START_TAG + participantImageView.tag]
                                  duration:HOME_VIEW_CONTROLLER_PARTICIPANT_THUMBNAIL_ANIMATION_DURATION
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:
                 ^{
                     [(UIImageView *) [self.view viewWithTag:PARTICIPANT_DEVICE_VIEW_START_TAG + participantImageView.tag]
                      setImage:[CLUser getDeviceIconImage:participantDeviceType]];
                 } completion:nil];
            }
        }];
    }
}

- (void)notifyUserAboutStepSync {
    NSLog(@"0 steps for today, notify the user");

    // Create the message string
    NSString *messageString = NSLocalizedString(@"MakeSureStepsAreSynced", nil);
    switch ([CLUser user].device) {
        case kCLUserDeviceFitbit: {
            messageString = [NSString stringWithFormat:NSLocalizedString(@"MakeSureStepsAreSyncedLong", nil),
                                                       NSLocalizedString(@"FitbitApp", nil)];
            break;
        }
        case kCLUserDeviceJawbone: {
            messageString = [NSString stringWithFormat:NSLocalizedString(@"MakeSureStepsAreSyncedLong", nil),
                                                       NSLocalizedString(@"JawboneApp", nil)];
            break;
        }
        case kCLUserDeviceHealthKit: {
            messageString = [NSString stringWithFormat:NSLocalizedString(@"MakeSureStepsAreSyncedLong", nil),
                                                       NSLocalizedString(@"HealthApp", nil)];
            break;
        }
        default: {
            break;
        }
    }

    // Show message
    [CLTextBoxView showWithTitle:NSLocalizedString(@"MakeSureStepsAreSyncedTitle", nil) message:messageString];
}

- (void)removeViewControllersAboveThisViewControllerAnimated:(BOOL)animated {
    // Remove any view controllers that are above this view controller
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    if ([viewControllers containsObject:self]) {

        // Remove view controllers until the last view controller is this view controller
        while ([viewControllers lastObject] != self) {
            [viewControllers removeLastObject];
        }

        // Set new view controller stack
        [self.navigationController setViewControllers:[NSArray arrayWithArray:viewControllers] animated:animated];
    }
}

#pragma mark - User notification management methods

- (NSDateFormatter *)notificationTimeFormatter {
    static NSDateFormatter *dateFormatter;

    if (!dateFormatter) {

        // Lazy instantiation
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:DATE_FORMAT_HOUR_MINUTE];
    }
    return dateFormatter;
}



#pragma mark - Network request methods

- (void)getTotalSteps {
    // Send a GET request
    [CLUser getAllParticipantsTotalStepsFromCache:NO successBlock:^(id data, BOOL fromCache) {
        // Check if we have all the steps from participants
        if ([data isKindOfClass:[NSDictionary class]] && data[USER_REST_PARAMATER_TOTAL_STEPS] && [data[USER_REST_PARAMATER_TOTAL_STEPS] isKindOfClass:[NSNumber class]]) {
            NSLog(@"get all participants total steps success: %@", data);
            // Set total steps
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isSyncInProgress = NO;
            });
            [self setTotalSteps:@([data[USER_REST_PARAMATER_TOTAL_STEPS] doubleValue]) animated:YES];
        }
        else {
            // No data received
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isSyncInProgress = NO;
            });
            NSLog(@"total steps could not be retrieved: %@", data);
        }

    }                                failureBlock:^(id data, NSError *error) {
        NSLog(@"get all participants steps failed: %@", error.localizedDescription);
    }];
}

- (void)getParticipants {
    // Send a POST request to get the overall leaderboard and count the number of participants
    [CLUser getLeaderboardForDay:kCLUserLeaderboardOverall fromCache:NO successBlock:^(id data, BOOL fromCache) {
        // Check if we have a leaderboard list
        if ([data isKindOfClass:[NSDictionary class]] && data[USER_REST_PARAMATER_LEADERBOARD] && [data[USER_REST_PARAMATER_LEADERBOARD] isKindOfClass:[NSArray class]]) {
            // Set participants count
            [self setParticipantsCount:[NSString stringWithFormat:@"%tu", [data[USER_REST_PARAMATER_LEADERBOARD] count]] animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isSyncInProgress = NO;
            });
            // Set participants thumbnails
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SYNC_FINISHED object:data[USER_REST_PARAMATER_LEADERBOARD]];

            if (self.playersButtonTopConstraint.constant == 42.0f) {
                [self turnPlayers];
            }

            [self setParticipantsThumbnailPictures:data[USER_REST_PARAMATER_LEADERBOARD]];
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isSyncInProgress = NO;
            });
            // No data received
            NSLog(@"leaderboard could not be retrieved");
        }

    }               failureBlock:^(id data, NSError *error) {
        NSLog(@"get leaderboard for day failed: %@", error.localizedDescription);
    }];
}

- (void)syncUserStepsWithComplitionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {

    if (self.isSyncInProgress) {
        return;
    }
    
    self.isSyncInProgress = YES;
    // Sync the steps
    [CLUser syncStepsWithSuccessBlock:^(id data) {
        NSInteger challengeDay = 0;
        
        NSLog(@"steps synced with success: %@", data);

        // If step count for the current challenge day equals to 0, prompt the user about synchronization
        if ([data isKindOfClass:[NSDictionary class]] && data[USER_REST_PARAMATER_CURRENT_CHALLENGE_DAY] &&
                [data[USER_REST_PARAMATER_CURRENT_CHALLENGE_DAY] isKindOfClass:[NSNumber class]]) {

            // Create challenge day dictionary key
            challengeDay = [data[USER_REST_PARAMATER_CURRENT_CHALLENGE_DAY] integerValue];
            NSString *key = [NSString stringWithFormat:@"%@%td", USER_REST_PARAMATER_USER_STEPS_DAY, challengeDay];

            // Check if the user has synced 0 steps for today
            if (data[key] && [data[key] isKindOfClass:[NSNumber class]] && [data[key] integerValue] == 0) {
                [self notifyUserAboutStepSync];
            }

            NSLog(@"clear all cached data except challenge start date");

            // Get challenge start date
            CLWebServiceCache *startDateCache = [CLWebServiceCache getCacheDataForKey:USER_REST_API_CHALLENGE_START_DATE_URL];

            // Clear all the cached data
            [CLWebServiceCache clearAllCache];

            // Add start date back to the cache
            [CLWebServiceCache addCacheData:startDateCache.data
                                    forDate:startDateCache.cacheDate
                    withCacheExpirationTime:startDateCache.cacheExpirationTime
                                     forKey:USER_REST_API_CHALLENGE_START_DATE_URL];
        }

        // Save cache to user defaults
        [CLWebServiceCache saveCacheDataToUserDefaults:[CLWebServiceCache cache]];

        // Update participants count and total total steps
        [self getTotalSteps];
        [self getParticipants];

        if ([[CLUser user] currentMiniGame]) {
            self.timelineView.startDate = [[[CLUser user] currentMiniGame] startDate];
            self.timelineView.durationDays = [[[CLUser user] currentMiniGame] durationDays];
            if (self.appearingsCount == 1) {
                self.timelineView.showCurrentDateOnly = NO;
            }
            else {
                self.timelineView.showCurrentDateOnly = YES;
            }
            [self.timelineView setNeedsDisplay];
            self.timelineView.hidden = NO;
        }

        if (completionHandler)
        {
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }
    failureBlock:^(id data, NSError *error) {

        if ([[CLUser user] currentMiniGame]) {
            self.timelineView.startDate = [[[CLUser user] currentMiniGame] startDate];
            self.timelineView.durationDays = [[[CLUser user] currentMiniGame] durationDays];
            if (self.appearingsCount == 1) {
                self.timelineView.showCurrentDateOnly = NO;
            }
            else {
                self.timelineView.showCurrentDateOnly = YES;
            }
            [self.timelineView setNeedsDisplay];
            self.timelineView.hidden = NO;
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isSyncInProgress = NO;
        });
        // Add sync failure notification
//        [self setNotificationSyncFailure];

        if (completionHandler)
        {
            completionHandler(UIBackgroundFetchResultFailed);
        }
        NSLog(@"failed to sync the steps: %@", [error localizedDescription]);
    }];
}


#pragma mark - Menu view controller delegate methods

- (void)menuViewController:(CLSideMenuViewController *)menuViewController homeMenuPressed:(id)homeMenu {
    NSLog(@"show home");

    // Remove any view controllers above home view controller
    [self removeViewControllersAboveThisViewControllerAnimated:NO];

    // Dismiss menu view controller
    [menuViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)menuViewController:(CLSideMenuViewController *)menuViewController challengeDetailsMenuPressed:(id)challengeDetailsMenu {
    NSLog(@"show challenge details");

    // Remove any view controllers above home view controller
    [self removeViewControllersAboveThisViewControllerAnimated:NO];

    // Segue to challenge details
    [self performSegueWithIdentifier:@"SegueToChallengeDetails" sender:self];

    // Dismiss menu view controller
    [menuViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)menuViewController:(CLSideMenuViewController *)menuViewController syncingStepsMenuPressed:(id)syncingStepsMenu {
    NSLog(@"show syncing steps");

    // Remove any view controllers above home view controller
    [self removeViewControllersAboveThisViewControllerAnimated:NO];

    // Segue to challenge details
    [self performSegueWithIdentifier:@"SegueToSyncingSteps" sender:self];

    // Dismiss menu view controller
    [menuViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)menuViewController:(CLSideMenuViewController *)menuViewController prizesMenuPressed:(id)prizesMenu {
    NSLog(@"show prizes");

    // Remove any view controllers above home view controller
    [self removeViewControllersAboveThisViewControllerAnimated:NO];

    // Segue to challenge details
    [self performSegueWithIdentifier:@"SegueToPrizes" sender:self];

    // Dismiss menu view controller
    [menuViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)menuViewController:(CLSideMenuViewController *)menuViewController cardioLegendMenuPressed:(id)prizesMenu {
    // Open Cardio Legend external link
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:USER_URL_CARDIO_LEGEND]];
}

- (void)menuViewController:(CLSideMenuViewController *)menuViewController signOutButtonPressed:(id)signOutButton {
    [[CLUser user] logOut];
    [menuViewController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)menuViewController:(CLSideMenuViewController *)menuViewController gameRules:(id)gameRulesButton
{
    [menuViewController dismissViewControllerAnimated:NO completion:nil];
    
    CLGameRulesViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameRulesModalID"];
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    modalViewController.transitioningDelegate = self;
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (void)menuViewController:(CLSideMenuViewController *)menuViewController editProfile:(id)editProfileButton
{
    [self performSegueWithIdentifier:@"SegueToEditProfile" sender:self];
    [menuViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Intro segue delegate methods

- (void)introSegueDidFinishAnimation:(CLIntroSegue *)introSegue {
    // Leave only login and this view controller on navigation stack
    UIViewController *loginViewController = [self.storyboard
            instantiateViewControllerWithIdentifier:@"LoginViewControllerStoryboardID"];
    [self.navigationController setViewControllers:@[loginViewController, self] animated:NO];

    NSLog(@"navigation stack: %@", self.navigationController.viewControllers);
}

#pragma mark - Storyboard navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueToChallengeDetails"] ||
            [segue.identifier isEqualToString:@"SegueToSyncingSteps"] ||
            [segue.identifier isEqualToString:@"SegueToPrizes"]) {

        // Segue to info view controller
        [(CLInfoViewController *) segue.destinationViewController setHomeViewController:self];
    }
}

#pragma mark - View controller's memory management

- (void)dealloc {
    // Remove this view controller from notification center as an observer
    NSLog(@"home view controller removed as an observer from notification center");
}

#pragma mark - ActivitiesViewDataSource

- (NSInteger)numberOfCardsInActivitiesView:(CLActivitiesView *)activitiesView {
    return [[[CLNotifications sharedInstance] unreadNotifications] count];
}

- (NSInteger)numberOfSentencesForTopCardInActivitiesView:(CLActivitiesView *)activitiesView {
    NSString *message = ((CLPushNotification *) [[[CLNotifications sharedInstance] unreadNotifications] lastObject]).message;

    NSRange range = [message rangeOfString:@"! "];
    if (range.location == NSNotFound) {
        range = [message rangeOfString:@". "];
    }
    if (range.location == NSNotFound) {
        return 1;
    }
    else {
        return 2;
    }
}

- (NSArray *)messagesForTopCardInActivitiesView:(CLActivitiesView *)activitiesView {
    NSString *message = ((CLPushNotification *) [[[CLNotifications sharedInstance] unreadNotifications] lastObject]).message;

    NSRange range = [message rangeOfString:@"! "];
    if (range.location == NSNotFound) {
        range = [message rangeOfString:@". "];
    }
    if (range.location == NSNotFound) {
        NSArray *messages = @[message];
        return messages;
    }
    else {
        NSString *substring1 = [message substringToIndex:range.location + 1];
        NSString *substring2 = [message substringFromIndex:range.location + range.length];
        NSArray *messages = @[substring1, substring2];
        return messages;
    }
}

- (UIImage *)imageForTopCardInActivitiesView:(CLActivitiesView *)activitiesView
{
    switch (((CLPushNotification *) [[[CLNotifications sharedInstance] unreadNotifications] lastObject]).type)
    {
        case 1:
            return ((CLPushNotification *) [[[CLNotifications sharedInstance] unreadNotifications] lastObject]).profilePicture ?: HOME_VIEW_CONTROLLER_DEFAULT_PROFILE_PICTURE_ICON;
        case 2:
            return ((CLPushNotification *) [[[CLNotifications sharedInstance] unreadNotifications] lastObject]).profilePicture ?: HOME_VIEW_CONTROLLER_DEFAULT_PROFILE_PICTURE_ICON;
        case 3:
            return [UIImage imageNamed:@"home_contestconditions"];
        case 4:
            return [UIImage imageNamed:@"home_contestconditions"];
        case 5:
            return ((CLPushNotification *) [[[CLNotifications sharedInstance] unreadNotifications] lastObject]).profilePicture ?: HOME_VIEW_CONTROLLER_DEFAULT_PROFILE_PICTURE_ICON;
        case 6:
            return [UIImage imageNamed:@"ico_great_job"];
        case 7:
            return [UIImage imageNamed:@"ico_great_job"];
        case 8:
            return [UIImage imageNamed:@"ico_great_job"];
        case 9:
            return [UIImage imageNamed:@"ico_great_job"];
        case 10:
            return [UIImage imageNamed:@"ico_great_job"];
        case 11:
            return [UIImage imageNamed:@"ico_great_job"];
        case 12:
            return [UIImage imageNamed:@"TopPlayer"];
        case 13:
            return [UIImage imageNamed:@"ico_nosteps"];
        case 14:
            return [UIImage imageNamed:@"ico_great_job"];
        case 15:
            return [UIImage imageNamed:@"cupWithTape"];
        case 0:
            return [UIImage imageNamed:@"cupWithTape"];
        default:
            return nil;
    }
}

- (BOOL)backgroundShoudBeSet:(CLActivitiesView *)activitiesView {
    switch (((CLPushNotification *) [[[CLNotifications sharedInstance] unreadNotifications] lastObject]).type) {
        case 0:
            return YES;
        case 1:
            return NO;
        case 2:
            return NO;
        case 3:
            return YES;
        case 4:
            return YES;
        case 5:
            return NO;
        case 6:
            return YES;
        case 7:
            return YES;
        case 8:
            return YES;
        case 9:
            return YES;
        case 10:
            return YES;
        case 11:
            return YES;
        case 12:
            return YES;
        case 13:
            return YES;
        case 14:
            return YES;
        case 15:
            return YES;
        default:
            return NO;
    }
}

#pragma mark - ActivitiesViewDelegate

- (void)activitiesViewWillBeginSlidingAnimation:(CLActivitiesView *)activitiesView {
    [[CLNotifications sharedInstance] markTopNotificationRead];
}

#pragma mark - FloatingViewDelegate

- (void)didSelectMenuOptionAtIndex:(NSInteger)row
{
    if (row == 1) {
        [self performSegueWithIdentifier:@"SegueToLeaderboard" sender:self];
    }
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
