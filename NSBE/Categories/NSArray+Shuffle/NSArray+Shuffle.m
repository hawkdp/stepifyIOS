//
//  NSArray+Shuffle.m
//  GratitudeJournal
//
//  Created by Iulian Corcoja on 10/9/14.
//
//

#import "NSArray+Shuffle.h"

@implementation NSArray (Shuffle)

- (NSArray *)shuffledArray
{
	// Create a mutable copy of the array.
	NSMutableArray *shuffledArray = [self mutableCopy];
	
	// Shuffle array.
	for (NSUInteger i = shuffledArray.count - 1; i > 0; i--) {
		NSUInteger n = arc4random_uniform((unsigned int) i + 1);
		[shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
	}
	
	// Returns the shuffled array.
	return shuffledArray;
}

@end
