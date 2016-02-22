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
@synthesize viewsStack = _viewsStack;

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

        _textLineSpacing = 15;
        _charactersSpacing = 2.0;
        _chapterTitleFontSize = 32.0;
        _chapterContentFontSize = 28.0;
        _backgroundColor = [UIColor blackColor];
        _textColor = [UIColor colorWithRed: 60.0 / 255.0 green: 1.0 blue: 1.0 / 255.0 alpha: 1.0];
        _rectOfTextView = rect;
        _contentView = viewController.contentView;
        [self renderPagesAndStoreInViewsStack];

        if (isPrefetching) {
            [self prefetchChapters];
            [self consolidateStacks];
        }
    }
    return self;
}

-(BOOL) renderPagesAndStoreInViewsStack {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSString *chapterTitleString = [_book getChapterTitleStringFromChapterNumber:_chapterNumber];
    NSString *chapterTextContentString = [_book getTextContentStringFromChapterNumber:_chapterNumber];
    
    
    _contentAttributedTextString = [[NSMutableAttributedString alloc] initWithAttributedString:[self createAttributiedChapterTitleStringFromString:[NSString stringWithFormat:@"%@\n",chapterTitleString]]];
    [_contentAttributedTextString appendAttributedString:[self createAttributiedChapterContentStringFromString:chapterTextContentString]];
    
    _textStorage = [[NSTextStorage alloc] initWithAttributedString:_contentAttributedTextString];
    _layoutManager = [NSLayoutManager new];
    [_textStorage addLayoutManager:_layoutManager];
    
    _viewsStack = [NSMutableArray new];
    
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
            [_viewsStack addObject:pageView];
            
            numberOfPages++;
        }
        
        NSLog(@"%s:%d page views were created", __PRETTY_FUNCTION__, numberOfPages);
        
        _totalNumberOfPages = numberOfPages;
        
    }
    return YES;
}


#pragma mark attributed string styling

-(NSAttributedString *) createAttributiedChapterTitleStringFromString:(NSString *)string {
    
    NSMutableAttributedString *workingAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _textLineSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.headIndent = 0;
    UIFont *font = [UIFont systemFontOfSize:_chapterTitleFontSize];
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
    paragraphStyle.firstLineHeadIndent = _chapterContentFontSize;
    
    UIColor *backgroundColor = [UIColor clearColor];
    UIColor *foregroundColor = _textColor;
    NSDictionary *attributionDict = @{NSParagraphStyleAttributeName : paragraphStyle , NSFontAttributeName : font, NSBackgroundColorAttributeName : backgroundColor, NSForegroundColorAttributeName : foregroundColor};
    
    [workingAttributedString addAttributes:attributionDict range:NSMakeRange(0, [string length])];
    [workingAttributedString addAttribute:NSKernAttributeName value:@(_charactersSpacing) range:NSMakeRange(0, [string length])];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithAttributedString:workingAttributedString];
    return attributedString;
}

-(void) makePageVisibleAt:(int)pageNumber {
    
    for (int i = 0; i < _viewsStack.count; i++) {
        UIView *v = [_viewsStack objectAtIndex:i];
        int currentChapterPageOffsetInViewsStack = (int)_previousVCChapter.viewsStack.count;
        [v setFrame:CGRectMake(0, (i - pageNumber - currentChapterPageOffsetInViewsStack) * _sizeOfScreen.height, _sizeOfScreen.width, _sizeOfScreen.height)];
        [_contentView addSubview:v];
        
    }
    
}

-(void) prefetchChapters {
    
    NSLog(@"fetch previous chapter");
    _previousVCChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:(_chapterNumber - 1) inViewController:_viewController inViewingRect:_rectOfTextView isPrefetching:NO];
    NSLog(@"fetch next chapter");
    _nextVCChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:(_chapterNumber + 1) inViewController:_viewController inViewingRect:_rectOfTextView isPrefetching:NO];
    
}

-(void) consolidateStacks {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSMutableArray *stack = [NSMutableArray new];
    int count = 0;

    for (int i = 0; i < _previousVCChapter.viewsStack.count; i++) {
        
        UIView *v = [_previousVCChapter.viewsStack objectAtIndex:i];
        CGRect rect = CGRectMake(0, (count - _previousVCChapter.viewsStack.count) * _sizeOfScreen.height, v.frame.size.width, v.frame.size.height);
        [v setFrame:rect];
        [stack addObject:v];
        [_contentView addSubview:v];
        count++;
    }
    for (int i = 0; i < self.viewsStack.count; i++) {

        UIView *v = [self.viewsStack objectAtIndex:i];
        CGRect rect = CGRectMake(0, (count - _previousVCChapter.viewsStack.count) * _sizeOfScreen.height, v.frame.size.width, v.frame.size.height);
        [v setFrame:rect];
        [stack addObject:v];
        [_contentView addSubview:v];
        count++;
    }
    for (int i = 0; i < _nextVCChapter.viewsStack.count; i++) {

        UIView *v = [_nextVCChapter.viewsStack objectAtIndex:i];
        CGRect rect = CGRectMake(0, (count - _previousVCChapter.viewsStack.count) * _sizeOfScreen.height, v.frame.size.width, v.frame.size.height);
        [v setFrame:rect];
        [stack addObject:v];
        [_contentView addSubview:v];
        count++;
    }
    _viewsStack = stack;
    
}


-(BOOL) goToNextChapter {
    if (_chapterNumber == _book.totalNumberOfChapters - 1) {
        return NO;
    }
    return YES;
}

-(BOOL) goToPreviousChapter {
    if (_chapterNumber == 0) {
        return NO;
    }
    return YES;
}

@end
