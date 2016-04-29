//
//  VCUserMO+CoreDataProperties.h
//  VCReader
//
//  Created by victor on 4/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VCUserMO.h"

NS_ASSUME_NONNULL_BEGIN

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
@property (nullable, nonatomic, retain) VCReadingStatusMO *readingStatus;

@end

NS_ASSUME_NONNULL_END
