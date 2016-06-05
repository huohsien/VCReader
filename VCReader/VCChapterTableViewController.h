//
//  VCChapterTableViewController.h
//  VCReader
//
//  Created by victor on 2/29/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCBook.h"
@interface VCChapterTableViewController : UITableViewController<UITableViewDelegate>

@property (nonatomic, strong) VCBook *book;
@property (assign) int chapterNumber;
@property (assign) int pageNumber;

@end
