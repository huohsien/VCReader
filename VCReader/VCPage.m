//
//  VCPage.m
//  VCReader
//
//  Created by victor on 2/23/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCPage.h"

@implementation VCPage

@synthesize view = _view;
@synthesize chapterNumber = _chapterNumber;
@synthesize pageNumber = _pageNumber;
@synthesize width = _width;
@synthesize height = _height;
@synthesize textView = _textView;

-(instancetype) initWithView:(UIView *)view andChapterNumber:(int)chapterNumber withPageNumber:(int)pageNumber {
    

    self = [super init];
    if (self) {
        
        _view = view;
        _chapterNumber = chapterNumber;
        _pageNumber = pageNumber;
        UIView *v = [view.subviews lastObject];
        if ([v isKindOfClass:[VCTextView class]]) {
            _textView = (VCTextView *)v;
        }
        
        [self setup];
    }
    return self;
}

-(void) setup {
    
    _width = _view.bounds.size.width;
    _height = _view.bounds.size.height;
}

@end
