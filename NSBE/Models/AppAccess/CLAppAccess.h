//
//  CLAppAccess.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/22/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Type defines and enums

#define kUserDefaultsAppAccessGrantedKey @"userDefaultsAppAccessGrantedKey"

@interface CLAppAccess : NSObject

#pragma mark - App access class methods

+ (void)askAccessPassword;

#pragma mark - User defaults management methods

+ (BOOL)appAccessGranted;

+ (void)setAppAccessGranted:(BOOL)granted;

@end
