//
//  CLEditProfileScreensViewController.h
//  UPMC
//
//  Created by Alexey Titov on 28.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLEditProfileScreensViewController;

@protocol CLEditProfileScreensViewControllerDelegate <NSObject>

- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeProfilePicture:(UIImage *)profilePicture;
- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeFirstName:(NSString *)firstName lastName:(NSString *)lastName;
- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeEmail:(NSString *)email;
- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeGender:(NSString *)gender;
- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeAge:(NSNumber *)age birthdate:(NSDate *)birthdate;
- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeHeightFeet:(NSNumber *)feet inches:(NSNumber *)inches;
- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller didChangeWeight:(NSString *)weight;

- (void)editProfileScreensViewController:(CLEditProfileScreensViewController *)controller activateTextField:(UITextField *)field;

@end

@interface CLEditProfileScreensViewController : UIViewController

@property (nonatomic, weak) id<CLEditProfileScreensViewControllerDelegate> delegate;

@end
