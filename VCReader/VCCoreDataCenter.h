//
//  VCCoreDataCenter.h
//  VCReader
//
//  Created by victor on 4/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCUserMO.h"
#import "VCReadingStatusMO.h"
#import "VCUserMO.h"

@interface VCCoreDataCenter : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

+(VCCoreDataCenter *) sharedInstance;

-(void) newUserWithAccoutnName:(NSString *)accountName accountPassword:(NSString *)accountPassword userID:(NSString *)userID email:(NSString *)email headshotFilePath:(NSString *)headshotFilePath nickName:(NSString *)nickName token:(NSString *)token timestamp:(NSString *)timestamp signupType:(NSString *)signupType;
-(VCUserMO *) getCurrentActiveUser;

@end


