//
//  CLBirthdateModalViewController.h
//  NSBE
//
//  Created by Alexey Titov on 24.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLBirthdateModalViewController;

@protocol CLBirthdateModalViewControllerDelegate <NSObject>

- (void)birthdateModalViewController:(CLBirthdateModalViewController *)birthdateModalViewController didSelectAge:(NSNumber *)age birthdate:(NSDate *)birthdate;

@end

@interface CLBirthdateModalViewController : UIViewController

@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSDate *birthdate;

@property (nonatomic, weak) id<CLBirthdateModalViewControllerDelegate> delegate;

@end
