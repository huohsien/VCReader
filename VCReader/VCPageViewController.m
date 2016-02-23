//
//  VCPageViewController.m
//  VCReader
//
//  Created by victor on 1/24/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCPageViewController.h"
#import "VCTextView.h"
#import "AppDelegate.h"

@implementation VCPageViewController
{

    int _pageNumber;
    int _chapterNumber;
    int _totalNumberOfPage;
    NSArray *_titleOfChaptersArray;
    CGRect _rectOfTextView;
    CGRect _rectOfScreen;
    CGFloat _currentPageScrollOffset;
    
    VCChapter *_currentVCChapter;

    
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
@synthesize charactersSpacing = _charactersSpacing;
@synthesize chapterTitleFontSize = _chapterTitleFontSize;
@synthesize chapterContentFontSize = _chapterContentFontSize;
@synthesize contentView =_contentView;

-(void) baseInit {
    
    _topMargin = 40;
    _bottomMargin = 20;
    _horizontalMargin = 10;
    _textLineSpacing = 15;
    _charactersSpacing = 2.0;
    _chapterTitleFontSize = 32.0;
    _chapterContentFontSize = 28.0;
    
    _backgroundColor = [UIColor blackColor];
    _textColor = [UIColor colorWithRed: 60.0 / 255.0 green: 1.0 blue: 1.0 / 255.0 alpha: 1.0];
    
}

-(void) setup {
    
    _totalNumberOfPage = 0;
    
    _rectOfScreen = [[UIScreen mainScreen] bounds];
    CGSize sizeOfScreen = _rectOfScreen.size;
    NSLog(@"w:%f h:%f", sizeOfScreen.width, sizeOfScreen.height);

    _rectOfTextView = CGRectMake(_horizontalMargin, _topMargin, sizeOfScreen.width - 2 * _horizontalMargin, sizeOfScreen.height - _topMargin - _bottomMargin);
    
    _contentView = [[UIView alloc] initWithFrame:_rectOfScreen];
    [self.view setBackgroundColor:_backgroundColor];
    [_contentView setBackgroundColor:[UIColor clearColor ]];
    [self.view addSubview:_contentView];
    [self.view sendSubviewToBack:_contentView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

}


-(void) start {
    
    [self.activityIndicator startAnimating];
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
        _currentBook = [[VCBook alloc] initWithBookName:@"超級學神"];
        
//        _chapterNumber = 166;
//        _pageNumber = 0;
        
        _chapterNumber = [[VCHelperClass getDatafromBook:_currentBook.bookName withField:@"savedChapterNumber"] intValue];
        _pageNumber = [[VCHelperClass getDatafromBook:_currentBook.bookName withField:@"savedPageNumber"] intValue];
        NSLog(@"chapter:%d page:%d", _chapterNumber, _pageNumber);

        _currentVCChapter = [[VCChapter alloc] initForVCBook:_currentBook OfChapterNumber:_chapterNumber inViewController:self inViewingRect:_rectOfTextView isPrefetching:YES];
        _totalNumberOfPage = _currentVCChapter.totalNumberOfPages;
        [_currentVCChapter makePageVisibleAt:_pageNumber];
        [self updateProgessInfo];

        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
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




#pragma mark gesture callback

-(void)swipeUp:(id)sender {
    
//    NSLog(@"%s",__PRETTY_FUNCTION__);

    _pageNumber++;

    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [_currentVCChapter makePageVisibleAt:_pageNumber];
        
    } completion:nil];
    
    if (_pageNumber > _totalNumberOfPage - 1) {

        _chapterNumber++;

        if(![_currentVCChapter goToNextChapter])
            return;

        _pageNumber = 0;
        _totalNumberOfPage = _currentVCChapter.totalNumberOfPages;
        
    }
    
    [self updateProgessInfo];
}

-(void)swipeDown:(id)sender {
    
//    NSLog(@"%s",__PRETTY_FUNCTION__);

    _pageNumber--;

    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [_currentVCChapter makePageVisibleAt:_pageNumber];
        
    } completion:nil];
    
    if (_pageNumber < 0){
        
        _chapterNumber--;

        if(![_currentVCChapter goToPreviousChapter])
            return;

        _totalNumberOfPage = _currentVCChapter.totalNumberOfPages;
        _pageNumber = _totalNumberOfPage - 1;
        
        [_currentVCChapter makePageVisibleAt:_pageNumber];

        
    }
    
    [self updateProgessInfo];
}

-(void) showPageWithScrollOffsetByUserTouch {
    
    int offset = [_currentVCChapter getOffset];
    NSLog(@"-------------------------");
//    int count = 0;
//    for (UIView *v in _contentView.subviews) {
//        NSLog(@"%@", v.description);
//        count++;
//    }
//    NSLog(@"%d", count);
    
//    int count = 0;
//    for (VCPage *v in _currentVCChapter.pageArray) {
//        NSLog(@"%@ c:%d p:%d", v.description, v.chapterNumber, v.pageNumber);
//        count++;
//    }
//    NSLog(@"%d", count);

    
    for (int i = 0; i < _currentVCChapter.pageArray.count; i++) {
        VCPage *page = [_currentVCChapter.pageArray objectAtIndex:i];
        [page.view setFrame:CGRectMake(0, (i - offset + _pageNumber) * _rectOfScreen.size.height + _currentPageScrollOffset, _rectOfScreen.size.width, _rectOfScreen.size.height)];
    }

}



#pragma mark time functions

-(void)updateTimeOnClock {
    
    self.currentTimeLabel.text = [self getCurrentTimeShortString];
    
//    NSLog(@"update clock view");
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
    
//    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [self updateTimeOnClock];
    
    int seconds = [[self getCurrentTimeSeconds] intValue];
    if (seconds != 0) {
        [self performSelector:@selector(StartTimerForClock) withObject:nil afterDelay:(60 - seconds)];
//        NSLog(@"compensation delay - %d", (60 - seconds));
        return;
    }
    
//    NSLog(@"start timer");
    
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"%s",__PRETTY_FUNCTION__);

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
//    NSLog(@"%@", NSStringFromCGPoint(point));
    
    _currentPageScrollOffset = 0;
    
    _lastTouchedPointY = point.y;

}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
//    NSLog(@"%@", NSStringFromCGPoint(point));
    
    CGFloat pointY = point.y;
    CGFloat yDisplacement = (pointY - _lastTouchedPointY);

    _currentPageScrollOffset = yDisplacement;
    
    [self showPageWithScrollOffsetByUserTouch];
    int count = 0;
    for (VCPage *v in _currentVCChapter.pageArray) {
        NSLog(@"%@ c:%d p:%d", NSStringFromCGRect(v.view.frame), v.chapterNumber, v.pageNumber);
        count++;
    }
    NSLog(@"%d", count);
    
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"%s",__PRETTY_FUNCTION__);

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
//    NSLog(@"%@", NSStringFromCGPoint(point));

    CGFloat pointY = point.y;
    CGFloat yDisplacement = (pointY - _lastTouchedPointY);
    
//    NSLog(@"moved distance %.0f",distance);
    
    if (yDisplacement < -10) {
        [self swipeUp:nil];
    }
    if (yDisplacement > 10) {
        [self swipeDown:nil];
    }
}


-(void) updateProgessInfo {

    self.chapterLabel.text = [NSString stringWithFormat:@"%d章", _chapterNumber + 1];
    self.pageLabel.text = [NSString stringWithFormat:@"%d頁/%d頁", _pageNumber + 1, _currentVCChapter.totalNumberOfPages];
}

@end
