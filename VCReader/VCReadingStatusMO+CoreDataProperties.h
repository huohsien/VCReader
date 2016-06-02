//
//  VCReadingStatusMO+CoreDataProperties.h
//  VCReader
//
//  Created by victor on 6/2/16.
//  Copyright © 2016 VHHC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VCReadingStatusMO.h"
@class VCUserMO;

NS_ASSUME_NONNULL_BEGIN

@interface VCReadingStatusMO (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *bookName;
@property (nonatomic) int16_t chapterNumber;
@property (nonatomic) BOOL synced;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic) int16_t wordNumber;
@property (nullable, nonatomic, retain) VCUserMO *user;

@end

NS_ASSUME_NONNULL_END
