//
//  VCReaderAPIClient.m
//  VCReader
//
//  Created by victor on 4/12/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCReaderAPIClient.h"

NSString * const kVCReaderAPIKey = @"";
NSString * const kVCReaderBaseURLString = @"http://api.VHHC.dyndns.org";

@implementation VCReaderAPIClient

+ (VCReaderAPIClient *) sharedClient {
    
    static VCReaderAPIClient *_shareClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{_shareClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kVCReaderBaseURLString]];});
    return _shareClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return self;
    
}

- (void)getReadingStatusForBookNamed:(NSString *)bookName success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    
    NSString* path = [NSString stringWithFormat:@"user_status_get.php?book_name=%@", bookName];
    NSLog(@"path = %@", path);
    [self GET:path parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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
