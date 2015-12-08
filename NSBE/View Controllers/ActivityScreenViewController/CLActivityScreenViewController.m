//
//  CLActivityScreenViewController.m
//  NSBE
//

#import "CLActivityScreenViewController.h"
#import "UIImage+BlurAndDarken.h"
#import "CLPushNotification.h"
#import "CLActivityScreenTableViewCell.h"
#import "CLActivityScreenTableSectionHeaderView.h"
#import "CLNotifications.h"

typedef NS_ENUM(NSInteger, CLActivitiesTableTag) {
    CLActivitiesTableTagMyFitclub,
    CLActivitiesTableTagTheWorld,
};

@interface CLActivityScreenViewController () <UITableViewDelegate, UITableViewDataSource>
@property(weak, nonatomic) IBOutlet UITableView *pushActivitiesTableView;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *underScoreViewLeadingConstraint;
@property(weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *theWorldButton;
@property (weak, nonatomic) IBOutlet UIButton *myFitclubButton;
@property (weak, nonatomic) IBOutlet UIView *underscoreView;
@property (weak, nonatomic) IBOutlet UIView *noActivitiesView;

@end

@implementation CLActivityScreenViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![[CLNotifications sharedInstance] myFitClubNotificationsGroupedByDate].count) {
        self.noActivitiesView.hidden = NO;
    } else {
        self.noActivitiesView.hidden = YES;
    }
    
    self.pushActivitiesTableView.tag = CLActivitiesTableTagMyFitclub;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self customize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 112.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CLActivityScreenTableSectionHeaderView *sectionHeaderView = [[CLActivityScreenTableSectionHeaderView alloc] initForTableView:tableView];
    
    if (self.pushActivitiesTableView.tag == CLActivitiesTableTagTheWorld) {
        NSDictionary *groupedNotifications = [[CLNotifications sharedInstance] theWorldNotificationsGroupedByDate][(NSUInteger) section];
        [sectionHeaderView setLabelFormattedTextWithDateString:[[groupedNotifications allKeys] firstObject]];;
        
    } else if (self.pushActivitiesTableView.tag == CLActivitiesTableTagMyFitclub) {
        NSDictionary *groupedNotifications = [[CLNotifications sharedInstance] myFitClubNotificationsGroupedByDate][(NSUInteger) section];
        [sectionHeaderView setLabelFormattedTextWithDateString:[[groupedNotifications allKeys] firstObject]];;
    }

    return sectionHeaderView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.pushActivitiesTableView.tag == CLActivitiesTableTagTheWorld) {
        return [[CLNotifications sharedInstance] theWorldNotificationsGroupedByDate].count;
    } else if (self.pushActivitiesTableView.tag == CLActivitiesTableTagMyFitclub) {
        return [[CLNotifications sharedInstance] myFitClubNotificationsGroupedByDate].count;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.pushActivitiesTableView.tag == CLActivitiesTableTagTheWorld) {
        NSDictionary *groupedNotificationsWithKey = [[CLNotifications sharedInstance] theWorldNotificationsGroupedByDate][(NSUInteger) section];
        NSArray *notifications = [[groupedNotificationsWithKey allValues] firstObject];
        return notifications.count;
    } else if (self.pushActivitiesTableView.tag == CLActivitiesTableTagMyFitclub) {
        NSDictionary *groupedNotificationsWithKey = [[CLNotifications sharedInstance] myFitClubNotificationsGroupedByDate][(NSUInteger) section];
        NSArray *notifications = [[groupedNotificationsWithKey allValues] firstObject];
        return notifications.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"activityCellReuseIdentifier";
    NSArray *notifications;
    
    CLActivityScreenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[CLActivityScreenTableViewCell alloc] init];
    }

    if (self.pushActivitiesTableView.tag == CLActivitiesTableTagTheWorld) {
        NSDictionary *groupedNotificationsWithKey = [[CLNotifications sharedInstance] theWorldNotificationsGroupedByDate][(NSUInteger) indexPath.section];
        notifications = [[groupedNotificationsWithKey allValues] firstObject];
    } else if (self.pushActivitiesTableView.tag == CLActivitiesTableTagMyFitclub) {
        NSDictionary *groupedNotificationsWithKey = [[CLNotifications sharedInstance] myFitClubNotificationsGroupedByDate][(NSUInteger) indexPath.section];
        notifications = [[groupedNotificationsWithKey allValues] firstObject];
    }

    CLPushNotification *pushNotification = notifications[(NSUInteger) indexPath.row];
    
    [cell configureCellWithPushNotification:pushNotification
                                  indexPath:indexPath];
    return cell;
}

#pragma mark - IBActions

- (IBAction)tapOnMyFitClubSectionButton:(UIButton *)sender {
    self.underScoreViewLeadingConstraint.constant = 0.0f;
    self.pushActivitiesTableView.tag = CLActivitiesTableTagMyFitclub;
    self.myFitclubButton.titleLabel.alpha = 1.0f;
    self.theWorldButton.titleLabel.alpha = 0.5f;
    [self.pushActivitiesTableView reloadData];
    
    if (![[CLNotifications sharedInstance] myFitClubNotificationsGroupedByDate].count) {
        self.noActivitiesView.hidden = NO;
    } else {
        self.noActivitiesView.hidden = YES;
    }
}

- (IBAction)tapOnTheWorldSectionButton:(UIButton *)sender {
    self.underScoreViewLeadingConstraint.constant = sender.frame.size.width;
    self.pushActivitiesTableView.tag = CLActivitiesTableTagTheWorld;
    self.myFitclubButton.titleLabel.alpha = 0.5f;
    self.theWorldButton.titleLabel.alpha = 1.0f;
    [self.pushActivitiesTableView reloadData];
    
    
    if (![[CLNotifications sharedInstance] theWorldNotificationsGroupedByDate].count) {
        self.noActivitiesView.hidden = NO;
    } else {
        self.noActivitiesView.hidden = YES;
    }
}

#pragma mark - Private Methods

- (void)customize {
    self.myFitclubButton.titleLabel.alpha = 1.0f;
    self.theWorldButton.titleLabel.alpha = 0.5f;
    [self setNavigationBarOpacity];
    [self setCustomNavigationBackButton];
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

- (void)setCustomNavigationBarTitle {
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
            NSFontAttributeName : [UIFont fontWithName:@"Geomanist-Regular"
                                                  size:22.0f]
    }];
}

@end
