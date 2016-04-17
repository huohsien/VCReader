//
//  VCBookMO+CoreDataProperties.h
//  VCReader
//
//  Created by victor on 4/17/16.
//  Copyright © 2016 VHHC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VCBookMO.h"

NS_ASSUME_NONNULL_BEGIN

@interface VCBookMO (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nonatomic) int32_t numberOfChapters;
@property (nullable, nonatomic, retain) NSSet<VCChapterMO *> *chapters;

@end

@interface VCBookMO (CoreDataGeneratedAccessors)

- (void)addChaptersObject:(VCChapterMO *)value;
- (void)removeChaptersObject:(VCChapterMO *)value;
- (void)addChapters:(NSSet<VCChapterMO *> *)values;
- (void)removeChapters:(NSSet<VCChapterMO *> *)values;

@end

NS_ASSUME_NONNULL_END
