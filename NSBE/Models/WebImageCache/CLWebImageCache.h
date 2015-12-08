//
//  CLWebImageCache.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/24/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Type defines and enums

#define kWebImageDefaultCacheSize 30

@interface CLWebImageCache : NSObject

#pragma mark - Web image cache properties

@property (nonatomic, assign) NSUInteger cacheSize;

#pragma mark - Web image cache singleton

+ (CLWebImageCache *)cache;

#pragma mark - Web image cache management

- (UIImage *)getImageForURL:(NSString *)URLString;

- (void)addImage:(UIImage *)photo forURL:(NSString *)URLString;

- (void)clearAllCache;

@end
