//
//  CLProfilePicturePicker.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/16/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLProfilePicturePicker : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
											  UIActionSheetDelegate>

#pragma mark - Profile picture picker singleton

+ (CLProfilePicturePicker *)sharedInstance;

#pragma mark - Profile picture picker instance methods

- (void)pickProfilePictureInViewController:(UIViewController *)viewController
						  showDeleteOption:(BOOL)deleteOption
								completion:(void (^)(UIImage *image, BOOL deleted))completion;

@end
