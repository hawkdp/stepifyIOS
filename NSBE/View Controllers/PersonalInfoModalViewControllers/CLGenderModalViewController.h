//
//  CLGenderModalViewController.h
//  NSBE
//
//  Created by Alexey Titov on 23.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLGenderModalViewController;

@protocol CLGenderModalViewControllerDelegate <NSObject>

- (void)genderModalViewController:(CLGenderModalViewController *)genderModalViewController didSelectMaleOption:(BOOL)maleOption;

@end

@interface CLGenderModalViewController : UIViewController

@property (nonatomic, assign) BOOL isFemaleOptionSelected;

@property (nonatomic, weak) id<CLGenderModalViewControllerDelegate> delegate;

@end
