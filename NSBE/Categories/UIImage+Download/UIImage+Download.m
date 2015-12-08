//
//  UIImage+Download.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/13/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "UIImage+Download.h"

@implementation UIImage (Download)

+ (void)downloadImageFromURL:(NSString *)URLString completion:(void (^)(UIImage *image, NSError *error))completion
{
	// Sanity check
	if (URLString.length == 0) {
		
		// Call completion block if this is available
		if (completion) {
			completion(nil, [NSError errorWithDomain:IMAGE_DOWNLOAD_DOMAIN_ERROR
												code:kUIImageDownloadErrorURLNotProvided
											userInfo:@{NSLocalizedDescriptionKey :
														   NSLocalizedString(@"ImageURLNotProvided", nil)}]);
		}
		return;
	}
	
	// Escape special characters
	URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSLog(@"image request to: %@", URLString);
	
	// Create URL request
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]
												cachePolicy:NSURLRequestReloadIgnoringCacheData
											timeoutInterval:IMAGE_DOWNLOAD_TIMEOUT];
	// Perform an image request
	AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
	requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
	[requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		// Call completion block if this is available
		if (completion) {
			completion(responseObject, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		// Call completion block if this is available
		if (completion) {
			completion(nil, error);
		}
	}];
	
	// Start operation
	[requestOperation start];
}

@end
