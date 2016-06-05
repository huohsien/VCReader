//
//  VCPlainTextResponseSerializer.m
//  VCReader
//
//  Created by victor on 6/5/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCPlaintextResponseSerializer.h"

@implementation VCPlaintextResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    [super responseObjectForResponse:response data:data error:error]; //BAD SIDE EFFECTS BAD BUT NECESSARY TO CATCH 500s ETC
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)([response textEncodingName] ?: @"utf-8")));
    return [[NSString alloc] initWithData:data encoding:encoding];
}

@end