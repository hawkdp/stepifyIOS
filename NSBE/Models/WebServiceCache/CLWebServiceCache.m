//
//  CLWebServiceCache.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/13/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "CLWebServiceCache.h"

#pragma mark - Properties dictionary key names

#define kCacheDateKey @"cacheDate"
#define kCacheExpirationTimeKey @"cacheExpirationTime"
#define kDataKey @"data"

@implementation NSDictionary (WebServiceCache)

@dynamic data;
@dynamic cacheDate;
@dynamic cacheExpirationTime;

#pragma mark - Web service all the cache

+ (NSMutableDictionary *)cache
{
	static NSMutableDictionary *cache;
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		
		if (!cache) {
			// The web service cache data instance hasn't been created yet, so try to retrieve the cache
			// from user defaults
			NSDictionary *webServiceCacheData = [CLWebServiceCache loadCacheFromUserDefaults];
			
			// If web service cache data was loaded from user defaults, use it, otherwise create a new cache instace
			cache = webServiceCacheData ? [webServiceCacheData mutableCopy] : [[NSMutableDictionary alloc] init];
		}
	});
	
	return cache;
}

#pragma mark - Setters and getters

- (NSDate *)cacheDate
{
	return self[kCacheDateKey];
}

- (void)setCacheDate:(NSDate *)cacheDate
{
	// Do nothing
}

- (NSTimeInterval)cacheExpirationTime
{
	return [self[kCacheExpirationTimeKey] doubleValue];
}

- (void)setCacheExpirationTime:(NSTimeInterval)cacheExpirationTime
{
	// Do nothing
}

- (id)data
{
	return self[kDataKey];
}

- (void)setData:(id)data
{
	// Do nothing
}

#pragma mark - Web service cache instance methods

- (BOOL)cacheExpired
{
	return [[NSDate date] timeIntervalSinceDate:self.cacheDate] > self.cacheExpirationTime;
}

- (NSTimeInterval)timeUntilExpiration
{
	return self.cacheExpirationTime - [[NSDate date] timeIntervalSinceDate:self.cacheDate];
}

#pragma mark - Web service cache class methods

+ (void)addCacheData:(id)data withCacheExpirationTime:(NSTimeInterval)expirationTime forKey:(id)key
{
	NSMutableDictionary *mutableWebServiceCache = [NSMutableDictionary dictionaryWithDictionary:
												   @{kCacheExpirationTimeKey : @(expirationTime),
													 kCacheDateKey : [NSDate date]}];
	// Add data if available
	if (data) {
		mutableWebServiceCache[kDataKey] = data;
	}
	
	// Add web service cache to cache pool
	[[CLWebServiceCache cache] setObject:[NSDictionary dictionaryWithDictionary:mutableWebServiceCache] forKey:key];
}

+ (void)addCacheData:(id)data forDate:(NSDate *)date withCacheExpirationTime:(NSTimeInterval)expirationTime forKey:(id)key
{
	NSMutableDictionary *mutableWebServiceCache = [NSMutableDictionary dictionaryWithDictionary:
												   @{kCacheExpirationTimeKey : @(expirationTime),
													 kCacheDateKey : (date ?: [NSDate date])}];
	// Add data if available
	if (data) {
		mutableWebServiceCache[kDataKey] = data;
	}
	
	// Add web service cache to cache pool
	[[CLWebServiceCache cache] setObject:[NSDictionary dictionaryWithDictionary:mutableWebServiceCache] forKey:key];
}

+ (CLWebServiceCache *)getCacheDataForKey:(id)key
{
	return [[CLWebServiceCache cache] objectForKey:key];
}

+ (CLWebServiceCache *)deleteCacheDataForKey:(id)key
{
	CLWebServiceCache *webServiceCache = [CLWebServiceCache getCacheDataForKey:key];
	[[CLWebServiceCache cache] removeObjectForKey:key];
	return webServiceCache;
}

+ (void)clearAllCache
{
	[[CLWebServiceCache cache] removeAllObjects];
}

#pragma mark - User defaults management methods

+ (void)saveCacheDataToUserDefaults:(NSDictionary *)webServiceCache
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:webServiceCache forKey:kUserDefaultsWebServiceCacheKey];
	[userDefaults synchronize];
	
	NSLog(@"saving web service cache data to user defaults");
}

+ (NSDictionary *)loadCacheFromUserDefaults
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults objectForKey:kUserDefaultsWebServiceCacheKey];
}

@end
