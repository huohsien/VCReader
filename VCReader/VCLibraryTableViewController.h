//
//  VCLibraryTableViewController.h
//  VCReader
//
//  Created by victor on 2/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCLibraryTableViewCell.h"
#import "VCPageViewController.h"
#import "VCBook.h"

extern NSString * const kVCReaderBaseURLString;


@interface VCLibraryTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *jsonResponse;
@property (nonatomic, strong) NSArray *bookArray;

@end
