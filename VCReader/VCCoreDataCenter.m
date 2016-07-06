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
        [self hookupCurrentUserWithToken];
    }
    return _user;
}

#pragma mark - account

-(void) setUserWithToken:(NSString *)token accountName:(NSString *)accountName accountPassword:(NSString *)accountPassword nickName:(NSString *)nickName timestamp:(NSString *)timestamp signupType:(NSString *)signupType {

    VCLOG();

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"token == %@", token];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *userArray = [_context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        
        VCLOG(@"Unresolved error %@, %@",error,[error userInfo]);
        abort();
    }
    
    // no local record in core data. create data.
    if (userArray.count == 0) {
    
        VCUserMO *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_context];
        user.accountName = accountName;
        user.accountPassword = accountPassword;
        user.nickName = nickName;
        user.token = token;
        user.timestamp = [timestamp doubleValue];
        user.signupType = signupType;
        
        [self saveContext];
        _user = user;
    } else {
        // if data exits, switch curernt usre to it
        [self hookupCurrentUserWithToken];
        
    }
}

-(void) setUserVerified {
    
        _user.verified = true;
        [self saveContext];
}

-(void) hookupCurrentUserWithToken {
    
    NSString *token = [VCTool getObjectWithKey:@"token"];

    if (!token) return;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"token == %@", token];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *userArray = [_context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        VCLOG(@"Unresolved error %@, %@",error,[error userInfo]);
        abort();
    }
    
    VCUserMO *user = [userArray lastObject];
    
    if (user == nil)
        [VCTool showAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not find user"];
    
    _user = user;
}

-(void) clearCurrentUser {
    _user = nil;
}

#pragma mark - reading status

-(VCReadingStatusMO *) updateReadingStatusForBook:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber {

    VCLOG();
    if (!_user) [self hookupCurrentUserWithToken];
    
    VCReadingStatusMO *readingStatus = [self getReadingStatusForBook:bookName];
    
    if (!readingStatus) {
        VCLOG(@"should not come here!"); //readingStatus = [NSEntityDescription insertNewObjectForEntityForName:@"ReadingStatus" inManagedObjectContext:_context];
    }
    
    readingStatus.bookName = bookName;
    readingStatus.chapterNumber = chapterNumber;
    readingStatus.wordNumber = wordNumber;
    NSTimeInterval timestamp= [[NSDate new] timeIntervalSince1970] * 1000.0;
    readingStatus.timestamp = timestamp;
    readingStatus.synced = NO;
    [_user addReadingStatusObject:readingStatus];
    [self saveContext];
    
    VCLOG(@"reading status: chapter = %d, word = %d timestamp = %13.0lf", readingStatus.chapterNumber, readingStatus.wordNumber, readingStatus.timestamp);
    return readingStatus;
}


-(VCReadingStatusMO *) updateReadingStatusForBook:(NSString *)bookName chapterNumber:(int)chapterNumber wordNumber:(int)wordNumber timestampFromServer:(NSTimeInterval)timestampFromServer {
    
    VCLOG();
    if (!_user) [self hookupCurrentUserWithToken];
    
    VCReadingStatusMO *readingStatus = [self getReadingStatusForBook:bookName];
    
    if (!readingStatus) {
        VCLOG(@"should not come here!"); //readingStatus = [NSEntityDescription insertNewObjectForEntityForName:@"ReadingStatus" inManagedObjectContext:_context];
    }
    if (timestampFromServer < readingStatus.timestamp) {
        
        VCLOG(@"the data in core data is more updated so return without writing data (from web) into core data");

        return readingStatus;
    }

    readingStatus.bookName = bookName;
    readingStatus.chapterNumber = chapterNumber;
    readingStatus.wordNumber = wordNumber;
    readingStatus.timestamp = timestampFromServer;
    readingStatus.synced = YES;
//    if (_user.readingStatus.count != 0) {
//        [_user removeReadingStatusObject:[_user.readingStatus anyObject]];
//    }
    [_user addReadingStatusObject:readingStatus];
    [self saveContext];
    
    VCLOG(@"reading status: chapter = %d, word = %d", readingStatus.chapterNumber, readingStatus.wordNumber);
    return readingStatus;
}

-(VCReadingStatusMO *) getReadingStatusForBook:(NSString *)bookName {
    
    if (!_user) [self hookupCurrentUserWithToken];

    VCReadingStatusMO *readingStatus = nil;
    
    for (VCReadingStatusMO *rs in _user.readingStatus) {
//        VCLOG(@"loop through books for user with token= %@ and book name = %@", _user.token, rs.bookName);
        if ([rs.bookName isEqualToString:bookName])
            readingStatus = rs;
    }

    if (readingStatus == nil) {
        VCLOG(@"can not find user's reading status of the given book. This might happen when the app is launched first time and the data are not synced with those on the server yet");
    }
    return readingStatus;
}

-(void) initReadingStatusForBook:(NSString *)bookName isDummy:(BOOL)isDummy {
    
    VCLOG();
    
    if (!_user) [self hookupCurrentUserWithToken];
    
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
#pragma mark - book

-(void) addForCurrentUserBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath timestamp:(NSString *)timestamp {
    
    VCLOG(@"add book:%@", bookName);
    
    if (!_user) [self hookupCurrentUserWithToken];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@)", bookName];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *bookArray = [_context executeFetchRequest:fetchRequest error:&error];
    
    if (error) VCLOG(@"Unresolved error %@, %@",error,[error userInfo]);
    
    VCBookMO *book = nil;
    if (bookArray.count == 0) {
        
        VCLOG(@"No book in core data. First time launch the app");
        book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_context];
    } else {
        book = [bookArray firstObject];
    }
    book.name = bookName;
    book.contentFilePath = contentFilePath;
    book.coverImageFilePath = coverImageFilePath;
    book.timestamp = [timestamp doubleValue];
    [_user addBooksObject:book];
    [self saveContext];
}

-(void) removeForCurrentUserBookNamed:(NSString *)bookName {
    
    if (!_user) [self hookupCurrentUserWithToken];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", bookName];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *bookArray = [_context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        
        VCLOG(@"Unresolved error %@, %@",error,[error userInfo]);
        abort();
    }
    
    VCBookMO *book = nil;
    if (bookArray.count == 0) {
        
        VCLOG(@"No book in core data. This should not happen.");
        return;
    } else {
        book = [bookArray firstObject];
    }

    [_user removeBooksObject:book];
    [self saveContext];
}

-(NSArray *)getForCurrentUserAllBooks {
    
    if (!_user) [self hookupCurrentUserWithToken];
    
    NSMutableArray *books = [NSMutableArray arrayWithArray:[_user.books allObjects]];
    NSArray *sortedArray;
    sortedArray = [books sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSTimeInterval first = [(VCBookMO*)a timestamp];
        NSTimeInterval second = [(VCBookMO*)b timestamp];
        return (first > second);
    }];
    
    return sortedArray;
}

/*
-(BOOL) updateForCurrentUserBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath timestamp:(NSString *)timestamp {
    
    if (!_user) [self hookupCurrentUserWithToken];
    
    for (VCBookMO *book in _user.books) {
        
        if ([book.name isEqualToString:bookName]) {
            
            if ([timestamp doubleValue] > book.timestamp) {
                // update
                book.contentFilePath = contentFilePath;
                book.coverImageFilePath = coverImageFilePath;
                book.timestamp = [timestamp doubleValue];
                [self saveContext];
                
                return YES;
        
            }
        }
    }

    return NO;
}
*/
-(void)clearAllBooksForCurrentUser {
    
    if (!_user) [self hookupCurrentUserWithToken];

    NSSet *books = _user.books;
    [_user removeBooks:books];
    [self saveContext];

}

-(void)addBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath timestamp:(NSString *)timestamp {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", bookName];
    NSError *error = nil;
    [fetchRequest setPredicate:predicate];
    NSArray *bookArray = [_context executeFetchRequest:fetchRequest error:&error];

    if (error)
        VCLOG(@"Unresolved error %@, %@",error,[error userInfo]);
    
    if (bookArray.count == 0) {
        VCBookMO *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_context];
        book.name = bookName;
        book.contentFilePath = contentFilePath;
        book.coverImageFilePath = coverImageFilePath;
        book.timestamp = [timestamp doubleValue];
        [self saveContext];
    } else if (bookArray.count == 1) {
        
        VCBookMO *book = (VCBookMO *)[bookArray firstObject];
        if (book.timestamp < [timestamp doubleValue]) {
            VCLOG(@"add a book with the same name as one's in Book Entity if the try-to-be-added book record is more updated than the one in the local storage");
            book.name = bookName;
            book.contentFilePath = contentFilePath;
            book.coverImageFilePath = coverImageFilePath;
            book.timestamp = [timestamp doubleValue];
            [self saveContext];
        }
    } else {
        VCLOG(@"something wrong about book instances");
    }
}


-(void)clearAllBooks {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    NSError *deleteError = nil;
    [[[VCTool appDelegate] persistentStoreCoordinator] executeRequest:delete withContext:_context error:&deleteError];
    
}

-(NSArray *)getAllBooks {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *bookArray = [_context executeFetchRequest:fetchRequest error:&error];

    if (error)
        VCLOG(@"Unresolved error %@, %@",error,[error userInfo]);

    return bookArray;

}

/*
-(void) setAttributesForBookNamed:(NSString *)bookName contentFilePath:(NSString *)contentFilePath coverImageFilePath:(NSString *)coverImageFilePath {

    [self updateForCurrentUserBookNamed:bookName contentFilePath:contentFilePath coverImageFilePath:coverImageFilePath timestamp:[NSString stringWithFormat:@"%lf",DBL_MAX]];
}
*/

#pragma mark - general tools

-(void) saveContext {
    
    // Save the context
    NSError *error = nil;
    
    if (![_context save:&error]) {
    
        VCLOG(@"Unresolved error %@, %@",error,[error userInfo]);
        [VCTool showAlertViewWithTitle:@"Core Data Error" andMessage:@"Can not save data"];
    }
}

#pragma mark - battery

-(void) logBatteryLevel:(double)level timestamp:(NSTimeInterval)timestamp {
    
    VCBatteryMO *battery = [NSEntityDescription insertNewObjectForEntityForName:@"Battery" inManagedObjectContext:_context];
    battery.level = level;
    battery.timestamp = timestamp;
    [self saveContext];
}

-(void) clearAllofBatteryLog {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Battery"];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    NSError *deleteError = nil;
    [[[VCTool appDelegate] persistentStoreCoordinator] executeRequest:delete withContext:_context error:&deleteError];
    [VCTool showAlertViewWithTitle:@"CLEAR ALL" andMessage:@"Complete"];
}

-(void) batteryLogDump {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Battery"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    NSArray *batteryInfoArray = [_context executeFetchRequest:fetchRequest error:&error];
    NSMutableString *logString = [[NSMutableString alloc] initWithString:@""];
    [logString appendString:@"times,battery level(percent)\n"];
    for (VCBatteryMO *battery in batteryInfoArray) {
        
        [logString appendString:[NSString stringWithFormat:@"%.0lf,%d%%\n",battery.timestamp * 1000.0, (int)(battery.level * 100.0)]];
        
        VCLOG(@"battery:%d%% timestamp:%@", (int)(battery.level * 100.0), [NSString stringWithFormat:@"%lf",battery.timestamp * 1000.0]);
    }

    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/battery_log.txt", documentPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
    [logString writeToFile:filePath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&error];
    [VCTool showAlertViewWithTitle:@"DUMP" andMessage:@"Complete"];

}

@end
