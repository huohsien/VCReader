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
    [self.requestSerializer setTimeoutInterval:25.0];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingTaskDidCompleteNotification object:nil];
    return self;
    
}

//-(void)networkRequestDidFinish: (NSNotification *) notification {
//    
//    NSError *error = [notification.userInfo objectForKey:AFNetworkingTaskDidCompleteErrorKey];
////    NSLog(@"%ld", (long)error.code);
//    if (error.code == -1009 || error.code == -1004) {
//        [VCTool toastMessage:@"网络连线异常"];
//    }
//    
//    NSHTTPURLResponse *httpResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
//    if (httpResponse.statusCode == 401) {
//        NSLog(@"Error was 401");
//    }
//}

-(void) callAPI:(NSString *)name params:(NSDictionary *)dict success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSMutableString *path = [[NSMutableString alloc] initWithFormat:@"%@.php?", name];
    
    for (NSString *param in dict) {
        [path appendFormat:@"%@=%@&", param, [dict objectForKey:param]];
    }
    [path deleteCharactersInRange:NSMakeRange(path.length - 1, 1)];
    
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);
    
    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success(task, responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.code == -1009 || error.code == -1004 || error.code == -1001) {
            [VCTool toastMessage:@"网络连线异常"];
            [VCTool hideActivityView];
            return;
        }
        if (failure) failure(task, error);
    }];
}

-(void) signupDirectlyWithName:(NSString *)accountName
                      password:(NSString *)accountPassword
                      nickName:(NSString *)nickName
                     timestamp:(NSTimeInterval)timestamp
                       success:(void (^)(NSURLSessionDataTask *, id))success
                       failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    

    NSMutableString *path = [NSMutableString stringWithFormat:@"user_signup.php?account_name=%@&account_password=%@&nick_name=%@&timestamp=%@", accountName, accountPassword, nickName, [NSString stringWithFormat:@"%ld",(long)timestamp]];
    
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);
    
    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success(task, responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(task, error);
        
    }];
    
}

// whether phone number is available or nil determines which one this api is for, signup or login.
-(void) signupOrLoginToQQWithToken:(NSString *)token
                          nickName:(NSString *)nickName
                         timestamp:(NSTimeInterval)timestamp
                           success:(void (^)(NSURLSessionDataTask *, id))success
                           failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    

    NSMutableString *path = [NSMutableString stringWithFormat:@"user_signup_login_qq.php?token=%@&nick_name=%@&timestamp=%@", token, nickName, [NSString stringWithFormat:@"%ld",(long)timestamp]];
    
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);
    
    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success(task, responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(task, error);
        
    }];
    
}

-(void) sendVerificationCodeToUserWithToken:(NSString *)token withPhoneNumber:(NSString *)phoneNumber timestamp:(NSTimeInterval)timestamp success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {

    NSString* path = [NSString stringWithFormat:@"user_send_phone_verify_code.php?token=%@&phone_number=%@&timestamp=%@", token, phoneNumber, [NSString stringWithFormat:@"%ld",(long)timestamp]];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);
    
    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success(task, responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(task, error);
        
    }];
    
}

-(void) getUserVerificationStatusWithToken:(NSString *)token success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
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
    NSString  *path = [NSString stringWithFormat:@"book_get_list.php?token=%@", userID];
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%s: encoded path = %@", __PRETTY_FUNCTION__, encodedPath);
    [self GET:encodedPath parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (success) success(task, responseObject);
        
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) failure(task, error);
        
    }];
}


@end
