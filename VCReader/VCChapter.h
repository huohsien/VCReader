//
//  VCChapter.h
//  VCReader
//
//  Created by victor on 2/22/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCBook.h"
#import "VCTextView.h"
#import "VCPageViewController.h"
#import "VCPage.h"

@class VCPageViewController;

@interface VCChapter : NSObject

@property (strong, nonatomic) VCBook *book;
@property (assign) int chapterNumber;
@property (strong, nonatomic) NSArray *pageArray;
@property (strong, nonatomic) NSMutableArray *firstWordCountOfEachPage;

-(instancetype) initForVCBook:(VCBook *)book OfChapterNumber:(int)chapterNumber inViewController:(VCPageViewController *)viewController inViewingRect:(CGRect)rect;

@end
