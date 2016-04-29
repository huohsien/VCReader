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

-(void) newUserWithAccoutnName:(NSString *)accountName accountPassword:(NSString *)accountPassword userID:(NSString *)userID email:(NSString *)email nickName:(NSString *)nickName token:(NSString *)token timestamp:(NSString *)timestamp signupType:(NSString *)signupType {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"token == %@", token];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *userArray = [_context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        abort();
    }
    // no local record in core data
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
        NSLog(@"%@,%@,%@,%@,%@,%lf,%@,%d", user.accountName, user.accountPassword, user.email, user.nickName, user.token, user.timestamp, user.signupType, user.userID);
        
        // Save the context
        NSError *error = nil;
        if (![_context save:&error]) {
            NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
            [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not save data"];
            abort();
        }
        _user = user;
    } else {
        [self setCurrentUserWithUserID:userID];
    }
}

-(void) setCurrentUserWithUserID:(NSString *)userIDString {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID == %@", userIDString];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *userArray = [_context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        abort();
    }
    VCUserMO *user = [userArray lastObject];
    if (user == nil) {
    
        [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not find user"];
        
    }
    
    _user = user;
}

-(void) clearCurrentActiveUser {
    _user = nil;
}



-(void) saveReadingStatusForBook:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber {
    
    if (!_user) {
        [self setCurrentUserWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    }
    
    VCReadingStatusMO *readingStatus = [NSEntityDescription insertNewObjectForEntityForName:@"ReadingStatus" inManagedObjectContext:_context];
    readingStatus.bookName = bookName;
    readingStatus.chapterNumber = chapterNumber;
    readingStatus.wordNumber = wordNumber;
    NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970];
    readingStatus.timestamp = timestamp;
    readingStatus.synced = NO;
    [_user addReadingStatusObject:readingStatus];
    
    NSLog(@"%s reading status: chapter = %d, word = %d", __PRETTY_FUNCTION__, readingStatus.chapterNumber, readingStatus.wordNumber);

    // Save the context
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not save data"];
        abort();
    }
}

-(VCReadingStatusMO *) getReadingStatusForBook:(NSString *)bookName {
    
    if (!_user) {
        [self setCurrentUserWithUserID:[[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    }
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID == %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
//    [fetchRequest setPredicate:predicate];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    NSError *error = nil;
//    NSArray *statusArray = [_context executeFetchRequest:fetchRequest error:&error];
    
    NSTimeInterval timestamp = 0.0;
    NSArray *readingStatusArray = [_user.readingStatus allObjects];
    int count = 0;
    int chosen_index = 0;
    for (VCReadingStatusMO *readingStatus in readingStatusArray) {
        if (readingStatus.timestamp > timestamp) {
            timestamp = readingStatus.timestamp;
            chosen_index = count;
        }
        count++;
//        NSLog(@"e: chapter = %d, word = %d t=%lf", readingStatus.chapterNumber, readingStatus.wordNumber, readingStatus.timestamp);
    }
//    if (error) {
//        
//        NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
//        abort();
//    }
    VCReadingStatusMO *readingStatus;
    if (readingStatusArray.count > 0) {
        
        readingStatus = [readingStatusArray objectAtIndex:chosen_index];
        
    } else {
        
        readingStatus = [NSEntityDescription insertNewObjectForEntityForName:@"ReadingStatus" inManagedObjectContext:_context];
        readingStatus.bookName = bookName;
        readingStatus.chapterNumber = 0;
        readingStatus.wordNumber = 0;
        NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970];
        readingStatus.timestamp = timestamp;
        readingStatus.synced = NO;
        [_user addReadingStatusObject:readingStatus];
                
        // Save the context
        NSError *error = nil;
        if (![_context save:&error]) {
            NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
            [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not save data"];
            abort();
        }
    }
        
    NSLog(@"%s reading status: chapter = %d, word = %d", __PRETTY_FUNCTION__, readingStatus.chapterNumber, readingStatus.wordNumber);
    
    if (readingStatus == nil)
        [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not find user's reading status"];
    
    return readingStatus;
}

@end
