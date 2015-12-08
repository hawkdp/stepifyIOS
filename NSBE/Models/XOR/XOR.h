//
//  XOR.h
//  NSBE
//
//  Created by Iulian Corcoja on 2/10/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XOR : NSObject

+ (NSData *)encryptString:(NSString *)string;

+ (NSData *)encryptData:(NSData *)data;

+ (NSData *)decryptString:(NSString *)string;

+ (NSData *)decryptData:(NSData *)data;

@end
