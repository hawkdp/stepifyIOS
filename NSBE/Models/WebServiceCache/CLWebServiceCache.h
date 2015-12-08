//
//  CLWebServiceCache.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/13/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Type defines and enums

#define kUserDefaultsWebServiceCacheKey @"userDefaultsWebServiceCache"

typedef NSDictionary CLWebServiceCache;

@interface NSDictionary (WebServiceCache)

#pragma mark - Web service cache properties

@property (nonatomic, readonly, strong) id data;

@property (nonatomic, readonly, strong) NSDate *cacheDate;

@property (nonatomic, readonly, assign) NSTimeInterval cacheExpirationTime;

#pragma mark - Web service all the cache

+ (NSMutableDictionary *)cache;

#pragma mark - Web service cache instance methods

- (BOOL)cacheExpired;

- (NSTimeInterval)timeUntilExpiration;

#pragma mark - Web service cache class methods

+ (void)addCacheData:(id)data withCacheExpirationTime:(NSTimeInterval)expirationTime forKey:(id)key;

+ (void)addCacheData:(id)data forDate:(NSDate *)date withCacheExpirationTime:(NSTimeInterval)expirationTime forKey:(id)key;

+ (CLWebServiceCache *)getCacheDataForKey:(id)key;

+ (CLWebServiceCache *)deleteCacheDataForKey:(id)key;

+ (void)clearAllCache;

#pragma mark - User defaults management methods

+ (void)saveCacheDataToUserDefaults:(NSDictionary *)webServiceCache;

+ (NSDictionary *)loadCacheFromUserDefaults;

@end
