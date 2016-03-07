//
//  VCChapter.m
//  VCReader
//
//  Created by victor on 2/22/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCChapter.h"

@implementation VCChapter {
    
    NSTextStorage *_textStorage;
    NSLayoutManager *_layoutManager;
    
    VCBook *_book;
    CGRect _rectOfTextView;
    
    UIView *_contentView;
    
    NSMutableAttributedString *_contentAttributedTextString;
    
    CGSize _sizeOfScreen;
    
    VCPageViewController *_viewController;
    
    CGFloat _textLineSpacing;
    CGFloat _charactersSpacing;
    CGFloat _chapterTitleFontSize;
    CGFloat _chapterContentFontSize;
    UIColor *_backgroundColor;
    UIColor *_textColor;
    
    VCChapter *_previousVCChapter;
    VCChapter *_nextVCChapter;


}

@synthesize book = _book;
@synthesize chapterNumber = _chapterNumber;
@synthesize totalNumberOfPages = _totalNumberOfPages;
@synthesize pageArray = _pageArray;



-(instancetype) initForVCBook:(VCBook *)book OfChapterNumber:(int)chapterNumber inViewController:(VCPageViewController *)viewController inViewingRect:(CGRect)rect isPrefetching:(BOOL)isPrefetching {
    
    self = [super init];
    if (self) {
        
        if (chapterNumber < 0 || chapterNumber > (book.totalNumberOfChapters - 1))
            return nil;
        
        _book = book;
        _chapterNumber = chapterNumber;
        _viewController = viewController;
        CGRect rectOfScreen = [[UIScreen mainScreen] bounds];
        _sizeOfScreen = rectOfScreen.size;

        _textLineSpacing = 4;
        _charactersSpacing = 4.0;
        _chapterTitleFontSize = 30.0;
        _chapterContentFontSize = 28.0;
        
        _backgroundColor = (UIColor *)[viewController.textRenderAttributionDict objectForKey:@"background color"];
        _textColor = (UIColor *)[viewController.textRenderAttributionDict objectForKey:@"text color"];
        
        _rectOfTextView = rect;
        _contentView = viewController.contentView;
        _pageArray = [NSMutableArray new];
        
        [self renderPagesAndStoreInto:_pageArray forChapter:chapterNumber];

        if (isPrefetching) {
            [self prefetchChapters];
            [self consolidateStacks];
        }
    }
    return self;
}

-(void) renderPagesAndStoreInto:(NSMutableArray*)pageArray forChapter:(int)chapterNumber {
    
    if (chapterNumber < 0 || chapterNumber > _book.totalNumberOfChapters - 1) {
        return;
    }
    NSString *chapterTitleString = [_book getChapterTitleStringFromChapterNumber:chapterNumber];
    NSString *chapterTextContentString = [_book getTextContentStringFromChapterNumber:chapterNumber];
    
    
    _contentAttributedTextString = [[NSMutableAttributedString alloc] initWithAttributedString:[self createAttributiedChapterTitleStringFromString:[NSString stringWithFormat:@"%@\n",chapterTitleString]]];
    [_contentAttributedTextString appendAttributedString:[self createAttributiedChapterContentStringFromString:chapterTextContentString]];
    
    _textStorage = [[NSTextStorage alloc] initWithAttributedString:_contentAttributedTextString];
    _layoutManager = [NSLayoutManager new];
    [_textStorage addLayoutManager:_layoutManager];
    
    
    if (_layoutManager.textContainers.count == 0) {
        NSRange range = NSMakeRange(0, 0);
        int numberOfPages = 0;
        
        while(NSMaxRange(range) < _layoutManager.numberOfGlyphs) {
            
            NSTextContainer *myTextContainer = [[NSTextContainer alloc] initWithSize:_rectOfTextView.size];
            [_layoutManager addTextContainer:myTextContainer];
            range = [_layoutManager glyphRangeForTextContainer:myTextContainer];
            
            VCTextView *pageTextView = [[VCTextView alloc] initWithFrame:_rectOfTextView textContainer:myTextContainer];

            UIView *pageView = [[UIView alloc] initWithFrame:_rectOfTextView];
            [pageView setBackgroundColor:[UIColor clearColor]];
            [pageTextView setResponder:_viewController];
            [pageTextView setSelectable:NO];
            [pageTextView setScrollEnabled:NO];
            [pageTextView setEditable:NO];
            [pageTextView setBackgroundColor:[UIColor clearColor]];
            [pageView addSubview:pageTextView];
            
            VCPage *page = [[VCPage alloc] initWithView:pageView andChapterNumber:chapterNumber withPageNumber:numberOfPages];
            [pageArray addObject:page];
            
            numberOfPages++;
        }
        
//        NSLog(@"%s:%d page views were created", __PRETTY_FUNCTION__, numberOfPages);
        
    }
}

-(void) prefetchChapters {
    
    _previousVCChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:(_chapterNumber - 1) inViewController:_viewController inViewingRect:_rectOfTextView isPrefetching:NO];
    _nextVCChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:(_chapterNumber + 1) inViewController:_viewController inViewingRect:_rectOfTextView isPrefetching:NO];
    
}

-(void) consolidateStacks {
    
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSMutableArray *array = [NSMutableArray new];
    int count = 0;
    
    for (int i = 0; i < _previousVCChapter.pageArray.count; i++) {
        
        VCPage *page = [_previousVCChapter.pageArray objectAtIndex:i];
        CGRect rect = CGRectMake(0, (count - _previousVCChapter.pageArray.count) * _sizeOfScreen.height, page.width, page.height);
        [page.view setFrame:rect];
        [array addObject:page];
        [_contentView addSubview:page.view];
        count++;
    }
    _previousVCChapter.totalNumberOfPages = (int)_previousVCChapter.pageArray.count;
    
    for (int i = 0; i < self.pageArray.count; i++) {
        
        VCPage *page = [self.pageArray objectAtIndex:i];
        CGRect rect = CGRectMake(0, (count - _previousVCChapter.pageArray.count) * _sizeOfScreen.height, page.width, page.height);
        [page.view setFrame:rect];
        [array addObject:page];
        [_contentView addSubview:page.view];
        count++;
    }
    _totalNumberOfPages = (int)self.pageArray.count;

    for (int i = 0; i < _nextVCChapter.pageArray.count; i++) {
        
        VCPage *page = [_nextVCChapter.pageArray objectAtIndex:i];
        CGRect rect = CGRectMake(0, (count - _previousVCChapter.pageArray.count) * _sizeOfScreen.height, page.width, page.height);
        [page.view setFrame:rect];
        [array addObject:page];
        [_contentView addSubview:page.view];
        count++;
    }
    _nextVCChapter.totalNumberOfPages = (int)_nextVCChapter.pageArray.count;

    _pageArray = array;
    
}

-(void) makePageVisibleAt:(int)pageNumber {
    
    int pageNumberOffset = (int)_previousVCChapter.pageArray.count;
    
    [VCHelperClass removeAllSubviewsInView:_contentView];
    
    for (int i = 0; i < _pageArray.count; i++) {
        VCPage *page = [_pageArray objectAtIndex:i];
        [page.view setFrame:CGRectMake(0, (i - pageNumber - pageNumberOffset) * _sizeOfScreen.height, _sizeOfScreen.width, _sizeOfScreen.height)];
        [_contentView addSubview:page.view];
        
    }
    
}

-(void) goToNextChapter {
    
    _chapterNumber++;

    // move to the next chapter, which was prefetched before and now it becomes the current chapter and we need to move the next chapter to the current one
    
    
    // clean _previousVCChapter and views of it in contentView
    
    if (_previousVCChapter.totalNumberOfPages > 0) {
        
        for (int i = 0; i < _previousVCChapter.totalNumberOfPages; i++) {
            VCPage *page = [_pageArray firstObject];
            [page.view removeFromSuperview];
            [_pageArray removeObjectAtIndex:0];
        }
    }
    
    [_previousVCChapter.pageArray removeAllObjects];

    // move current chapter to _previousVCChapter
    
    
    if (_pageArray) {
        
        for (int i = 0; i < _totalNumberOfPages; i++) {
            VCPage *page = [_pageArray objectAtIndex:i];
            [_previousVCChapter.pageArray addObject:page];
            [page.view setFrame:CGRectMake(0, (i - _totalNumberOfPages) * _sizeOfScreen.height, _sizeOfScreen.width, _sizeOfScreen.height)];
        }
        _previousVCChapter.totalNumberOfPages = _totalNumberOfPages;
    }
    

    // set current chapter from _nextVCChapter and adjust position in content view
    
    _totalNumberOfPages = _nextVCChapter.totalNumberOfPages;
    
    // set view position
    
    for (int i = 0; i < _nextVCChapter.pageArray.count; i++) {

        VCPage *page = [_pageArray objectAtIndex:(i + _previousVCChapter.totalNumberOfPages)];

        [page.view setFrame:CGRectMake(0, i * _sizeOfScreen.height, _rectOfTextView.size.width, _rectOfTextView.size.height)];
        

    }

    //fetch new next chapter
    [_nextVCChapter.pageArray removeAllObjects];
    
    [self renderPagesAndStoreInto:_nextVCChapter.pageArray forChapter:_chapterNumber + 1];
    _nextVCChapter.totalNumberOfPages = (int)_nextVCChapter.pageArray.count;

    VCPage *page = [_pageArray lastObject];
    CGFloat yOffsetOfLastViewsInStack = page.view.frame.origin.y + _sizeOfScreen.height;
    
    
    for (int i = 0; i < _nextVCChapter.pageArray.count; i++) {
        VCPage *page = [_nextVCChapter.pageArray objectAtIndex:i];
        [_pageArray addObject:page];
        [page.view setFrame:CGRectMake(0, yOffsetOfLastViewsInStack + _sizeOfScreen.height * i, _rectOfTextView.size.width, _rectOfTextView.size.height)];
        [_contentView addSubview:page.view];
    }

//    for (int i = 0; i < _pageArray.count; i++) {
//        VCPage *page = [_pageArray objectAtIndex:i];
//        NSLog(@"%@ c:%d p:%d", NSStringFromCGRect(page.view.frame), page.chapterNumber, page.pageNumber);
//    }

}

-(void) goToPreviousChapter {
    
    _chapterNumber--;
    
    // move to the previous chapter, which was prefetched before and now it becomes the current chapter and we need to move the previous chapter to the current one
    
    
    
    // clean _nextVCChapter and views of it in contentView
    
    if (_nextVCChapter.totalNumberOfPages > 0) {
        
        for (int i = 0; i < _nextVCChapter.totalNumberOfPages; i++) {
            VCPage *page = [_pageArray lastObject];
            [page.view removeFromSuperview];
            [_pageArray removeObject:page];
        }
    }
    
    [_nextVCChapter.pageArray removeAllObjects];
    
    // move current chapter to _nextVCChapter
    
    
    if (_pageArray) {
        
        for (int i = 0; i < _totalNumberOfPages; i++) {
            VCPage *page = [_pageArray objectAtIndex:i + _previousVCChapter.totalNumberOfPages];
            [_nextVCChapter.pageArray addObject:page];
            [page.view setFrame:CGRectMake(0, (i + 1) * _sizeOfScreen.height, _sizeOfScreen.width, _sizeOfScreen.height)];
        }
        _nextVCChapter.totalNumberOfPages = _totalNumberOfPages;
    }
    
    
    // set current chapter from _previousVCChapter and adjust position in content view
    
    _totalNumberOfPages = _previousVCChapter.totalNumberOfPages;
    
    // set view position
    
    for (int i = 0; i < _previousVCChapter.pageArray.count; i++) {
        
        VCPage *page = [_pageArray objectAtIndex:i];
        
        [page.view setFrame:CGRectMake(0, (i - _previousVCChapter.pageArray.count) * _sizeOfScreen.height, _rectOfTextView.size.width, _rectOfTextView.size.height)];
        
        
    }
    
    //fetch new previous chapter
    [_previousVCChapter.pageArray removeAllObjects];
    
    [self renderPagesAndStoreInto:_previousVCChapter.pageArray forChapter:_chapterNumber - 1];
    _previousVCChapter.totalNumberOfPages = (int)_previousVCChapter.pageArray.count;

    VCPage *page = [_pageArray firstObject];
    CGFloat yOffsetOfLastViewsInStack = page.view.frame.origin.y - _sizeOfScreen.height * _previousVCChapter.pageArray.count;
    
    
    for (int i = (int)_previousVCChapter.pageArray.count - 1; i >= 0; i--) {
        VCPage *page = [_previousVCChapter.pageArray objectAtIndex:i];
        [_pageArray insertObject:page atIndex:0];
        [page.view setFrame:CGRectMake(0, yOffsetOfLastViewsInStack + _sizeOfScreen.height * i, _rectOfTextView.size.width, _rectOfTextView.size.height)];
        [_contentView addSubview:page.view];
    }
    
//    for (int i = 0; i < _pageArray.count; i++) {
//        VCPage *page = [_pageArray objectAtIndex:i];
//        NSLog(@"%@ c:%d p:%d", NSStringFromCGRect(page.view.frame), page.chapterNumber, page.pageNumber);
//    }
    
}

#pragma mark attributed string styling

-(NSAttributedString *) createAttributiedChapterTitleStringFromString:(NSString *)string {
    
    NSMutableAttributedString *workingAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _textLineSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.headIndent = 0;
    UIFont *font = [UIFont systemFontOfSize:_chapterTitleFontSize];
//    UIFont *font = [UIFont fontWithName:@"STFangSong" size:_chapterTitleFontSize];
    UIColor *backgroundColor = [UIColor clearColor];
    UIColor *foregroundColor = _textColor;
    NSDictionary *attributionDict = @{NSParagraphStyleAttributeName : paragraphStyle , NSFontAttributeName : font, NSBackgroundColorAttributeName : backgroundColor, NSForegroundColorAttributeName : foregroundColor};
    
    [workingAttributedString addAttributes:attributionDict range:NSMakeRange(0, [string length])];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithAttributedString:workingAttributedString];
    return attributedString;
}

-(NSAttributedString *) createAttributiedChapterContentStringFromString:(NSString *)string {
    
    NSMutableAttributedString *workingAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _textLineSpacing;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    UIFont *font = [UIFont systemFontOfSize:_chapterContentFontSize];
//    UIFont *font = [UIFont fontWithName:@"STFangSong" size:_chapterContentFontSize];
    paragraphStyle.firstLineHeadIndent = _chapterContentFontSize;
    
    UIColor *backgroundColor = [UIColor clearColor];
    UIColor *foregroundColor = _textColor;
    NSDictionary *attributionDict = @{NSParagraphStyleAttributeName : paragraphStyle , NSFontAttributeName : font, NSBackgroundColorAttributeName : backgroundColor, NSForegroundColorAttributeName : foregroundColor};
    
    [workingAttributedString addAttributes:attributionDict range:NSMakeRange(0, [string length])];
    [workingAttributedString addAttribute:NSKernAttributeName value:@(_charactersSpacing) range:NSMakeRange(0, [string length])];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithAttributedString:workingAttributedString];
    return attributedString;
}

@end
