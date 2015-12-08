//
//  CLHeightModalViewController.h
//  NSBE
//
//  Created by Alexey Titov on 23.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLHeightModalViewController;

@protocol CLHeightModalViewControllerDelegate <NSObject>

- (void)heightModalViewController:(CLHeightModalViewController *)heightModalViewController didSelectHeightFeet:(NSNumber *)heightFeet heightInches:(NSNumber *)heightInches;

@end

@interface CLHeightModalViewController : UIViewController

@property (nonatomic, strong) NSNumber *heightFeet;
@property (nonatomic, strong) NSNumber *heightInches;

@property (nonatomic, weak) id<CLHeightModalViewControllerDelegate> delegate;

@end
