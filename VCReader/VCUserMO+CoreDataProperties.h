//
//  VCUserMO+CoreDataProperties.h
//  VCReader
//
//  Created by victor on 5/3/16.
//  Copyright © 2016 VHHC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VCUserMO.h"

NS_ASSUME_NONNULL_BEGIN
@class VCBookMO;
@interface VCUserMO (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accountName;
@property (nullable, nonatomic, retain) NSString *accountPassword;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *headshotFileURL;
@property (nullable, nonatomic, retain) NSString *signupType;
@property (nullable, nonatomic, retain) NSString *nickName;
@property (nonatomic) NSTimeInterval timestamp;
@property (nullable, nonatomic, retain) NSString *token;
@property (nonatomic) int32_t userID;
@property (nullable, nonatomic, retain) NSSet<VCReadingStatusMO *> *readingStatus;
@property (nullable, nonatomic, retain) NSSet<VCBookMO *> *books;

@end

@interface VCUserMO (CoreDataGeneratedAccessors)

- (void)addReadingStatusObject:(VCReadingStatusMO *)value;
- (void)removeReadingStatusObject:(VCReadingStatusMO *)value;
- (void)addReadingStatus:(NSSet<VCReadingStatusMO *> *)values;
- (void)removeReadingStatus:(NSSet<VCReadingStatusMO *> *)values;

- (void)addBooksObject:(VCBookMO *)value;
- (void)removeBooksObject:(VCBookMO *)value;
- (void)addBooks:(NSSet<VCBookMO *> *)values;
- (void)removeBooks:(NSSet<VCBookMO *> *)values;

@end

NS_ASSUME_NONNULL_END
