//
//  VCCoreDataCenter.h
//  VCReader
//
//  Created by victor on 4/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCUserMO.h"
#import "VCReadingStatusMO.h"
#import "VCUserMO.h"

@interface VCCoreDataCenter : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) VCUserMO *user;

+(VCCoreDataCenter *) sharedInstance;

@end


