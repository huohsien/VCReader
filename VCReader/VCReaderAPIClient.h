//
//  VCReaderAPIClient.h
//  VCReader
//
//  Created by victor on 4/12/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

extern NSString * const kVCReaderAPIKey;
extern NSString * const kVCReaderBaseURLString;

@interface VCReaderAPIClient : AFHTTPSessionManager

+ (VCReaderAPIClient *) sharedClient;

@end
