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
#import "VCBookMO.h"
#import "VCBatteryMO.h"

@interface VCCoreDataCenter : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) VCUserMO *user;
@property (nonatomic, strong) NSDictionary *jsonResponse;

+(VCCoreDataCenter *) sharedInstance;

-(void) newUserWithAccoutnName:(NSString *)accountName accountPassword:(NSString *)accountPassword userID:(NSString *)userID email:(NSString *)email nickName:(NSString *)nickName token:(NSString *)token timestamp:(NSString *)timestamp signupType:(NSString *)signupType;
-(void) clearCurrentUser;
-(VCReadingStatusMO *) updateReadingStatusForBook:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber timestampFromServer:(NSTimeInterval)timestamp;
-(VCReadingStatusMO *) updateReadingStatusForBook:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber;
-(VCReadingStatusMO *) getReadingStatusForBook:(NSString *)bookName;
-(void) saveContext;
-(void) initReadingStatusForBook:(NSString *)bookName isDummy:(BOOL)isDummy;
-(BOOL) addBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath timestamp:(NSString *)timestamp;
-(BOOL) updateBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath timestamp:(NSString *)timestamp;
-(void) setAttributesForBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath;
-(NSArray *) getAllBooks;
-(void)addBatteryLogWithPercentage:(double)percentage timestamp:(NSTimeInterval)timestamp;
-(void) batteryLogDump;
-(void) clearAllofBatteryLog;

@end


