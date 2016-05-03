//
//  VCBookMO+CoreDataProperties.m
//  VCReader
//
//  Created by victor on 5/3/16.
//  Copyright © 2016 VHHC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VCBookMO+CoreDataProperties.h"

@implementation VCBookMO (CoreDataProperties)

@dynamic name;
@dynamic contentFilePath;
@dynamic coverImageFilePath;
@dynamic timestamp;
@dynamic chapters;
@dynamic user;

@end
