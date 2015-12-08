//
//  CLWeightModalViewController.h
//  NSBE
//
//  Created by Alexey Titov on 24.07.15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLWeightModalViewController;

@protocol CLWeightModalViewControllerDelegate <NSObject>

- (void)weightModalViewController:(CLWeightModalViewController *)weightModalViewController didSelectWeight:(NSString *)weight;

@end

@interface CLWeightModalViewController : UIViewController

@property (nonatomic, strong) NSString *weight;

@property (nonatomic, weak) id<CLWeightModalViewControllerDelegate> delegate;

@end
