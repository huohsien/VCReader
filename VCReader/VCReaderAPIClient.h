//
//  VCReaderAPIClient.h
//  VCReader
//
//  Created by victor on 4/12/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

extern NSString * const kVCReaderBaseURLString;

@interface VCReaderAPIClient : AFHTTPSessionManager

+ (VCReaderAPIClient *) sharedClient;

- (void)userLoginWithAccountName:(NSString *)name password:(NSString *)password  success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
-(void) getReadingStatusForBookNamed:(NSString *)bookName success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
-(void) saveReadingStatusForBookNamed:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber timestamp:(NSTimeInterval)timestamp success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
@end
