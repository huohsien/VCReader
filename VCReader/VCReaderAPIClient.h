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

-(void) callAPI:(NSString *)name params:(NSDictionary *)dict success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure completion:(void (^)(BOOL finished))completion;

-(void) signupDirectlyWithName:(NSString *)accountName password:(NSString *)accountPassword nickName:(NSString *)nickName timestamp:(NSTimeInterval)timestamp success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

-(void) userLoginWithAccountName:(NSString *)name password:(NSString *)password  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
-(void) getReadingStatusForBookNamed:(NSString *)bookName success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
