//
//  CLRegisterViewController.h
//  NSBE
//
//  Created by Iulian Corcoja on 1/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLKeyboardViewController.h"
#import "CLUser.h"
#import "CLUser+API.h"

typedef NS_ENUM(NSInteger, CLRegisterViewControllerType) {
	CLRegisterViewControllerTypeStep1 = 0,
	CLRegisterViewControllerTypeStep2 = 1
};

@interface CLRegisterViewController : CLKeyboardViewController <UITextFieldDelegate, UIPickerViewDelegate,
                                                                UIPickerViewDataSource>

@property (nonatomic, assign) CLRegisterViewControllerType type;

@property (nonatomic, assign) BOOL facebookRegistration;

@end
