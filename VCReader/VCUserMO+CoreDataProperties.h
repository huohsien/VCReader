//
//  VCUserMO+CoreDataProperties.h
//  VCReader
//
//  Created by victor on 5/17/16.
//  Copyright © 2016 VHHC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VCUserMO.h"

@class VCBookMO;

NS_ASSUME_NONNULL_BEGIN

@interface VCUserMO (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accountName;
@property (nullable, nonatomic, retain) NSString *accountPassword;
@property (nullable, nonatomic, retain) NSString *headshotFileURL;
@property (nullable, nonatomic, retain) NSString *nickName;
@property (nullable, nonatomic, retain) NSString *phoneNumber;
@property (nullable, nonatomic, retain) NSString *signupType;
@property (nonatomic) NSTimeInterval timestamp;
@property (nullable, nonatomic, retain) NSString *token;
@property (nonatomic) int32_t userID;
@property (nonatomic) BOOL verified;
@property (nullable, nonatomic, retain) NSSet<VCBookMO *> *books;
@property (nullable, nonatomic, retain) NSSet<VCReadingStatusMO *> *readingStatus;

@end

@interface VCUserMO (CoreDataGeneratedAccessors)

- (void)addBooksObject:(VCBookMO *)value;
- (void)removeBooksObject:(VCBookMO *)value;
- (void)addBooks:(NSSet<VCBookMO *> *)values;
- (void)removeBooks:(NSSet<VCBookMO *> *)values;

- (void)addReadingStatusObject:(VCReadingStatusMO *)value;
- (void)removeReadingStatusObject:(VCReadingStatusMO *)value;
- (void)addReadingStatus:(NSSet<VCReadingStatusMO *> *)values;
- (void)removeReadingStatus:(NSSet<VCReadingStatusMO *> *)values;

@end

NS_ASSUME_NONNULL_END
