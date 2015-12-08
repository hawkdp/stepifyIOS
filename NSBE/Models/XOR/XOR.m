//
//  XOR.m
//  NSBE
//
//  Created by Iulian Corcoja on 2/10/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "XOR.h"
#import "Constants.h"

@implementation XOR

+ (NSData *)encryptString:(NSString *)string
{
	return [XOR decryptData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSData *)encryptData:(NSData *)data
{
	return [XOR decryptData:data];
}

+ (NSData *)decryptString:(NSString *)string
{
	return [XOR decryptData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSData *)decryptData:(NSData *)data;
{
	char secretKey[] = XOR_CIPHER_SECRET_KEY;
	char input[[data length]];
	char output[[data length]];
	int secretLength = (int) strlen(secretKey);
	
	// Copy input data
	memcpy(input, [data bytes], [data length]);
	
	// Encrypt/decrypt every byte from input
	for (int i = 0; i < [data length]; i++) {
		output[i] = input[i] ^ secretKey[i % secretLength];
	}
	
	// Return output data
	return [NSData dataWithBytes:output length:[data length]];
}



@end
