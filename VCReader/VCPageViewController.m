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
    UITextView *_currentPageTextView;
    UITextView *_previousPageTextView;
    UITextView *_nextPageTextView;
    NSDictionary *_attributionDict;
    NSLayoutManager *_layoutManager;
    NSTextContainer *_textContainer;
    int pageNumber;
    CGRect rectOfPage;

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
    
    pageNumber = -1;
    
    CGSize sizeOfScreen = [[UIScreen mainScreen] bounds].size;
    rectOfPage = CGRectMake(_margin, _margin, sizeOfScreen.width - 2 * _margin, sizeOfScreen.height - 2 * _margin);
    

    [self loadContent];
    self.textStorage = [[NSTextStorage alloc] initWithAttributedString:_contentAttributedTextString];
    _layoutManager = [NSLayoutManager new];
    [self.textStorage addLayoutManager:_layoutManager];


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
        [self createOnePage];
        [self.activityIndicator stopAnimating];
    });
}

-(void) loadContent {
    NSURL *textURL = [[NSBundle mainBundle] URLForResource:@"novel" withExtension:@"txt"];
    NSError *error = nil;
    self.contentString = [[NSString alloc] initWithContentsOfURL:textURL encoding:NSUTF8StringEncoding error:&error];
    _contentAttributedTextString = [[NSMutableAttributedString alloc] initWithString:self.contentString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    UIFont *font = [UIFont systemFontOfSize:26.0];
    UIColor *backgroundColor = _backgroundColor;
    UIColor *foregroundColor = _textColor;
    _attributionDict = @{NSParagraphStyleAttributeName : paragraphStyle , NSFontAttributeName : font, NSBackgroundColorAttributeName : backgroundColor, NSForegroundColorAttributeName : foregroundColor};
    
    [_contentAttributedTextString addAttributes:_attributionDict range:NSMakeRange(0, [self.contentString length])];
    
}

-(void) createOnePage {
    
    pageNumber++;
    _textContainer = [[NSTextContainer alloc] initWithSize:rectOfPage.size];
    [_layoutManager addTextContainer:_textContainer];
    [_currentPageTextView removeFromSuperview];
    _currentPageTextView = [[UITextView alloc] initWithFrame:rectOfPage textContainer:[_layoutManager.textContainers objectAtIndex:pageNumber]];
    [_currentPageTextView setBackgroundColor:self.backgroundColor];
    [_currentPageTextView setScrollEnabled:NO];
    [self.view addSubview:_currentPageTextView];

}

-(void)swipeUp:(id)sender {
    
    [self createOnePage];
}

-(void)swipeDown:(id)sender {
    
    pageNumber--;
    if (pageNumber < 0) pageNumber = 0;
    
    [_currentPageTextView removeFromSuperview];
    _currentPageTextView = [[UITextView alloc] initWithFrame:rectOfPage textContainer:[_layoutManager.textContainers objectAtIndex:pageNumber]];
    [_currentPageTextView setBackgroundColor:self.backgroundColor];
    [_currentPageTextView setScrollEnabled:NO];
    [self.view addSubview:_currentPageTextView];
}

@end
