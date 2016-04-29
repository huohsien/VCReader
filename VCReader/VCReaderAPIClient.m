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

-(void) signupWithName:(NSString *)accountName password:(NSString *)accountPassword nickName:(NSString *)nickName email:(NSString *)email token:(NSString *)token timestamp:(NSTimeInterval)timestamp signupType:(NSString *)signupType success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NSString* path;
    if (token) {
        path = [NSString stringWithFormat:@"user_signup.php?account_name=%@&account_password=%@&nick_name=%@&email=%@&token=%@&timestamp=%@&signup_type=%@", accountName, accountPassword, nickName, email, token, [NSString stringWithFormat:@"%ld",(long)(timestamp * 1000.0)], signupType];
    } else {
        path = [NSString stringWithFormat:@"user_signup.php?account_name=%@&account_password=%@&nick_name=%@&email=%@&timestamp=%@&signup_type=%@", accountName, accountPassword, nickName, email, [NSString stringWithFormat:@"%ld",(long)(timestamp * 1000.0)], signupType];
    }
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);
    
    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
    
}

-(void) userLoginWithAccountName:(NSString *)name password:(NSString *)password  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {

    NSString* path = [NSString stringWithFormat:@"user_login.php?account_name=%@&account_password=%@", name, password];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);

    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

-(void) getReadingStatusForBookNamed:(NSString *)bookName success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
//    if (![self connected]) {
//        
//        [VCHelperClass showErrorAlertViewWithTitle:@"Network" andMessage:@"Diconnected from internet"];
//        return;
//    }
    
    NSString* path = [NSString stringWithFormat:@"user_status_get.php?book_name=%@", bookName];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);
    
    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
    
}

-(void) saveReadingStatusForBookNamed:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber timestamp:(NSTimeInterval)timestamp success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
//    if (![self connected]) {
//        
//        [VCHelperClass showErrorAlertViewWithTitle:@"Network" andMessage:@"Diconnected from internet"];
//        return;
//    }
    
    NSString* path = [NSString stringWithFormat:@"user_status_add.php?book_name=%@&current_reading_chapter=%d&current_reading_word=%d&timestamp=%@", bookName, chapterNumber, wordNumber, [NSString stringWithFormat:@"%ld",(long)(timestamp * 1000.0)]];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);

    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
    
}

@end
