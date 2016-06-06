//
//  VCBookStoreTableViewController.h
//  VCReader
//
//  Created by victor on 6/6/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCBookStoreTableViewCell.h"
#import "VCBook.h"
#import "VCLibraryTableViewController.h"

extern NSString * const kVCReaderBaseURLString;

@interface VCBookStoreTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *jsonResponse;
@property (nonatomic, strong) NSArray *bookArray;

@end
