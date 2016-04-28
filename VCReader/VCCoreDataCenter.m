//
//  VCCoreDataCenter.m
//  VCReader
//
//  Created by victor on 4/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCCoreDataCenter.h"

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

-(void) newUserWithAccoutnName:(NSString *)accountName accountPassword:(NSString *)accountPassword email:(NSString *)email headshotFilePath:(NSString *)headshotFilePath nickName:(NSString *)nickName {

    VCUserMO *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_context];
    user.accountName = accountName;
    user.accountPassword = accountPassword;
    user.email = email;
    user.headshotFilePath = headshotFilePath;
    user.nickName = nickName;
    
    // Save the context
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not save data"];
        abort();
    }
    _user = user;
}

-(VCUserMO *) getUser {
    
    if (!_user) {
        
        // Retrieve all the shapes
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookName == %@", bookName];
//        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *userArray = [_context executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
            abort();
        }
        _user = [userArray lastObject];
        if (_user == nil) {
            
            [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not find user"];
            
        }
    }
    
    return _user;
}

-(void) saveReadingStatusForBook:(NSString *)bookName andUserID:(NSString *)userID chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber {
    
    VCReadingStatusMO *readingStatus = [NSEntityDescription insertNewObjectForEntityForName:@"ReadingStatus" inManagedObjectContext:_context];
    readingStatus.bookName = bookName;
    readingStatus.chapterNumber = chapterNumber;
    readingStatus.wordNumber = wordNumber;
    NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970];
    readingStatus.timestamp = timestamp;
    readingStatus.user.userID = [userID intValue];
    // Save the context
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not save data"];
        abort();
    }
}

-(VCReadingStatusMO *) getReadingStatusForBook:(NSString *)bookName andUserID:(NSString *)userID {
    
    // Retrieve all the shapes
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReadingStatus"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookName == %@", bookName];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *statusArray = [_context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"%s: Unresolved error %@, %@",__PRETTY_FUNCTION__,error,[error userInfo]);
        abort();
    }
    VCReadingStatusMO *readingStatus = [statusArray lastObject];
    if (readingStatus == nil) {
        
        [VCHelperClass showErrorAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not find user's reading status"];
        
    }
    return readingStatus;
}

@end
