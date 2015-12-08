//
//  CLKeyboardViewController.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/27/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLKeyboardViewController.h"

#define KEYBOARD_OFFSET_CHANGE_DEVIATION 5.0f

@implementation CLKeyboardViewController

#pragma mark - View controller's lifecycle methods

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// Register observer for keyboard the events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	// Reset scroll view content size and offset
	if (self.isKeyboardVisible) {
		[self keyboardWillHide:nil];
	}
	
	// Remove observer
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Gesture recognizers and actions

- (IBAction)viewTapGesture:(UITapGestureRecognizer *)sender
{
	[self.view endEditing:YES];
}

#pragma mark - Notification methods

- (void)keyboardWillShow:(NSNotification *)notification
{	
	// Get the size of the keyboard
	NSDictionary *userInfo = [notification userInfo];
	CGSize oldKeyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	CGSize newKeyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	CGSize contentSize = self.view.frame.size;
	
	// Set the size of the new content considering keyboard size
	contentSize.height += newKeyboardSize.height;
	[self.scrollView setContentSize:contentSize];
	
	// Calculate old and new content offset
	CGPoint newContentOffset = self.contentOffsetFromBottom ? CGPointMake(self.contentOffsetKeyboardVisible.x,
																	   self.contentOffsetKeyboardVisible.y -
																	   (self.view.frame.size.height - newKeyboardSize.height)) :
																		self.contentOffsetKeyboardVisible;
	CGPoint oldContentOffset = CGPointMake(newContentOffset.x, newContentOffset.y - newKeyboardSize.height +
										   oldKeyboardSize.height);
	// Animate new changes
	if (!self.isKeyboardVisible || (self.isKeyboardVisible && fabsf(self.scrollView.contentOffset.y -
																	oldContentOffset.y) < KEYBOARD_OFFSET_CHANGE_DEVIATION)) {
		[self.scrollView setContentOffset:newContentOffset.y >= 0.0f ? newContentOffset :
		 CGPointMake(newContentOffset.x, 0.0f) animated:YES];
	}

	// Keyboard is now visible
	self.isKeyboardVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	// If the keyboard is invisible, return
	if (!self.isKeyboardVisible)
		return;
	
	// Get the size of the new content offset
	CGPoint currentOffset = [self.scrollView contentOffset];
	
	// Animate changes
	[self.scrollView setContentSize:CGSizeMake(0.0f, 0.0f)];
	[self.scrollView setContentOffset:currentOffset animated:NO];
	[self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
	
	// Keyboard is now invisible
	self.isKeyboardVisible = NO;
}

@end
