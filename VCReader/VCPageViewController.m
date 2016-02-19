//
//  VCPageViewController.m
//  VCReader
//
//  Created by victor on 1/24/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCPageViewController.h"
#import "VCTextView.h"
@implementation VCPageViewController
{
    NSMutableAttributedString *_contentAttributedTextString;
    VCTextView *_pageTextView;

    NSTextStorage *_textStorage;
    NSLayoutManager *_layoutManager;
    int _pageNumber;
    int _chapterNumber;
    int _totalNumberOfPage;
    int _totalNumberOfChapter;
    NSArray *_titleOfChaptersArray;
    CGRect _rectOfPage;
    
    NSMutableArray *_viewStacks;
    
    // touch
    
    CGFloat _lastTouchedPointX;
    CGFloat _lastTouchedPointY;
    CFTimeInterval _startTime;
    CFTimeInterval _elapsedTime;

}
@synthesize currentBook = _currentBook;
@synthesize backgroundColor = _backgroundColor;
@synthesize textColor = _textColor;
@synthesize topMargin = _topMargin;
@synthesize bottomMargin = _bottomMargin;
@synthesize horizontalMargin = _horizontalMargin;
@synthesize textLineSpacing = _textLineSpacing;

-(void) baseInit {
    _topMargin = 40;
    _bottomMargin = 20;
    _horizontalMargin = 10;
    _textLineSpacing = 15;
    _backgroundColor = [UIColor blackColor];
    _textColor = [UIColor colorWithRed: 60.0 / 255.0 green: 1.0 blue: 1.0 / 255.0 alpha: 1.0];
    
}

-(void) setup {
    
    _totalNumberOfPage = 0;
    _totalNumberOfChapter = 0;
    CGSize sizeOfScreen = [[UIScreen mainScreen] bounds].size;
    _rectOfPage = CGRectMake(_horizontalMargin, _topMargin, sizeOfScreen.width - 2 * _horizontalMargin, sizeOfScreen.height - _topMargin - _bottomMargin);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [((VCView *)self.view) setNextResponder:self];
}

-(void) start {
    
    [self.activityIndicator startAnimating];
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
        _currentBook = [[VCBook alloc] initWithBookName:@"超級學神"];
        _totalNumberOfChapter = [[VCHelperClass getDatafromBook:_currentBook.bookName withField:@"numberOfChapters"] intValue];
        
        _chapterNumber = [[VCHelperClass getDatafromBook:_currentBook.bookName withField:@"savedChapterNumber"] intValue];
        _pageNumber = [[VCHelperClass getDatafromBook:_currentBook.bookName withField:@"savedPageNumber"] intValue];
        NSLog(@"chapter:%d page:%d", _chapterNumber, _pageNumber);
        [self loadChapter:_chapterNumber];
        [self updatePage];
        [self.activityIndicator stopAnimating];
    });
    [self startMonitoringBattery];
    [self StartTimerForClock];
    
    
}

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

-(void) applicationWillEnterForeground:(NSNotification *)notification {
    
}


-(void) applicationWillResignActive:(NSNotification *)notification {
    
    [VCHelperClass storeIntoBook:_currentBook.bookName withField:@"savedPageNumber" andData:@(_pageNumber).stringValue];
    [VCHelperClass storeIntoBook:_currentBook.bookName withField:@"savedChapterNumber" andData:@(_chapterNumber).stringValue];

}


-(BOOL)loadChapter:(int)chapterNumber {
    
    if (chapterNumber < 0 || chapterNumber >= _totalNumberOfChapter) {
        return NO;
    }
    NSString *chapterTitleString = [_currentBook getChapterTitleStringFromChapterNumber:chapterNumber];
    NSString *chapterTextContentString = [_currentBook getTextContentStringFromChapterNumber:chapterNumber];
    
    
    _contentAttributedTextString = [[NSMutableAttributedString alloc] initWithAttributedString:[self createAttributiedChapterTitleStringFromString:[NSString stringWithFormat:@"%@\n",chapterTitleString]]];
    [_contentAttributedTextString appendAttributedString:[self createAttributiedChapterContentStringFromString:chapterTextContentString]];
    
    _textStorage = [[NSTextStorage alloc] initWithAttributedString:_contentAttributedTextString];
    _layoutManager = [NSLayoutManager new];
    [_textStorage addLayoutManager:_layoutManager];
    [self createAllContainers];
    return YES;
}

-(NSAttributedString *) createAttributiedChapterTitleStringFromString:(NSString *)string {
    
    NSMutableAttributedString *workingAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _textLineSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.headIndent = 0;
    UIFont *font = [UIFont systemFontOfSize:32.0];
    UIColor *backgroundColor = _backgroundColor;
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
    paragraphStyle.alignment = NSTextAlignmentLeft;
    UIFont *font = [UIFont systemFontOfSize:26.0];
    paragraphStyle.firstLineHeadIndent = 26;

    UIColor *backgroundColor = _backgroundColor;
    UIColor *foregroundColor = _textColor;
    NSDictionary *attributionDict = @{NSParagraphStyleAttributeName : paragraphStyle , NSFontAttributeName : font, NSBackgroundColorAttributeName : backgroundColor, NSForegroundColorAttributeName : foregroundColor};
    
    [workingAttributedString addAttributes:attributionDict range:NSMakeRange(0, [string length])];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithAttributedString:workingAttributedString];
    return attributedString;
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
    if (_pageTextView) {
        [_pageTextView removeFromSuperview];
        _pageTextView = nil;
    }
    _pageTextView = [[VCTextView alloc] initWithFrame:_rectOfPage textContainer:newContainer];
    [_pageTextView setSelectable:NO];
    [_pageTextView setScrollEnabled:NO];
    [_pageTextView setEditable:NO];
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
#pragma mark time functions

-(void)updateTimeOnClock {
    self.currentTimeLabel.text = [self getCurrentTimeShortString];
    NSLog(@"update clock view");
}

-(NSString *)getCurrentTimeShortString {
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}

-(NSString *)getCurrentTimeSeconds {
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}

-(void)StartTimerForClock {
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self updateTimeOnClock];
    
    int seconds = [[self getCurrentTimeSeconds] intValue];
    if (seconds != 0) {
        [self performSelector:@selector(StartTimerForClock) withObject:nil afterDelay:(60 - seconds)];
        NSLog(@"compensation delay- %d", (60 - seconds));
        return;
    }
    NSLog(@"start timer");
    NSTimer *timer = [NSTimer timerWithTimeInterval:60
                                             target:self
                                           selector:@selector(updateTimeOnClock)
                                           userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
#pragma mark battery fuctions

-(void) startMonitoringBattery {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelDidChange:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    self.batteryLabel.text = [NSString stringWithFormat:@"%.0f%%",[[UIDevice currentDevice] batteryLevel] * 100.0f];
    
}
-(void) batteryLevelDidChange:(NSNotification *)notification {
    self.batteryLabel.text = [NSString stringWithFormat:@"%.0f%%",[[UIDevice currentDevice] batteryLevel] * 100.0f];
}

#pragma mark - touch functions

- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    _lastTouchedPointX = point.x;
    _lastTouchedPointY = point.y;
    
    _startTime = CACurrentMediaTime();
}

- (void) touchesMoved:(NSSet *)touches
            withEvent:(UIEvent *)event {
    
    _elapsedTime = CACurrentMediaTime() - _startTime;
    
    //    NSLog(@"duration of atouch: %f", _elapsedTime);
    if (_elapsedTime > 1.0 && _startTime != 0) {

        _startTime = 0;
    }
    
}

- (void) touchesEnded:(NSSet *)touches
            withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    CGFloat pointX = point.x;
    CGFloat pointY = point.y;
    CGFloat xDist = (pointX - _lastTouchedPointX);
    CGFloat yDist = (pointY - _lastTouchedPointY);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    //    NSLog(@"moved distance %.0f",distance);
    
    if (distance <= 100.0) {
    } else {
    }
    
    if (yDist < -10) {
        [self swipeUp:nil];
    }
    if (yDist > 10) {
        [self swipeDown:nil];
    }
}

@end
