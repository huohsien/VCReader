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

@class VCPageViewController;

@interface VCChapter : NSObject

@property (strong, nonatomic) VCBook *book;
@property (assign) int chapterNumber;
@property (assign) int totalNumberOfPages;
@property (strong, nonatomic) NSMutableArray *viewsStack;

-(instancetype) initForVCBook:(VCBook *)book OfChapterNumber:(int)chapterNumber inViewController:(VCPageViewController *)viewController inViewingRect:(CGRect)rect isPrefetching:(BOOL)isPrefetching;
-(void) makePageVisibleAt:(int)pageNumber;
-(BOOL) goToNextChapter;
-(BOOL) goToPreviousChapter;

@end
