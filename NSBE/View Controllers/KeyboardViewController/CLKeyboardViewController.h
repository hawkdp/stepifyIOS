//
//  CLKeyboardViewController.h
//  NSBE
//
//  Created by Iulian Corcoja on 1/27/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLKeyboardViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) CGPoint contentOffsetKeyboardVisible;
@property (nonatomic, assign) BOOL contentOffsetFromBottom;
@property (nonatomic, assign) BOOL isKeyboardVisible;

@end
