//
//  VCPageViewController.m
//  VCReader
//
//  Created by victor on 1/24/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCPageViewController.h"

@interface VCPageViewController ()

@property (strong, nonatomic) NSTextStorage *textStorage;
@end

@implementation VCPageViewController
{
    NSMutableAttributedString *_contentAttributedTextString;
    UITextView *_pageTextView;

    NSDictionary *_attributionDict;
    NSLayoutManager *_layoutManager;
    int _pageNumber;
    int _totalNumberOfPage;
    CGRect _rectOfPage;

}
@synthesize backgroundColor = _backgroundColor;
@synthesize textColor = _textColor;
@synthesize contentString = _contentString;
@synthesize margin = _margin;
@synthesize textStorage = _textStorage;

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
    _totalNumberOfPage = 0;
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
        
        [self loadContent];
        VCBookContent *content = [[VCBookContent alloc] initWithContent:_contentString];
        NSString *chapterTitleString = [content.chapterTitleStringArray objectAtIndex:0];
        NSString *chapterContentString = [content getTextStringFromChapter:1];
        
        
        [self setupChapterAttributionFromString:[NSString stringWithFormat:@"%@%@", chapterTitleString, chapterContentString]];
        self.textStorage = [[NSTextStorage alloc] initWithAttributedString:_contentAttributedTextString];
        _layoutManager = [NSLayoutManager new];
        [self.textStorage addLayoutManager:_layoutManager];
        [self createAllContainers];
        [self updatePage];
        [self.activityIndicator stopAnimating];
    });
}

-(void) loadContent {
    NSURL *textURL = [[NSBundle mainBundle] URLForResource:@"novel" withExtension:@"txt"];
    NSError *error = nil;
    self.contentString = [[NSString alloc] initWithContentsOfURL:textURL encoding:NSUTF8StringEncoding error:&error];
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
    if (_pageNumber == _totalNumberOfPage - 1)
        return;
    _pageNumber++;
    [self updatePage];
}

-(void)swipeDown:(id)sender {
    
    if (_pageNumber == 0)
        return;
    
    _pageNumber--;
    [self updatePage];
}

@end
