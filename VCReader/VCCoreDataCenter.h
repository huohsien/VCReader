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
#import "VCUserMO+CoreDataProperties.h"

@interface VCCoreDataCenter : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) VCUserMO *user;

+(VCCoreDataCenter *) sharedInstance;

-(void) newUserWithAccoutnName:(NSString *)accountName accountPassword:(NSString *)accountPassword userID:(NSString *)userID email:(NSString *)email nickName:(NSString *)nickName token:(NSString *)token timestamp:(NSString *)timestamp signupType:(NSString *)signupType;
-(void) setCurrentUserWithUserID:(NSString *)userIDString;
-(void) clearCurrentActiveUser;
-(void) saveReadingStatusForBook:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber;
-(VCReadingStatusMO *) getReadingStatusForBook:(NSString *)bookName;

@end


