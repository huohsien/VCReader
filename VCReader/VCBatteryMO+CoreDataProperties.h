//
//  VCBatteryMO+CoreDataProperties.h
//  VCReader
//
//  Created by victor on 6/2/16.
//  Copyright © 2016 VHHC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VCBatteryMO.h"

NS_ASSUME_NONNULL_BEGIN

@interface VCBatteryMO (CoreDataProperties)

@property (nonatomic) double level;
@property (nonatomic) NSTimeInterval timestamp;

@end

NS_ASSUME_NONNULL_END
