//
//  VCReaderAPIClient.m
//  VCReader
//
//  Created by victor on 4/12/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCReaderAPIClient.h"

NSString * const kVCReaderBaseURLString = @"http://api.VHHC.dyndns.org";

@implementation VCReaderAPIClient

+(VCReaderAPIClient *) sharedClient {
    
    static VCReaderAPIClient *_shareClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{_shareClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kVCReaderBaseURLString]];});
    return _shareClient;
}

-(instancetype) initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];

    return self;
    
}

-(BOOL) connected {
    BOOL isReachable = [AFNetworkReachabilityManager sharedManager].reachable;
    return isReachable;
}

-(void) signupWithName:(NSString *)accountName
              password:(NSString *)accountPassword
              nickName:(NSString *)nickName
                 phoneNumber:(NSString *)phoneNumber
                 token:(NSString *)token timestamp:(NSTimeInterval)timestamp
            signupType:(NSString *)signupType success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSMutableString *path = [NSMutableString stringWithFormat:@"user_signup.php?account_name=%@&account_password=%@&nick_name=%@&phone_number=%@&timestamp=%@&signup_type=%@", accountName, accountPassword, nickName, phoneNumber, [NSString stringWithFormat:@"%ld",(long)timestamp], signupType];
    
    if (token) [path appendString:[NSString stringWithFormat:@"&token=%@", token]];
    
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);
    
    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success(task, responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(task, error);
        
    }];
    
}

-(void) userLoginWithAccountName:(NSString *)name password:(NSString *)password  success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {

    NSString* path = [NSString stringWithFormat:@"user_login.php?account_name=%@&account_password=%@", name, password];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);

    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success(task, responseObject);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(task, error);
        
    }];
}

-(void) getReadingStatusForBookNamed:(NSString *)bookName success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSString *token = [VCCoreDataCenter sharedInstance].user.token;
    NSString* path = [NSString stringWithFormat:@"user_status_get.php?token=%@&book_name=%@", token, bookName];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s --- http get path = %@", __PRETTY_FUNCTION__, encodedPath);
    
    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success(task, responseObject);
        
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(task, error);
        
    }];
    
}

-(void) addReadingStatusForBookNamed:(NSString *)bookName
                          chapterNumber:(int)chapterNumber
                             wordNumber:(int)wordNumber
                              timestamp:(NSTimeInterval)timestamp success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *token = [VCCoreDataCenter sharedInstance].user.token;
    NSString  *path = [NSString stringWithFormat:@"user_status_add.php?token=%@&book_name=%@&current_reading_chapter=%d&current_reading_word=%d&timestamp=%@", token, bookName, chapterNumber, wordNumber, [NSString stringWithFormat:@"%ld",(long)timestamp]];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);

    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success(task, responseObject);
        
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(task, error);
        
    }];
    
}
-(void) getBookListForUserWithID:(NSString *)userID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    if (!userID) return;
    NSString  *path = [NSString stringWithFormat:@"book_get_list.php?user_id=%@", userID];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);
    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success(task, responseObject);
        
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(task, error);
        
    }];
}


@end
