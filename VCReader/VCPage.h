//
//  VCPage.h
//  VCReader
//
//  Created by victor on 2/23/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCTextView.h"

@interface VCPage : NSObject

-(instancetype) initWithView:(UIView *)view andChapterNumber:(int)chapterNumber withPageNumber:(int)pageNumber;

@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) VCTextView *textView;
@property (assign) int chapterNumber;
@property (assign) int pageNumber;
@property (assign) CGFloat width;
@property (assign) CGFloat height;

@end
