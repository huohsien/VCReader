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

-(void) callAPI:(NSString *)name params:(NSDictionary *)dict success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

-(void) signupDirectlyWithName:(NSString *)accountName password:(NSString *)accountPassword nickName:(NSString *)nickName timestamp:(NSTimeInterval)timestamp success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
//-(void) signupOrLoginToQQWithToken:(NSString *)token nickName:(NSString *)nickName timestamp:(NSTimeInterval)timestamp success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
-(void) sendVerificationCodeToUserWithToken:(NSString *)token withPhoneNumber:(NSString *)phoneNumber timestamp:(NSTimeInterval)timestamp success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

-(void) getUserVerificationStatusWithToken:(NSString *)token success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;


-(void) userLoginWithAccountName:(NSString *)name password:(NSString *)password  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
-(void) getReadingStatusForBookNamed:(NSString *)bookName success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
-(void) addReadingStatusForBookNamed:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber timestamp:(NSTimeInterval)timestamp success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
-(void) getBookListForUserWithID:(NSString *)userID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
