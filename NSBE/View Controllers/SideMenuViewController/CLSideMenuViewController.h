//
//  CLSideMenuViewController.h
//  NSBE
//

@import UIKit;
@protocol CLSideMenuViewControllerDelegate;

@interface CLSideMenuViewController : UIViewController

@property (nonatomic, weak) id<CLSideMenuViewControllerDelegate> delegate;

@end

@protocol CLSideMenuViewControllerDelegate <NSObject>
@required
- (void)menuViewController:(CLSideMenuViewController *)menuViewController homeMenuPressed:(id)homeMenu;
- (void)menuViewController:(CLSideMenuViewController *)menuViewController challengeDetailsMenuPressed:(id)challengeDetailsMenu;
- (void)menuViewController:(CLSideMenuViewController *)menuViewController syncingStepsMenuPressed:(id)syncingStepsMenu;
- (void)menuViewController:(CLSideMenuViewController *)menuViewController prizesMenuPressed:(id)prizesMenu;
- (void)menuViewController:(CLSideMenuViewController *)menuViewController cardioLegendMenuPressed:(id)prizesMenu;
- (void)menuViewController:(CLSideMenuViewController *)menuViewController signOutButtonPressed:(id)signOutButton;

- (void)menuViewController:(CLSideMenuViewController *)menuViewController editProfile:(id)editProfileButton;
- (void)menuViewController:(CLSideMenuViewController *)menuViewController gameRules:(id)gameRulesButton;
@end