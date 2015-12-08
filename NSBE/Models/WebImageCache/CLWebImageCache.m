//
//  CLWebImageCache.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/24/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLWebImageCache.h"

@interface CLWebImageCache ()

@property (nonatomic, strong) NSMutableArray *imagesArray;

@property (nonatomic, strong) NSMutableDictionary *imagesDictionary;

@end

@implementation CLWebImageCache

#pragma mark - Declared dynamic properties

@dynamic imagesArray;
@dynamic imagesDictionary;

#pragma mark - Web image cache singleton

+ (CLWebImageCache *)cache
{
	static CLWebImageCache *sharedInstance;
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		
		if (!sharedInstance) {
			
			// Create a new instance of web image cache
			sharedInstance = [[CLWebImageCache alloc] init];
			
			// Set default cache size
			sharedInstance.cacheSize = kWebImageDefaultCacheSize;
		}
	});
	
	return sharedInstance;
}

#pragma mark - Setters and getters

- (NSMutableArray *)imagesArray
{
	static NSMutableArray *imagesArrayInstance;
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		
		// Create a shared instace of mutable array
		imagesArrayInstance = [[NSMutableArray alloc] initWithCapacity:self.cacheSize];
	});
	return imagesArrayInstance;
}

- (NSMutableDictionary *)imagesDictionary
{
	static NSMutableDictionary *imagesDictionaryInstance;
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		
		// Create a shared instace of mutable dictionary
		imagesDictionaryInstance = [[NSMutableDictionary alloc] initWithCapacity:self.cacheSize];
	});
	return imagesDictionaryInstance;
}

#pragma mark - Web image cache management

- (UIImage *)getImageForURL:(NSString *)URLString
{
	// Sanity check
	if (!URLString) {
		return nil;
	}
	return [self.imagesDictionary valueForKey:URLString];
}

- (void)addImage:(UIImage *)photo forURL:(NSString *)URLString
{
	// Sanity check
	if (!photo || !URLString) {
		
		// Nothing to do
		return;
	}
	
	// Check if cache is full
	if (self.imagesArray.count >= self.cacheSize) {
		do {
			// Get first cached photo and remove it from the array
			NSString *firstPhotoURL = [self.imagesArray firstObject];
			[self.imagesArray removeObjectAtIndex:0];
			
			// Remove key from dictionary
			if (firstPhotoURL) {
				[self.imagesDictionary removeObjectForKey:firstPhotoURL];
			}
			
			// Delete photos from cache until the size has space for one more photo
		} while (self.imagesArray.count >= self.cacheSize);
	}
	
	// Add photo to the dictionary and array
	[self.imagesArray addObject:URLString];
	[self.imagesDictionary setObject:photo forKey:URLString];
	
	NSLog(@"new image has been added to the cache, new size: %td [%td] [%g kbytes]",
		  self.imagesArray.count, self.imagesDictionary.count, (self.imagesArray.count * photo.size.width *
																photo.size.height * 4) / 1024.0f);
}

- (void)clearAllCache
{
	[self.imagesArray removeAllObjects];
	[self.imagesDictionary removeAllObjects];
}

@end
