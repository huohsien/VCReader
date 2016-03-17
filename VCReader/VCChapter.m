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

}

@synthesize book = _book;
@synthesize chapterNumber = _chapterNumber;
@synthesize totalNumberOfPages = _totalNumberOfPages;


-(instancetype) initForVCBook:(VCBook *)book OfChapterNumber:(int)chapterNumber inViewController:(VCPageViewController *)viewController inViewingRect:(CGRect)rect{
    
    self = [super init];
    if (self) {
        
        if (chapterNumber < 0 || chapterNumber > (book.totalNumberOfChapters - 1))
            return nil;
        
        _book = book;
        _chapterNumber = chapterNumber;
        _viewController = viewController;
        
        CGRect rectOfScreen = [[UIScreen mainScreen] bounds];
        _sizeOfScreen = rectOfScreen.size;

        _textLineSpacing = 14.0;
        _charactersSpacing = 2.5;
        _chapterTitleFontSize = 34.0;
        _chapterContentFontSize = 26.0;
        
        _backgroundColor = (UIColor *)[viewController.textRenderAttributionDict objectForKey:@"background color"];
        _textColor = (UIColor *)[viewController.textRenderAttributionDict objectForKey:@"text color"];
        
        _rectOfTextView = rect;
        _contentView = viewController.contentView;

    }
    return self;
}

-(NSMutableArray *) renderPages {
    return [self renderPagesForChapter:_chapterNumber];
}

-(NSMutableArray *) renderPagesInThePreviousChapter {
    return [self renderPagesForChapter:_chapterNumber - 1];
}
-(NSMutableArray *) renderPagesInTheNextChapter {
    
    return [self renderPagesForChapter:_chapterNumber + 1];
}

-(NSMutableArray*) renderPagesForChapter:(int)chapterNumber {
    
    if (chapterNumber < 0 || chapterNumber > _book.totalNumberOfChapters - 1) {
        
        return nil;
    }
    
    NSString *chapterTitleString = [_book getChapterTitleStringFromChapterNumber:chapterNumber];
    NSString *chapterTextContentString = [_book getTextContentStringFromChapterNumber:chapterNumber];

    
    _contentAttributedTextString = [[NSMutableAttributedString alloc] initWithAttributedString:[self createAttributiedChapterTitleStringFromString:[NSString stringWithFormat:@"\n%@\n\n",chapterTitleString]]];
    [_contentAttributedTextString appendAttributedString:[self createAttributiedChapterContentStringFromString:chapterTextContentString]];
    
    _textStorage = [[NSTextStorage alloc] initWithAttributedString:_contentAttributedTextString];
    _layoutManager = [NSLayoutManager new];
    [_textStorage addLayoutManager:_layoutManager];
    
    
//    if (_layoutManager.textContainers.count == 0) {
    
    NSMutableArray *pageArray = [NSMutableArray new];
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
//    }
    return pageArray;
}


#pragma mark attributed string styling

-(NSAttributedString *) createAttributiedChapterTitleStringFromString:(NSString *)string {
    
    NSMutableAttributedString *workingAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _textLineSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    UIFont *font = [UIFont systemFontOfSize:_chapterTitleFontSize];
//    UIFont *font = [UIFont fontWithName:@"STFangSong" size:_chapterTitleFontSize];
    UIColor *backgroundColor = [UIColor clearColor];
    UIColor *foregroundColor = _textColor;
    NSDictionary *attributionDict = @{NSParagraphStyleAttributeName : paragraphStyle , NSFontAttributeName : font, NSBackgroundColorAttributeName : backgroundColor, NSForegroundColorAttributeName : foregroundColor};
    
    [workingAttributedString addAttributes:attributionDict range:NSMakeRange(0, [string length])];
    [workingAttributedString addAttribute:NSKernAttributeName value:@(_charactersSpacing) range:NSMakeRange(0, [string length])];

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithAttributedString:workingAttributedString];
    return attributedString;
}

-(NSAttributedString *) createAttributiedChapterContentStringFromString:(NSString *)string {
    
    NSMutableAttributedString *workingAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _textLineSpacing;
    paragraphStyle.firstLineHeadIndent = _chapterContentFontSize * 2.0 + _charactersSpacing * 3.0;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    UIFont *font = [UIFont systemFontOfSize:_chapterContentFontSize];
//    UIFont *font = [UIFont fontWithName:@"STFangSong" size:_chapterContentFontSize];

    
    UIColor *backgroundColor = [UIColor clearColor];
    UIColor *foregroundColor = _textColor;
    NSDictionary *attributionDict = @{NSParagraphStyleAttributeName : paragraphStyle , NSFontAttributeName : font, NSBackgroundColorAttributeName : backgroundColor, NSForegroundColorAttributeName : foregroundColor};
    
    [workingAttributedString addAttributes:attributionDict range:NSMakeRange(0, [string length])];
    [workingAttributedString addAttribute:NSKernAttributeName value:@(_charactersSpacing) range:NSMakeRange(0, [string length])];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithAttributedString:workingAttributedString];
    return attributedString;
}

@end
