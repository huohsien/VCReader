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

-(void) setUserWithToken:(NSString *)token accountName:(NSString *)accountName accountPassword:(NSString *)accountPassword nickName:(NSString *)nickName timestamp:(NSString *)timestamp signupType:(NSString *)signupType;
-(void) clearCurrentUser;
-(void) setUserVerified;
-(VCReadingStatusMO *) updateReadingStatusForBook:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber timestampFromServer:(NSTimeInterval)timestamp;
-(VCReadingStatusMO *) updateReadingStatusForBook:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber;
-(VCReadingStatusMO *) getReadingStatusForBook:(NSString *)bookName;
-(void) saveContext;

-(void) initReadingStatusForBook:(NSString *)bookName isDummy:(BOOL)isDummy;

-(void) addForCurrentUserBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath timestamp:(NSString *)timestamp;
//-(BOOL) updateForCurrentUserBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath timestamp:(NSString *)timestamp;
-(void) removeForCurrentUserBookNamed:(NSString *)bookName;
-(void) clearAllBooksForCurrentUser;

//-(void) setAttributesForBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath;

-(void) addBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath timestamp:(NSString *)timestamp;
-(void) clearAllBooks;
-(NSArray *)getAllBooks;


-(NSArray *) getForCurrentUserAllBooks;

-(void) logBatteryLevel:(double)level timestamp:(NSTimeInterval)timestamp;
-(void) batteryLogDump;
-(void) clearAllofBatteryLog;

@end


