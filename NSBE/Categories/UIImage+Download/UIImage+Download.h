//
//  UIImage+Download.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/13/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"


#pragma mark - Image download properties

#define IMAGE_DOWNLOAD_TIMEOUT 60

#define IMAGE_DOWNLOAD_DOMAIN_ERROR @"UIImageDownloadErrorDomain"

typedef NS_ENUM(NSInteger, UIImageDownloadErrors) {
	kUIImageDownloadErrorURLNotProvided				= 10,
	kUIImageDownloadErrorUnknown					= 99
};

@interface UIImage (Download)

+ (void)downloadImageFromURL:(NSString *)URLString completion:(void (^)(UIImage *image, NSError *error))completion;

@end
