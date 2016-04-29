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

-(void) signUPWithName:(NSString *)accountName password:(NSString *)accountPassword nickName:(NSString *)nickName email:(NSString *)email token:(NSString *)token timestamp:(NSTimeInterval)timestamp signupType:(NSString *)signupType success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
-(void) userLoginWithAccountName:(NSString *)name password:(NSString *)password  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
-(void) getReadingStatusForBookNamed:(NSString *)bookName success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
-(void) saveReadingStatusForBookNamed:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber timestamp:(NSTimeInterval)timestamp success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
