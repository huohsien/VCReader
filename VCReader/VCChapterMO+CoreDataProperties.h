//
//  VCChapterMO+CoreDataProperties.h
//  VCReader
//
//  Created by victor on 7/6/16.
//  Copyright © 2016 VHHC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VCChapterMO.h"

NS_ASSUME_NONNULL_BEGIN

@interface VCChapterMO (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contentText;
@property (nonatomic) int32_t firstWordLocation;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) VCBookMO *book;

@end

NS_ASSUME_NONNULL_END
