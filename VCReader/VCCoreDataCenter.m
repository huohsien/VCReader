//
//  VCCoreDataCenter.m
//  VCReader
//
//  Created by victor on 4/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCCoreDataCenter.h"
#import "VCReadingStatusMO+CoreDataProperties.h"

@implementation VCCoreDataCenter

@synthesize context = _context;
@synthesize user = _user;

+(VCCoreDataCenter *) sharedInstance {
    
    static VCCoreDataCenter *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{_sharedInstance = [[self alloc] init];});
    return _sharedInstance;
}

-(instancetype) init {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    return self;
}

-(VCUserMO *)user {
    if (!_user) {
        [self hookupCurrentUserWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    }
    return _user;
}

-(void) newUserWithAccoutnName:(NSString *)accountName accountPassword:(NSString *)accountPassword userID:(NSString *)userID email:(NSString *)email nickName:(NSString *)nickName token:(NSString *)token timestamp:(NSString *)timestamp signupType:(NSString *)signupType {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"token == %@", token];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *userArray = [_context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%s --- Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        abort();
    }
    
    // no local record in core data. create data.
    if (userArray.count == 0) {
    
        VCUserMO *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_context];
        user.accountName = accountName;
        user.accountPassword = accountPassword;
        user.email = email;
        user.nickName = nickName;
        user.token = token;
        user.timestamp = [timestamp doubleValue];
        user.signupType = signupType;
        user.userID = [userID intValue];
//        NSLog(@"%s %@,%@,%@,%@,%@,%lf,%@,%d", __PRETTY_FUNCTION__, user.accountName, user.accountPassword, user.email, user.nickName, user.token, user.timestamp, user.signupType, user.userID);
        [self saveContext];
        _user = user;
    } else {
        // if data exits, switch curernt usre to it
        [self hookupCurrentUserWithUserID:userID];
    }
}

-(void) hookupCurrentUserWithUserID:(NSString *)userIDString {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID == %@", userIDString];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *userArray = [_context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%s --- Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        abort();
    }
    
    VCUserMO *user = [userArray lastObject];
    
    if (user == nil)
        [VCTool showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not find user"];
    
    _user = user;
}

-(void) clearCurrentUser {
    _user = nil;
}

-(VCReadingStatusMO *) updateReadingStatusForBook:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber {

    if (!_user) [self hookupCurrentUserWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    
    VCReadingStatusMO *readingStatus = [self getReadingStatusForBook:bookName];
    
    if (!readingStatus) {
        NSLog(@"%s --- should not come here!", __PRETTY_FUNCTION__); //readingStatus = [NSEntityDescription insertNewObjectForEntityForName:@"ReadingStatus" inManagedObjectContext:_context];
    }
    
    readingStatus.bookName = bookName;
    readingStatus.chapterNumber = chapterNumber;
    readingStatus.wordNumber = wordNumber;
    NSTimeInterval timestamp= [[NSDate new] timeIntervalSince1970] * 1000.0;
    readingStatus.timestamp = timestamp;
    readingStatus.synced = NO;
    [_user addReadingStatusObject:readingStatus];
    [self saveContext];
    
    NSLog(@"%s --- reading status: chapter = %d, word = %d timestamp = %13.0lf", __PRETTY_FUNCTION__, readingStatus.chapterNumber, readingStatus.wordNumber, readingStatus.timestamp);
    return readingStatus;
}


-(VCReadingStatusMO *) updateReadingStatusForBook:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber timestampFromServer:(NSTimeInterval)timestampFromServer {
    
    if (!_user) [self hookupCurrentUserWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    
    VCReadingStatusMO *readingStatus = [self getReadingStatusForBook:bookName];
    
    if (!readingStatus) {
        NSLog(@"%s --- should not come here!", __PRETTY_FUNCTION__); //readingStatus = [NSEntityDescription insertNewObjectForEntityForName:@"ReadingStatus" inManagedObjectContext:_context];
    }
    if (timestampFromServer < readingStatus.timestamp) {
        
        NSLog(@"%s --- the data in core data is more updated so return without writing data (from web) into core data", __PRETTY_FUNCTION__);

        return readingStatus;
    }

    readingStatus.bookName = bookName;
    readingStatus.chapterNumber = chapterNumber;
    readingStatus.wordNumber = wordNumber;
    readingStatus.timestamp = timestampFromServer;
    readingStatus.synced = YES;
    if (_user.readingStatus.count != 0) {
        [_user removeReadingStatusObject:[_user.readingStatus anyObject]];
    }
    [_user addReadingStatusObject:readingStatus];
    [self saveContext];
    
    NSLog(@"%s --- reading status: chapter = %d, word = %d", __PRETTY_FUNCTION__, readingStatus.chapterNumber, readingStatus.wordNumber);
    return readingStatus;
}

-(VCReadingStatusMO *) getReadingStatusForBook:(NSString *)bookName {
    
    if (!_user) [self hookupCurrentUserWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];

    VCReadingStatusMO *readingStatus = [_user.readingStatus anyObject];

    if (readingStatus == nil) {
        NSLog(@"%s --- can not find user's reading status", __PRETTY_FUNCTION__);
    } else {
//        NSLog(@"%s --- chapter = %d, word = %d timestamp=%13.0lf", __PRETTY_FUNCTION__, readingStatus.chapterNumber, readingStatus.wordNumber, readingStatus.timestamp);
    }
    return readingStatus;
}

-(void) initReadingStatusForBook:(NSString *)bookName isDummy:(BOOL)isDummy {
    
    if (!_user) [self hookupCurrentUserWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    
    VCReadingStatusMO *readingStatus = [NSEntityDescription insertNewObjectForEntityForName:@"ReadingStatus" inManagedObjectContext:_context];
    readingStatus.bookName = bookName;
    readingStatus.chapterNumber = 0;
    readingStatus.wordNumber = 0;
    NSTimeInterval timestamp;
    if (isDummy) {
        timestamp = 0.0;
    } else {
        timestamp = [[NSDate new] timeIntervalSince1970]  * 1000.0;
    }
    
    readingStatus.timestamp = timestamp;
    readingStatus.synced = NO;
    [_user addReadingStatusObject:readingStatus];
    [self saveContext];
    
}

-(void) saveContext {
    
    // Save the context
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"%s --- Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        [VCTool showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not save data"];
        abort();
    }
}

@end
