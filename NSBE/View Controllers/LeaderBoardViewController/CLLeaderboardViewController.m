//
//  CLLeaderboardViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/5/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLLeaderboardViewController.h"
#import "CLLeaderboardTableViewCell.h"
#import "CLActivityIndicator.h"
#import "CLWebImageCache.h"
#import "UILabel+TextAnimationTransition.h"
#import "UIAlertView+Blocks.h"
#import "UIImage+Download.h"
#import "Stylesheet.h"
#import "Constants.h"
#import "Utils.h"
#import "CLLeaderboardDayCollectionViewCell.h"
#import "SevenSwitch.h"
#import "CLFloatingActionButton.h"
#import "CLTextBoxView.h"
#import "CLSideMenuViewController.h"
#import "CLGameRulesViewController.h"
#import "CLRulesShowAnimationController.h"
#import "CLDismissAnimationController.h"
#import "CLHomeViewController.h"

typedef NS_ENUM(NSInteger, CLLeaderboardMode) {
    CLLeaderboardModeDaily = 0,
    CLLeaderboardModeWeekly = 1
};

@interface CLLeaderboardViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FloatMenuDelegate, CLSideMenuViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property(weak, nonatomic) IBOutlet SevenSwitch *leaderboardModeSwitch;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic, weak) IBOutlet UIImageView *profilePictureImageView;
@property(nonatomic, weak) IBOutlet UILabel *userPositionLabel;
@property(nonatomic, weak) IBOutlet UILabel *userPositionSuffixLabel;
@property(nonatomic, weak) IBOutlet UILabel *userStepsLabel;
@property(nonatomic, weak) IBOutlet UILabel *participantsCountLabel;
@property(nonatomic, weak) IBOutlet UIView *activityContainerView;
@property(nonatomic, weak) IBOutlet MRActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet UIImageView *fitnessDeviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property(nonatomic, assign) NSInteger userLeadeboardPosition;
@property(nonatomic, assign) NSInteger selectedLeaderboardDay;
@property(nonatomic, assign) NSInteger selectedLeaderboardWeek;
@property(nonatomic, strong) NSArray *leaderboardParticipantsArray;
@property (weak, nonatomic) IBOutlet UIView *tableViewBackgroudView;
@property (weak, nonatomic) IBOutlet UIView *leaderboardView;

@property (nonatomic, strong) CLRulesShowAnimationController *presentAnimationController;
@property (nonatomic, strong) CLDismissAnimationController *dismissAnimationController;
@property (weak, nonatomic) IBOutlet UILabel *ofLabel;

@property (nonatomic, assign) double visibleDays;
@property (nonatomic, assign) double visibleWeeks;

@end

@implementation CLLeaderboardViewController

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
    
    double days = ([[NSDate date] timeIntervalSinceDate:[CLUser user].currentMiniGame.startDate]) / 3600.f / 24.f;
    self.visibleDays = ceill(days);
    self.visibleWeeks = ceill(self.visibleDays / 7.f);
    
    self.fitnessDeviceImageView.image = [CLUser getDeviceIconImage:[CLUser user].device];
    // Do any additional setup after loading the view.

    self.leaderboardModeSwitch.onTintColor =  [UIColor colorWithRed:63.f/255.f green:116.f/255.f blue:132.f/255.f alpha:1.0f];
    self.leaderboardModeSwitch.inactiveColor = [UIColor colorWithRed:63.f/255.f green:116.f/255.f blue:132.f/255.f alpha:1.0f];
    self.leaderboardModeSwitch.borderColor = [UIColor colorWithRed:63.f/255.f green:116.f/255.f blue:132.f/255.f alpha:1.0f];
    self.leaderboardModeSwitch.thumbImage = [UIImage imageNamed:@"switch_steps_blue"];
    self.leaderboardModeSwitch.offImage = [UIImage imageNamed:@"switch_cup_white"];
    self.collectionView.tag = CLLeaderboardModeDaily;
    //

    self.activityContainerView.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = [UIScreen mainScreen].bounds;
    [self.activityContainerView insertSubview:effectView belowSubview:self.activityIndicatorView];
    
    self.selectedLeaderboardDay = self.visibleDays + 1;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:self.visibleDays + 1 inSection:0]];
    });

    // Reset user statistics labels
    [self resetUserStatisticsAnimated:NO];

    [[CLWebImageCache cache] setCacheSize:PARTICIPANTS_PHOTOS_CACHE_COUNT];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:KNOTIFICATION_SYNC_FINISHED object:nil];
    
    [self addFloatingButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshData:(NSNotification *)aNotofication
{
    NSInteger row = 0;

    NSLog(@"%@", aNotofication.object);
    
    if (self.collectionView.tag == CLLeaderboardModeDaily) {
        if (self.selectedLeaderboardDay == self.visibleDays + 1) {
            self.leaderboardParticipantsArray = aNotofication.object;
            [self getUserStatisticsFor:kCLUserLeaderboardOverall];
            [self.tableView reloadData];
            return;
        }
        row = self.selectedLeaderboardDay;
    } else {
        row = self.selectedLeaderboardWeek;
    }
    
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:row
                                                                                         inSection:0]];
    NSLog(@"refreshing data...");
}

- (void)layoutSubviews {

    [[CLWebImageCache cache] setCacheSize:PARTICIPANTS_PHOTOS_CACHE_COUNT];
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

    [self.tableView reloadData];
    // Set profile picture image
    __weak typeof(self) weakSelf = self;
    [[CLUser user] fetchProfilePictureWithCompletionBlock:^(UIImage *profilePic, NSError *error) {
        if (!error) {
            weakSelf.profilePictureImageView.image = profilePic ? profilePic : LEADERBOARD_VIEW_CONTROLLER_DEFAULT_PARTICIPANT_PHOTO_ICON;
        }
    }];
    self.profilePictureImageView.image = [CLUser user].profilePicture ? [CLUser user].profilePicture : LEADERBOARD_VIEW_CONTROLLER_DEFAULT_PARTICIPANT_PHOTO_ICON;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [CLUser user].firstName ?: @"", [CLUser user].lastName?:@""];
}

#pragma mark - Gesture recognizers and actions

- (IBAction)menuAction:(id)sender {
    NSLog(@"show menu");
    
    // Get menu view controller and present it modally
    CLSideMenuViewController *menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewControllerStoryboardID"];
    [menuViewController setDelegate:self];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self.navigationController presentViewController:menuViewController animated:NO completion:nil];
}

- (IBAction)swipeOnLeaderboardTable:(UISwipeGestureRecognizer *)sender {

    NSInteger row = 0;
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"get gesture right");
        if (self.collectionView.tag == CLLeaderboardModeDaily) {
            row = self.selectedLeaderboardDay - 1;
        } else {
            row = self.selectedLeaderboardWeek  - 1;
        }
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"get gesture Left");
        if (self.collectionView.tag == CLLeaderboardModeDaily) {
            row = self.selectedLeaderboardDay + 1;
        } else {
            row = self.selectedLeaderboardWeek  + 1;
        }
    }

    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:row
                                                                                         inSection:0]];
}

- (IBAction)tapOnLeaderboadModeSwitch:(SevenSwitch *)sender {
    if (sender.on) {
        NSLog(@"Switch to weeks mode");
        self.leaderboardModeSwitch.thumbImage = [UIImage imageNamed:@"switch_cup_blue"];
        self.leaderboardModeSwitch.onImage = [UIImage imageNamed:@"switch_steps_white"];

        self.collectionView.tag = CLLeaderboardModeWeekly;
        [self.collectionView reloadData];
        
        NSInteger days = ([[NSDate date] timeIntervalSinceDate:[CLUser user].currentMiniGame.startDate]) / 3600 / 24;
        self.selectedLeaderboardWeek = days / 7 + 1; // current week
        [self resetUserStatisticsAnimated:NO];

        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedLeaderboardWeek
                                                                                                  inSection:0]];
    } else {
        NSLog(@"Switch to days mode");
        self.leaderboardModeSwitch.thumbImage = [UIImage imageNamed:@"switch_steps_blue"];
        self.leaderboardModeSwitch.offImage = [UIImage imageNamed:@"switch_cup_white"];

        self.collectionView.tag = CLLeaderboardModeDaily;
        [self.collectionView reloadData];
        self.selectedLeaderboardDay = /*[[CLUser user] currentMiniGame].durationDays*/self.visibleDays + 1;


        [self resetUserStatisticsAnimated:NO];
        
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:/*[[CLUser user] currentMiniGame].durationDays*/self.visibleDays + 1
                                                                                              inSection:0]];
    }
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)profilePictureTapGesture:(UITapGestureRecognizer *)sender {
    // Scroll to user position in table view
    if (self.userLeadeboardPosition > 0 && self.userLeadeboardPosition <= [self.tableView numberOfRowsInSection:0]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.userLeadeboardPosition - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark - Setters and getters

- (void)setLeaderboardParticipantsArray:(NSArray *)leaderboardParticipantsArray {
    _leaderboardParticipantsArray = leaderboardParticipantsArray;

    // Update participants count
    [self.participantsCountLabel setText:[NSString stringWithFormat:@"%td", leaderboardParticipantsArray.count]
                       animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];

    // Update table view data
    [self.tableView reloadData];
    
}

#pragma mark - User interface management

- (void)resetUserStatisticsAnimated:(BOOL)animated {
    [self.userPositionLabel setText:@"..."
                  animationDuration:animated ? LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION : 0.0f];
    [self.userPositionSuffixLabel setText:nil
                        animationDuration:animated ? LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION : 0.0f];
//    [self.participantsCountLabel setText:[NSString stringWithFormat:@"%td", self.leaderboardParticipantsArray.count]
//                       animationDuration:animated ? LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION : 0.0f];
    [self.participantsCountLabel setText:@"..."
                       animationDuration:animated ? LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION : 0.0f];
    [self.userStepsLabel setText:@"0"
               animationDuration:animated ? LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION : 0.0f];
}

#pragma mark - Network request methods

- (void)fetchWeeklyBoardForWeekNumber:(NSInteger)week {
    // Start and show activity indicator
    [self.activityIndicatorView startAnimating];
    [UIView animateWithDuration:LEADERBOARD_VIEW_CONTROLLER_SHOW_HIDE_ACTIVITY_ANIMATION_DURATION animations:^{
        self.activityContainerView.alpha = 1.0f;
    }];

    // Send a request to get the leaderboard
    [CLUser fetchWeeklyboardForWeek:week fromCache:NO successBlock:^(id data, BOOL fromCache) {
        // Stop and hide activity indicator
        [self.activityIndicatorView stopAnimating];
        [UIView animateWithDuration:LEADERBOARD_VIEW_CONTROLLER_SHOW_HIDE_ACTIVITY_ANIMATION_DURATION animations:^{
            self.activityContainerView.alpha = 0.0f;
        }];

        // Check if we have a leaderboard list
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSLog(@"get leaderboard for week success");
            self.leaderboardParticipantsArray = data[@"weeklyBoard"];
        } else {
            // No data received
            NSLog(@"leaderboard could not be retrieved");
            [CLTextBoxView showWithTitle:@"" message:data[@"message"]];

        }
    }               failureBlock:^(id data, NSError *error) {
        NSLog(@"get leaderboard for day failed: %@", error.localizedDescription);

        // Stop and hide activity indicator
        [self.activityIndicatorView stopAnimating];
        [UIView animateWithDuration:LEADERBOARD_VIEW_CONTROLLER_SHOW_HIDE_ACTIVITY_ANIMATION_DURATION animations:^{
            self.activityContainerView.alpha = 0.0f;
        }];

    }];
}

- (void)fetchUserWeeklyRankingForWeekNumber:(NSInteger)week {
    // Send a request to user ranking
    [CLUser fetchUserWeeklyRanking:[CLUser user] forWeek:week fromCache:NO successBlock:^(id data, BOOL fromCache) {

        NSLog(@"get user ranking success: %@", data);

        // Check if we have user ranking statistics
        if ([data isKindOfClass:[NSDictionary class]] && data[USER_REST_PARAMATER_USER_RANKING] &&
                [data[USER_REST_PARAMATER_USER_RANKING] isKindOfClass:[NSArray class]] &&
                data[USER_REST_PARAMATER_USER_RANKING][0] &&
                [data[USER_REST_PARAMATER_USER_RANKING][0] isKindOfClass:[NSDictionary class]]) {

            NSDictionary *userStatisctics = data[USER_REST_PARAMATER_USER_RANKING][0];

            // Get user leaderboard position and steps
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            NSNumber *userLeaderboardPosition = [numberFormatter
                    numberFromString:userStatisctics[USER_REST_PARAMATER_LEADERBOARD_POSITION]];
            NSNumber *userSteps = userStatisctics[USER_REST_PARAMATER_TOTAL_STEPS];

            // Set user leaderboard position, label and suffix
            self.ofLabel.hidden = NO;
            self.participantsCountLabel.hidden = NO;
            if (![CLUser user].isHourlyRulePassed || ![CLUser user].isDailyRulePassed || ![CLUser user].isMaxStepsRulePassed) {
                [self setUserLeadeboardPosition:0];
                [self.userPositionLabel setText:@"F"
                              animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                [self.userPositionSuffixLabel setText:@""
                                    animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                [self.userStepsLabel setText:@"..."
                           animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
            } else if (![CLUser user].isDisqualified) {
                [self setUserLeadeboardPosition:[userLeaderboardPosition integerValue]];
                if ([[userLeaderboardPosition stringValue] isEqualToString:@"0"]) {
                    [self.userPositionLabel setText:@"----"
                                  animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                    [self.userPositionSuffixLabel setText:@""
                                        animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                    self.participantsCountLabel.text = @"";
                    self.ofLabel.hidden = YES;
                    self.participantsCountLabel.hidden = YES;
                } else {
                    [self.userPositionLabel setText:[userLeaderboardPosition stringValue]
                                  animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                    [self.userPositionSuffixLabel setText:[Utils getOrdinalNumberSuffix:userLeaderboardPosition]
                                        animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                }
            } else {
                [self setUserLeadeboardPosition:0];
                [self.userPositionLabel setText:@"DQ"
                              animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                [self.userPositionSuffixLabel setText:@""
                                    animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                // Set user total steps
                [self.userStepsLabel setText:@"..."
                           animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
            }
        } else {

            NSLog(@"no user ranking was found");

            // No user rankings, reset user statistics labels
            [self resetUserStatisticsAnimated:YES];
        }

    }
    failureBlock:^(id data, NSError *error) {
        NSLog(@"get user ranking for day failed: %@", error.localizedDescription);

        [CLTextBoxView showWithTitle:@"" message:data ? data[@"message"] : @"The Internet connection appears to be offline."];
        // Reset user statistics labels
        [self resetUserStatisticsAnimated:YES];
    }];
}

- (void)getLeaderboardFor:(CLUserLeaderboardDay)day {
    // Start and show activity indicator
    [self.activityIndicatorView startAnimating];
    [UIView animateWithDuration:LEADERBOARD_VIEW_CONTROLLER_SHOW_HIDE_ACTIVITY_ANIMATION_DURATION animations:^{
        self.activityContainerView.alpha = 1.0f;
    }];

    // Send a request to get the leaderboard
    [CLUser getLeaderboardForDay:day fromCache:NO successBlock:^(id data, BOOL fromCache) {

        // Stop and hide activity indicator
        [self.activityIndicatorView stopAnimating];
        [UIView animateWithDuration:LEADERBOARD_VIEW_CONTROLLER_SHOW_HIDE_ACTIVITY_ANIMATION_DURATION animations:^{
            self.activityContainerView.alpha = 0.0f;
        }];

        // Check if we have a leaderboard list
        if ([data isKindOfClass:[NSDictionary class]] &&
                data[USER_REST_PARAMATER_LEADERBOARD] &&
                [data[USER_REST_PARAMATER_LEADERBOARD] isKindOfClass:[NSArray class]]) {

            NSLog(@"get leaderboard for day success");

            //			// Set selected leaderboard day
            //			self.selectedLeaderboardDay = day;

            // Update leaderboard participants
            self.leaderboardParticipantsArray = data[USER_REST_PARAMATER_LEADERBOARD];

        } else {

            // No data received
            NSLog(@"leaderboard could not be retrieved");

            // Show failure error message
            [CLTextBoxView showWithTitle:@"" message:data[@"message"]];
        }
    } failureBlock:^(id data, NSError *error) {
        NSLog(@"get leaderboard for day failed: %@", error.localizedDescription);

        [CLTextBoxView showWithTitle:@"" message:data ? data[@"message"] : @"The Internet connection appears to be offline."];

        // Stop and hide activity indicator
        [self.activityIndicatorView stopAnimating];
        [UIView animateWithDuration:LEADERBOARD_VIEW_CONTROLLER_SHOW_HIDE_ACTIVITY_ANIMATION_DURATION animations:^{
            self.activityContainerView.alpha = 0.0f;
        }];

        // Show failure error message
    }];
}

- (void)getUserStatisticsFor:(CLUserLeaderboardDay)day {
    // Send a request to user ranking
    [CLUser getUserRanking:[CLUser user] forDay:day fromCache:NO successBlock:^(id data, BOOL fromCache) {

        NSLog(@"get user ranking success: %@", data);

        // Check if we have user ranking statistics
        if ([data isKindOfClass:[NSDictionary class]] && data[USER_REST_PARAMATER_USER_RANKING] &&
                [data[USER_REST_PARAMATER_USER_RANKING] isKindOfClass:[NSArray class]] &&
                data[USER_REST_PARAMATER_USER_RANKING][0] &&
                [data[USER_REST_PARAMATER_USER_RANKING][0] isKindOfClass:[NSDictionary class]]) {

            NSDictionary *userStatisctics = data[USER_REST_PARAMATER_USER_RANKING][0];

            // Get user leaderboard position and steps
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            NSNumber *userLeaderboardPosition = [numberFormatter
                    numberFromString:userStatisctics[USER_REST_PARAMATER_LEADERBOARD_POSITION]];
            NSNumber *userSteps = userStatisctics[USER_REST_PARAMATER_TOTAL_STEPS];

            // Set user leaderboard position, label and suffix
            self.ofLabel.hidden = NO;
            self.participantsCountLabel.hidden = NO;
            if (![CLUser user].isHourlyRulePassed || ![CLUser user].isDailyRulePassed || ![CLUser user].isMaxStepsRulePassed) {
                [self setUserLeadeboardPosition:0];
                [self.userPositionLabel setText:@"F"
                              animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                [self.userPositionSuffixLabel setText:@""
                                    animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                [self.userStepsLabel setText:@"..."
                           animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
            } else if (![CLUser user].isDisqualified) {
                [self setUserLeadeboardPosition:[userLeaderboardPosition integerValue]];

                if ([[userLeaderboardPosition stringValue] isEqualToString:@"0"]) {
                    [self.userPositionLabel setText:@"----"
                                  animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                    [self.userPositionSuffixLabel setText:@""
                                        animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                    self.participantsCountLabel.text = @"";
                    self.ofLabel.hidden = YES;
                    self.participantsCountLabel.hidden = YES;
                } else {
                    [self.userPositionLabel setText:[userLeaderboardPosition stringValue]
                                  animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                    [self.userPositionSuffixLabel setText:[Utils getOrdinalNumberSuffix:userLeaderboardPosition]
                                        animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                }

                // Set user total steps
                [self.userStepsLabel setText:[Utils getGroupedStringNumber:userSteps]
                           animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
            } else {
                [self setUserLeadeboardPosition:0];
                [self.userPositionLabel setText:@"DQ"
                              animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                [self.userPositionSuffixLabel setText:@""
                                    animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
                // Set user total steps
                [self.userStepsLabel setText:@"..."
                           animationDuration:LEADERBOARD_VIEW_CONTROLLER_USER_STATISTICS_ANIMATION_DURATION];
            }


        } else {

            NSLog(@"no user ranking was found");

            // No user rankings, reset user statistics labels
            [self resetUserStatisticsAnimated:YES];
        }

    }         failureBlock:^(id data, NSError *error) {

        NSLog(@"get user ranking for day failed: %@", error.localizedDescription);

        // Reset user statistics labels
        [self resetUserStatisticsAnimated:YES];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.leaderboardParticipantsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"LeaderboardTableViewCellDark";
    CLLeaderboardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[CLLeaderboardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    CLUser *user = [CLUser user];
    
    cell.profilePictureImageView.image = [UIImage imageNamed:@"NoPhotoIcon"];
    NSDictionary *participantData = self.leaderboardParticipantsArray[indexPath.row];
    [cell setLeaderboardPosition:participantData[USER_REST_PARAMATER_LEADERBOARD_POSITION] atIndexPath:indexPath];
    [cell setParticipantSteps:participantData[USER_REST_PARAMATER_TOTAL_STEPS] atIndexPath:indexPath];

    if (user.userId.integerValue != [participantData[USER_REST_PARAMATER_USER_ID] integerValue]) {
        [cell setParticipantFirstName:participantData[USER_REST_PARAMATER_FIRST_NAME]
                          andLastName:participantData[USER_REST_PARAMATER_LAST_NAME]];
        [cell setParticipantDeviceIcon:[participantData[USER_REST_PARAMATER_DEVICE_TYPE] integerValue]];
        [cell setProfilePictureURL:participantData[USER_REST_PARAMATER_PROFILE_PICTURE]];
    } else {
        [cell setParticipantFirstName:participantData[USER_REST_PARAMATER_FIRST_NAME]
                          andLastName:participantData[USER_REST_PARAMATER_LAST_NAME]];
        [cell setParticipantDeviceIcon:[participantData[USER_REST_PARAMATER_DEVICE_TYPE] integerValue]];
        [cell setProfilePictureURL:[CLUser user].profilePicture ? nil : [CLUser user].profilePictureURL];
        cell.profilePictureImageView.image = user.profilePicture;
    }



    // Download picture for the participant
    if ([cell.profilePictureURL length] != 0) {
        NSString *photoURLString = cell.profilePictureURL;

        // Check if we have a picture in the cache
        UIImage *cachedPhoto = [[CLWebImageCache cache] getImageForURL:photoURLString];
        if (cachedPhoto) {

            // Assign the photo
            cell.profilePictureImageView.image = cachedPhoto;
        } else {

            // Until download finishes, assign default profile picture
            cell.profilePictureImageView.image = LEADERBOARD_VIEW_CONTROLLER_DEFAULT_PARTICIPANT_PHOTO_ICON;

            // Download and cache the photo
            [UIImage downloadImageFromURL:photoURLString completion:^(UIImage *image, NSError *error) {
                if (!error && image) {

                    // Cache the photo
                    [[CLWebImageCache cache] addImage:image forURL:photoURLString];

                    // Assign the photo only if cell profile pictur URL hasn't changed
                    if ([cell.profilePictureURL isEqualToString:photoURLString]) {

                        [UIView transitionWithView:cell.profilePictureImageView
                                          duration:LEADERBOARD_VIEW_CONTROLLER_PARTICIPANT_THUMBNAIL_ANIMATION_DURATION
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:
                                                ^{
                                                    cell.profilePictureImageView.image = image;
                                                } completion:NULL];
                    }
                } else {
                    NSLog(@"an error occurred while downloading user profile picture: %@", [error localizedDescription]);
                }
            }];
        }
    } else if (!cell.profilePictureImageView.image) {

        // Default profile picture
        cell.profilePictureImageView.image = LEADERBOARD_VIEW_CONTROLLER_DEFAULT_PARTICIPANT_PHOTO_ICON;
    }

    // Return the configured cell
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == CLLeaderboardModeDaily) {
        return self.visibleDays + 3;//[[CLUser user] currentMiniGame].durationDays + 3;
    } else if (collectionView.tag == CLLeaderboardModeWeekly) {
        return self.visibleWeeks + 2;//[CLUser user].challengeDurationWeeks + 2;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CLLeaderboardDayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"leaderboardDayCell"
                                                                                         forIndexPath:indexPath];

    if (collectionView.tag == CLLeaderboardModeDaily) {

        if (indexPath.row < /*[[CLUser user] currentMiniGame].durationDays*/self.visibleDays +1) {
            if (indexPath.row == 0) {
                cell.dayLabel.text = @"";
            } else {
                cell.dayLabel.text = [NSString stringWithFormat:@"DAY %li", indexPath.row];
            }
        } else {
            if (indexPath.row == /*[[CLUser user] currentMiniGame].durationDays*/self.visibleDays +1) {
                cell.dayLabel.text = @"OVERALL";
            }
            if (indexPath.row == /*[[CLUser user] currentMiniGame].durationDays*/self.visibleDays +2) {
                cell.dayLabel.text = @"";
            }
        }
        if (self.selectedLeaderboardDay == indexPath.row) {
            [cell.dayLabel setFont:LEADERBOARD_VIEW_CONTROLLER_DAY_BUTTON_SELECTED_FONT];
            [cell.dayLabel setTextColor:LEADERBOARD_VIEW_CONTROLLER_DAY_BUTTON_SELECTED_COLOR];
        } else {
            [cell.dayLabel setFont:LEADERBOARD_VIEW_CONTROLLER_DAY_BUTTON_NORMAL_FONT];
            [cell.dayLabel setTextColor:LEADERBOARD_VIEW_CONTROLLER_DAY_BUTTON_NORMAL_COLOR];
        }

    } else if (collectionView.tag == CLLeaderboardModeWeekly) {
//        NSLog(@"%@", [CLUser user].challengeDurationWeeks);
        if (indexPath.row <= /*[CLUser user].challengeDurationWeeks*/ self.visibleWeeks) {
            if (indexPath.row == 0) {
                cell.dayLabel.text = @"";
            } else {
                cell.dayLabel.text = [NSString stringWithFormat:@"WEEK %li", indexPath.row];
            }
        } else {
            cell.dayLabel.text = @"";
        }

        if (self.selectedLeaderboardWeek == indexPath.row) {
            [cell.dayLabel setFont:LEADERBOARD_VIEW_CONTROLLER_DAY_BUTTON_SELECTED_FONT];
            [cell.dayLabel setTextColor:LEADERBOARD_VIEW_CONTROLLER_DAY_BUTTON_SELECTED_COLOR];
        } else {
            [cell.dayLabel setFont:LEADERBOARD_VIEW_CONTROLLER_DAY_BUTTON_NORMAL_FONT];
            [cell.dayLabel setTextColor:LEADERBOARD_VIEW_CONTROLLER_DAY_BUTTON_NORMAL_COLOR];
        }
    }




    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == CLLeaderboardModeDaily) {
//        if (indexPath.row != self.selectedLeaderboardDay) {
            CLUserLeaderboardDay dayIndex;

            if (indexPath.row <= /*[[CLUser user] currentMiniGame].durationDays*/self.visibleDays) {
                dayIndex = indexPath.row;
            }
            else {
                dayIndex = kCLUserLeaderboardOverall;
            }

            if (indexPath.row - 1 >= 0 && indexPath.row < /*[[CLUser user] currentMiniGame].durationDays*/self.visibleDays + 2 ) {
                [self getLeaderboardFor:dayIndex];
                [self getUserStatisticsFor:dayIndex];

                self.selectedLeaderboardDay = indexPath.row;
                [collectionView reloadItemsAtIndexPaths:collectionView.indexPathsForVisibleItems];

                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]
                                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                    animated:YES];
            }
//        }
    } else if (collectionView.tag == CLLeaderboardModeWeekly) {

        if (indexPath.row - 1 >= 0 && indexPath.row < /*[CLUser user].challengeDurationWeeks*/self.visibleWeeks + 1 ) {
            self.selectedLeaderboardWeek = indexPath.row;
            [collectionView reloadItemsAtIndexPaths:collectionView.indexPathsForVisibleItems];
            [self fetchWeeklyBoardForWeekNumber:self.selectedLeaderboardWeek];
            [self fetchUserWeeklyRankingForWeekNumber:self.selectedLeaderboardWeek];

            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                animated:YES];
        }
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 3, 20.f);
}

- (IBAction)buttonPopupMenuAction:(UIButton *)sender
{
    
}

#pragma mark - Storyboard navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark - View controller's memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    NSLog(@"memory warning received");
}

#pragma mark - FloatingMenuDelegate

- (void)didSelectMenuOptionAtIndex:(NSInteger)row
{
    if (row == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - CLSideMenuViewControllerDelegate

- (void)menuViewController:(CLSideMenuViewController *)menuViewController signOutButtonPressed:(id)signOutButton
{
    [[CLUser user] logOut];
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[CLHomeViewController class]]) {
            [[NSNotificationCenter defaultCenter] removeObserver:controller];
        }
    }
    [menuViewController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)menuViewController:(CLSideMenuViewController *)menuViewController editProfile:(id)editProfileButton
{
    [self performSegueWithIdentifier:@"SegueToEditProfile" sender:self];
    [menuViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)menuViewController:(CLSideMenuViewController *)menuViewController gameRules:(id)gameRulesButton
{
    [menuViewController dismissViewControllerAnimated:NO completion:nil];
    
    CLGameRulesViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameRulesModalID"];
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    modalViewController.transitioningDelegate = self;
    [self presentViewController:modalViewController animated:YES completion:nil];
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
