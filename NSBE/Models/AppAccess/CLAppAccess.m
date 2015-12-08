//
//  CLAppAccess.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/22/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLAppAccess.h"
#import "UIAlertView+Blocks.h"
#import "Constants.h"

@implementation CLAppAccess

#pragma mark - App access class methods

+ (void)askAccessPassword
{
	[CLAppAccess askAccessPasswordWithMessage:NSLocalizedString(@"EnterPassword", nil)];
}

+ (void)askAccessPasswordWithMessage:(NSString *)message
{
	// An alert view with obscure text field is shown for entering the application's password. If the password is
	// incorrect, the user is asked again for the password. Application cannot be accessed until the user enters
	// the correct password and once he does this, the password won't be asked anymore.
	if (![CLAppAccess appAccessGranted]) {
		
		// Ask for password
//		[[[UIAlertView showWithTitle:nil message:message style:UIAlertViewStyleSecureTextInput cancelButtonTitle:nil
//				   otherButtonTitles:@[NSLocalizedString(@"Ok", nil)] tapBlock:
//		   ^(UIAlertView *alertView, NSInteger buttonIndex) {
//			   
//			   UITextField *textField = [alertView textFieldAtIndex:0];
//			   
//			   // Check if the password is correct
//			   if ([textField.text caseInsensitiveCompare:APP_PASSWORD] == NSOrderedSame) {
//				   
				   // Password is correct, save app access as granted
				   [CLAppAccess setAppAccessGranted:YES];
//			   } else {
//				   
//				   // Password is incorrect, promt user to try again
//				   [CLAppAccess askAccessPasswordWithMessage:NSLocalizedString(@"RetryEnterPassword", nil)];
//			   }
//		   }] textFieldAtIndex:0] setKeyboardAppearance:UIKeyboardAppearanceDark];
	}
}

#pragma mark - User defaults management methods

+ (BOOL)appAccessGranted
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:kUserDefaultsAppAccessGrantedKey];
}

+ (void)setAppAccessGranted:(BOOL)granted
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:granted forKey:kUserDefaultsAppAccessGrantedKey];
	[userDefaults synchronize];
}

@end
