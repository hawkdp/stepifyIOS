//
//  NSObject+AssociatedObject.m
//  NSBE
//
//  Created by Iulian Corcoja on 5/1/14.
//  Copyright (c) 2014 Adelante Consulting. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+AssociatedObject.h"

@implementation NSObject (AssociatedObject)

@dynamic associatedObject;

- (void)setAssociatedObject:(id)object
{
	// Sanity check
	if (!object) {
		return;
	}
	objc_setAssociatedObject(self, @selector(associatedObject), object, OBJC_ASSOCIATION_RETAIN);
}

- (id)associatedObject
{
	return objc_getAssociatedObject(self, @selector(associatedObject));
}

@end
