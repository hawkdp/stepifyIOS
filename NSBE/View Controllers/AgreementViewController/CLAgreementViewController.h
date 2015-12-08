//
//  CLAgreementViewController.h
//  Stepify
//
//  Created by Vasya Pupkin on 10/7/15.
//  Copyright © 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CLAgreementControllerMode) {
    CLAgreementControllerModePrivacy,
    CLAgreementControllerModeConditions
};

@interface CLAgreementViewController : UIViewController

@property (nonatomic, assign) CLAgreementControllerMode displayMode;

@end
