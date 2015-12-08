//
//  CLProfilePicturePicker.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/16/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLProfilePicturePicker.h"
#import "NSObject+AssociatedObject.h"
#import "UIActionSheet+Blocks.h"
#import "UIImage+Resize.h"
#import "Constants.h"

#pragma mark - Constant defines

#define kCompletionBlockKey @"completionBlock"

@implementation CLProfilePicturePicker

#pragma mark - Profile picture picker singleton

+ (CLProfilePicturePicker *)sharedInstance
{
	static CLProfilePicturePicker *sharedInstance;
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		
		// Create a shared instace of profile picture picker
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}

#pragma mark - Profile picture picker instance methods

- (void)pickProfilePictureInViewController:(UIViewController *)viewController
						  showDeleteOption:(BOOL)deleteOption
								completion:(void (^)(UIImage *image, BOOL deleted))completion
{
	// Create available options for image picker
	NSMutableArray *options = [NSMutableArray array];
	NSMutableArray *actions = [NSMutableArray array];
	
	// Take a photo action
	if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
		void (^takePhoto)() = ^void() {
			
			// Create image picker controller
			UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
			
			// Set a dictionary with the provided information as associated object to the image picker
			if (completion) {
				[imagePickerController setAssociatedObject:@{kCompletionBlockKey : [completion copy]}];
			}
			
			// Show camera
			imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			imagePickerController.delegate = self;
			imagePickerController.allowsEditing = YES;
			[viewController presentViewController:imagePickerController animated:YES completion:nil];
		};
		[options addObject:NSLocalizedString(@"TakePicture", nil)];
		[actions addObject:[takePhoto copy]];
	}
	
	// Choose from library action
	void (^chooseFromLibrary)() = ^void() {
		
		// Create image picker controller
		UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
		
		// Set a dictionary with the provided information as associated object to the image picker
		if (completion) {
			[imagePickerController setAssociatedObject:@{kCompletionBlockKey : [completion copy]}];
		}
		
		// Show photo library
		imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePickerController.delegate = self;
		imagePickerController.allowsEditing = YES;
		[viewController presentViewController:imagePickerController animated:YES completion:nil];
	};
	[options addObject:NSLocalizedString(@"ChooseFromLibrary", nil)];
	[actions addObject:[chooseFromLibrary copy]];
	
	// Delete photo action
	if (deleteOption) {
		void (^deletePhoto)() = ^void() {
			
			// Call completion block with deleted set to YES
			completion(nil, YES);
		};
		[options addObject:NSLocalizedString(@"DeletePicture", nil)];
		[actions addObject:[deletePhoto copy]];
	}
	
	// Show action sheet to choose from available options
	[UIActionSheet showInView:[[[UIApplication sharedApplication] delegate] window]
					withTitle:nil
			cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
	   destructiveButtonTitle:nil
			otherButtonTitles:options tapBlock:
	 ^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
		 if (buttonIndex < options.count) {
			 void (^action)() = actions[buttonIndex];
			 action();
		 }
	 }];
}

#pragma mark - Image picker controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
	
	// Resize image
	editedImage = [editedImage thumbnailImage:PROFILE_PICTURE_THUMBNAIL_SIZE
							transparentBorder:0
								 cornerRadius:0
						 interpolationQuality:kCGInterpolationHigh];
	
	// Call completion block is available
	NSDictionary *associatedInfo = [picker associatedObject];
	if (associatedInfo[kCompletionBlockKey]) {
		((void (^)(UIImage *image, BOOL deleted)) associatedInfo[kCompletionBlockKey])(editedImage, NO);
	}

	// Dismiss image picker view controller
	[picker dismissViewControllerAnimated:YES completion:nil];
}

@end
