//
//  VCPageViewController.m
//  VCReader
//
//  Created by victor on 1/24/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCPageViewController.h"

@implementation VCPageViewController
{
    NSMutableAttributedString *_contentAttributedTextString;
    UITextView *_pageTextView;

    NSDictionary *_attributionDict;
    NSTextStorage *_textStorage;
    NSLayoutManager *_layoutManager;
    int _pageNumber;
    int _chapterNumber;
    int _totalNumberOfPage;
    int _totalNumberOfChapter;
    NSArray *_titleOfChaptersArray;
    CGRect _rectOfPage;

}
@synthesize currentBook = _currentBook;
@synthesize backgroundColor = _backgroundColor;
@synthesize textColor = _textColor;
@synthesize margin = _margin;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self baseInit];
    [self setup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self start];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)baseInit {
    _margin = 10;
    _backgroundColor = [UIColor blackColor];
    _textColor = [UIColor colorWithRed: 60.0 / 255.0 green: 1.0 blue: 1.0 / 255.0 alpha: 1.0];

}

-(void) setup {
    
    _pageNumber = 0;
    _chapterNumber = 0;
    _totalNumberOfPage = 0;
    _totalNumberOfChapter = 0;
    CGSize sizeOfScreen = [[UIScreen mainScreen] bounds].size;
    _rectOfPage = CGRectMake(_margin, _margin, sizeOfScreen.width - 2 * _margin, sizeOfScreen.height - 2 * _margin);
    
    UISwipeGestureRecognizer *gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    gr.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:gr];
    UISwipeGestureRecognizer *gr1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    gr1.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:gr1];
    


}

-(void) start {
    
    [self.activityIndicator startAnimating];
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
        _currentBook = [[VCBook alloc] initWithBookName:@"官神"];
        NSString *s = [VCHelperClass getDatafromBook:_currentBook.bookName withField:@"numberOfChapters"];
        _totalNumberOfChapter = [s intValue];
        
        [self loadChapter:_chapterNumber];
        [self updatePage];
        [self.activityIndicator stopAnimating];
    });
}

-(BOOL)loadChapter:(int)chapterNumber {
    
    if (chapterNumber < 0 || chapterNumber >= _totalNumberOfChapter) {
        return NO;
    }
    NSString *chapterTitleString = [_currentBook getChapterTitleStringFromChapterNumber:chapterNumber];
    NSString *chapterTextContentString = [_currentBook getTextContentStringFromChapterNumber:chapterNumber];
    
    
    [self setupChapterAttributionFromString:[NSString stringWithFormat:@"%@%@", chapterTitleString, chapterTextContentString]];
    _textStorage = [[NSTextStorage alloc] initWithAttributedString:_contentAttributedTextString];
    _layoutManager = [NSLayoutManager new];
    [_textStorage addLayoutManager:_layoutManager];
    [self createAllContainers];
    return YES;
}

-(void) setupChapterAttributionFromString:(NSString *)string {
    _contentAttributedTextString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    UIFont *font = [UIFont systemFontOfSize:26.0];
    UIColor *backgroundColor = _backgroundColor;
    UIColor *foregroundColor = _textColor;
    _attributionDict = @{NSParagraphStyleAttributeName : paragraphStyle , NSFontAttributeName : font, NSBackgroundColorAttributeName : backgroundColor, NSForegroundColorAttributeName : foregroundColor};
    
    [_contentAttributedTextString addAttributes:_attributionDict range:NSMakeRange(0, [string length])];
    
}

- (void)createAllContainers {
    if (_layoutManager.textContainers.count == 0) {
        NSRange range = NSMakeRange(0, 0);
        int numberOfPages = 0;
        while(NSMaxRange(range) < _layoutManager.numberOfGlyphs) {
            NSTextContainer *myTextContainer = [[NSTextContainer alloc] initWithSize:_rectOfPage.size];
            [_layoutManager addTextContainer:myTextContainer];
            range = [_layoutManager glyphRangeForTextContainer:myTextContainer];
            numberOfPages++;
        }
        NSLog(@"%d container were created", numberOfPages);
        _totalNumberOfPage = numberOfPages;
    }
}
-(void) updatePage {
    
    NSTextContainer *newContainer = [_layoutManager.textContainers objectAtIndex:_pageNumber];
    _pageTextView = [[UITextView alloc] initWithFrame:_rectOfPage textContainer:newContainer];
    [_pageTextView setSelectable:NO];
    [_pageTextView setScrollEnabled:NO];
    [_pageTextView setBackgroundColor:self.backgroundColor];

    [self.view addSubview:_pageTextView];

}

-(void)swipeUp:(id)sender {
    
    if (_pageNumber == _totalNumberOfPage - 1) {
        _chapterNumber++;
        if([self loadChapter:_chapterNumber] == NO) {
            _chapterNumber--;
            return;
        }
        _pageNumber = 0;
    } else {
        _pageNumber++;
    }
    [self updatePage];
}

-(void)swipeDown:(id)sender {
    
    if (_pageNumber == 0){
        _chapterNumber--;
        if([self loadChapter:_chapterNumber] == NO) {
            _chapterNumber++;
            return;
        }
        _pageNumber = _totalNumberOfPage - 1;
    } else {
        _pageNumber--;
    }
    [self updatePage];
}


@end
