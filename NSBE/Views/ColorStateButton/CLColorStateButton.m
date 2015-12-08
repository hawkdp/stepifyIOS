//
//  CLColorStateButton.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/27/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLColorStateButton.h"

@interface CLColorStateButton ()

@property (nonatomic, strong) NSMutableDictionary *backgroundStates;

@end

@implementation CLColorStateButton

#pragma mark - View's lifecycle methods

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		// Initialization code
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	// Set normal state background color
	self.backgroundStates[@(UIControlStateNormal)] = self.backgroundColor;
}

#pragma mark - Button delegate methods

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
	self.backgroundStates[@(state)] = backgroundColor;
	
	if (self.backgroundColor == nil)
		[self setBackgroundColor:backgroundColor];
}

- (UIColor *)backgroundColorForState:(UIControlState)state
{
	return self.backgroundStates[@(state)];
}

#pragma mark - Setters and getters

- (NSMutableDictionary *)backgroundStates
{
	if (!_backgroundStates) {
		
		// Lazy instantiation
		_backgroundStates = [[NSMutableDictionary alloc] init];
	}
	return _backgroundStates;
}

- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	
	if (enabled) {
		[self transitionToState:UIControlStateNormal];
	} else {
		[self transitionToState:UIControlStateDisabled];
	}
}

#pragma mark - Touche events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	[self transitionToState:UIControlStateHighlighted];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	[self transitionToState:UIControlStateNormal];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	[self transitionToState:UIControlStateNormal];
}

#pragma mark - Transition between states

- (void)transitionToState:(UIControlState)controlState
{
	UIColor *color = self.backgroundStates[@(controlState)];

	// Check if color exists
	if (color) {
		
		// Create transition and add it to the layer
		CATransition *animation = [CATransition animation];
		[animation setType:kCATransitionFade];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		[self.layer addAnimation:animation forKey:@"EaseOut"];
		self.backgroundColor = color;
	}
}

@end
