//
//  VCPageViewController.m
//  VCReader
//
//  Created by victor on 1/24/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCPageViewController.h"
#import "VCChapterTableViewController.h"
#import "VCTextView.h"
#import "AppDelegate.h"
#define NUMBER_OF_PREFETCH_PAGES 1

@implementation UIImage (Crop)

- (UIImage *)crop:(CGRect)rect {
    
    rect = CGRectMake(rect.origin.x * self.scale,
                      rect.origin.y * self.scale,
                      rect.size.width * self.scale,
                      rect.size.height * self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

@end

@implementation UIImage (AverageColor)

- (UIColor *)averageColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

@end

@implementation UIImage (Color)

+ (UIImage *)imageFromColor:(UIColor *)color withRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

@implementation UIImage (Extras)

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        //        if (widthFactor < heightFactor) {
        //          thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        //        } else if (widthFactor > heightFactor) {
        //          thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        //        }
        
        //thumbnailPoint.x
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    
    return newImage ;
}

@end;

@implementation VCPageViewController
{

    NSArray *_titleOfChaptersArray;
    CGRect _rectOfTextView;
    CGRect _rectOfScreen;
    CGFloat _previousOffset;
    CGFloat _deltaOffset;
    BOOL _statusBarHidden;
    
    NSMutableArray *_pageArray;
    
    NSArray *_pagesInThePreviousChapter;
    NSArray *_pagesInTheNextChapter;
    
    int _totalNumberOfPage;

    
    // touch
    
    CGFloat _lastTouchedPointX;
    CGFloat _lastTouchedPointY;
    CFTimeInterval _startTime;
    CFTimeInterval _elapsedTime;

}

@synthesize book = _book;
@synthesize textColor = _textColor;
@synthesize topMargin = _topMargin;
@synthesize bottomMargin = _bottomMargin;
@synthesize horizontalMargin = _horizontalMargin;
@synthesize textLineSpacing = _textLineSpacing;
@synthesize charactersSpacing = _charactersSpacing;
@synthesize chapterTitleFontSize = _chapterTitleFontSize;
@synthesize chapterContentFontSize = _chapterContentFontSize;
@synthesize contentView =_contentView;
@synthesize textRenderAttributionDict = _textRenderAttributionDict;
@synthesize backgroundImage = _backgroundImage;
@synthesize chapterNumber = _chapterNumber;
@synthesize pageNumber = _pageNumber;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self baseInit];
    [self setup];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self start];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        
        // detect going back in navigation chain
        //prepare the to be shown controlller with correct UI style
        
        UIViewController *vc = self.navigationController.topViewController;
        vc.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        vc.navigationController.navigationBar.barTintColor = [UIColor redColor];
        vc.tabBarController.tabBar.hidden = NO;
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"the last read book"];

    } else {
        
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.hidden = YES;
    }
    
    [super viewWillDisappear:animated];
    
    [VCHelperClass storeIntoBook:_book.bookName withField:@"savedPageNumber" andData:@(_pageNumber).stringValue];
    [VCHelperClass storeIntoBook:_book.bookName withField:@"savedChapterNumber" andData:@(_chapterNumber).stringValue];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

-(BOOL)prefersStatusBarHidden {
    
    return _statusBarHidden;
}

-(void) baseInit {
    
    _topMargin = 0;
    _bottomMargin = 0;
    _horizontalMargin = 10;
    _textLineSpacing = 15;
    _charactersSpacing = 2.0;
    _chapterTitleFontSize = 32.0;
    _chapterContentFontSize = 28.0;
    _rectOfScreen = [[UIScreen mainScreen] bounds];

    _backgroundImage = [UIImage imageFromColor:[UIColor colorWithRed:186.0 / 255.0 green:159.0 / 255.0 blue:130.0 / 255.0 alpha:1.0] withRect:_rectOfScreen];
    _textColor = [UIColor colorWithRed: 56.0 / 255.0 green: 33.0 / 255.0 blue: 20.0 / 255.0 alpha: 1.0];
    
}

-(void) setup {
    
    _totalNumberOfPage = 0;
    _textRenderAttributionDict = [NSMutableDictionary new];
    [_textRenderAttributionDict setObject:[UIColor colorWithPatternImage:_backgroundImage] forKey:@"background color"];
    [_textRenderAttributionDict setObject:_textColor forKey:@"text color"];
    
    self.title = _book.bookName;
    
    CGSize sizeOfScreen = _rectOfScreen.size;
    NSLog(@"screen resolution:%@", NSStringFromCGSize(sizeOfScreen));
    
    // resize bg image
    _backgroundImage = [_backgroundImage imageByScalingProportionallyToSize:sizeOfScreen];
    
    // calculate the region for laying out text
    
    CGFloat y = _topMargin + self.topStatusBarView.frame.origin.y + self.topStatusBarView.frame.size.height;
    CGFloat h = sizeOfScreen.height - self.bottomStatusBarView.frame.size.height - self.topStatusBarView.frame.size.height - _topMargin - _bottomMargin;
    _rectOfTextView = CGRectMake(_horizontalMargin, y, sizeOfScreen.width - 2 * _horizontalMargin, h);
    
    // add content view
    _contentView = [[UIView alloc] initWithFrame:_rectOfScreen];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:self.backgroundImage]];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_contentView];
    [self.view sendSubviewToBack:_contentView];
    

    // set status bars' color
    [self.topStatusBarView setBackgroundColor:[UIColor colorWithPatternImage:_backgroundImage]];
    
    // crop background image to match the bottom part
    CGRect cropRect = CGRectMake(0, _backgroundImage.size.height - _bottomStatusBarView.bounds.size.height, _backgroundImage.size.width, _backgroundImage.size.height);
    [self.bottomStatusBarView setBackgroundColor:[UIColor colorWithPatternImage:[_backgroundImage crop:cropRect]]];
    
    // set color of the text in the status bars
    UIColor *statusBarTextColor = [VCHelperClass changeUIColor:_textColor alphaValueTo:0.7];
    [self.chapterTitleLabel setTextColor:statusBarTextColor];
    [self.pageLabel setTextColor:statusBarTextColor];
    [self.batteryLabel setTextColor:statusBarTextColor];
    [self.currentTimeLabel setTextColor:statusBarTextColor];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:_book.bookName forKey:@"the last read book"];

}

-(void) start {
    
    // custom UI settings for status bar and navigation bar
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self showStatusBar:NO];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.barTintColor = [_backgroundImage averageColor];
    self.navigationController.navigationBar.tintColor = [VCHelperClass changeUIColor:_textColor alphaValueTo:0.5];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[VCHelperClass changeUIColor:_textColor alphaValueTo:0.5],NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chapter_list_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showChapters:)];
    
    NSArray *actionButtonItems = @[item];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    self.tabBarController.tabBar.hidden = YES;
    
    // turn off gesture for navigation
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
//    _chapterNumber = 0;
//    _pageNumber = 0;
    _chapterNumber = [[VCHelperClass getDatafromBook:_book.bookName withField:@"savedChapterNumber"] intValue];
    _pageNumber = [[VCHelperClass getDatafromBook:_book.bookName withField:@"savedPageNumber"] intValue];

    
    [self.activityIndicator startAnimating];
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
        [self initPages]; // execute only once
        
        [self updateProgessInfo];
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
    });
    
    [self startMonitoringBattery];
    [self StartTimerForClock];
    

}

- (void)showStatusBar:(BOOL)show {
    
    [UIView animateWithDuration:0.3 animations:^{
        _statusBarHidden = !show;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

-(void) applicationWillEnterForeground:(NSNotification *)notification {
    
}


-(void) applicationWillResignActive:(NSNotification *)notification {
    
    [VCHelperClass storeIntoBook:_book.bookName withField:@"savedPageNumber" andData:@(_pageNumber).stringValue];
    [VCHelperClass storeIntoBook:_book.bookName withField:@"savedChapterNumber" andData:@(_chapterNumber).stringValue];

}

#pragma mark - uicontrol callbacks

-(void)showChapters:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VCChapterTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"VCChapterTableViewController"];
    vc.book = _book;
    vc.chapterNumber = _chapterNumber;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark gesture callback

-(void)swipeUp:(id)sender {
    
//    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (_chapterNumber == _book.totalNumberOfChapters - 1 && _pageNumber == _totalNumberOfPage - 1) {
        
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showThePageAt:_pageNumber];
            
        } completion:nil];
        return;
    }
    _pageNumber++;

    
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        [self showThePageAt:_pageNumber];
        
    } completion:^(BOOL finished) {
        
        if (_pageNumber > _totalNumberOfPage - 1) {
            
            [self nextChapter];
            
        }
        
        [self updateProgessInfo];
        
    }];
    
}

-(void)swipeDown:(id)sender {
    
//    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (_chapterNumber == 0 && _pageNumber == 0) {
     
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showThePageAt:_pageNumber];
            
        } completion:nil];
        return;
    }
    _pageNumber--;
    
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        [self showThePageAt:_pageNumber];
        
    } completion:^(BOOL finished) {
        
        if (_pageNumber < 0){
            
            [self previousChapter];
        }
        
        [self updateProgessInfo];
        
    }];
    
    

}

#pragma mark - chapters and pages related

-(void) initPages {
    
    VCChapter *currentChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:_chapterNumber inViewController:self inViewingRect:_rectOfTextView];
    
    //render pages in the Current and the adjacent chapters and store pages of the current chapter and prefetched pages in the previous and next chapter into _pageArray
    
    _pagesInThePreviousChapter = [currentChapter renderPagesInThePreviousChapter];
    _pagesInTheNextChapter = [currentChapter renderPagesInTheNextChapter];
    
    _pageArray = [currentChapter renderPages];
    
    _totalNumberOfPage = (int)_pageArray.count;

    if (_chapterNumber > 0 && _pagesInThePreviousChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            if ([_pagesInThePreviousChapter objectAtIndex:(_pagesInThePreviousChapter.count - 1 - i)]) {
                [_pageArray insertObject:[_pagesInThePreviousChapter objectAtIndex:(_pagesInThePreviousChapter.count - 1 - i)] atIndex:0];
                
            }
        }
    }
    
    
    if (_chapterNumber < _book.totalNumberOfChapters - 1 && _pagesInTheNextChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            if ([_pagesInTheNextChapter objectAtIndex:i]) {
                
                [_pageArray addObject:[_pagesInTheNextChapter objectAtIndex:i]];
                
            }
        }
    }
    
//    for (VCPage *p in _pageArray) {
//        NSLog(@"%s: c:%d p:%d", __PRETTY_FUNCTION__, p.chapterNumber, p.pageNumber);
//    }
//    

    [VCHelperClass removeAllSubviewsInView:self.contentView];
    
    for (int i = 0; i < _pageArray.count; i++) {
        int index;
        if (_chapterNumber != 0) {
            index = i - _pageNumber - NUMBER_OF_PREFETCH_PAGES;
        } else {
            index = i - _pageNumber;
        }
        VCPage *page = [_pageArray objectAtIndex:i];
        UIView *view = page.view;
        [view setFrame:CGRectMake(0.0, index * _rectOfScreen.size.height, _rectOfScreen.size.width, _rectOfScreen.size.height)];
        [self.contentView addSubview:view];
    }
}

-(void) nextChapter {
    
    _chapterNumber++;
    _pageNumber = 0;

    // move previously rendered pages useful to the array _pagesInThePreviousChapter
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange((_chapterNumber == 1 ? 0 : NUMBER_OF_PREFETCH_PAGES), _totalNumberOfPage)];
    _pagesInThePreviousChapter = [_pageArray objectsAtIndexes:indexSet];

    
    // move previously rendered pages stored in the pages of the next chapter array to _pageArray
    
    _pageArray = [[NSMutableArray alloc] initWithArray:_pagesInTheNextChapter];
    _totalNumberOfPage = (int)_pageArray.count;
    
    // create/render new pages into the next chapter array
    VCChapter *currentChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:_chapterNumber inViewController:self inViewingRect:_rectOfTextView];
    _pagesInTheNextChapter = [currentChapter renderPagesInTheNextChapter];
    
    
    
    if (_chapterNumber > 0 && _pagesInThePreviousChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            if ([_pagesInThePreviousChapter objectAtIndex:(_pagesInThePreviousChapter.count - 1 - i)]) {
                [_pageArray insertObject:[_pagesInThePreviousChapter objectAtIndex:(_pagesInThePreviousChapter.count - 1 - i)] atIndex:0];
                
            }
        }
    }
    
    
    if (_chapterNumber < _book.totalNumberOfChapters - 1 && _pagesInTheNextChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            if ([_pagesInTheNextChapter objectAtIndex:i]) {
                
                [_pageArray addObject:[_pagesInTheNextChapter objectAtIndex:i]];
                
            }
        }
    }
    
//    for (VCPage *p in _pageArray) {
//        NSLog(@"%s: c:%d p:%d", __PRETTY_FUNCTION__, p.chapterNumber, p.pageNumber);
//    }
    

    
    // organize new page views in the content view
    
    [VCHelperClass removeAllSubviewsInView:_contentView];
    
    // add new views
    for (int i = 0; i < _pageArray.count; i++) {
        
        int index = i - _pageNumber -  NUMBER_OF_PREFETCH_PAGES;
        VCPage *page = [_pageArray objectAtIndex:i];
        UIView *view = page.view;
        [view setFrame:CGRectMake(0.0, index * _rectOfScreen.size.height, _rectOfScreen.size.width, _rectOfScreen.size.height)];
        [self.contentView addSubview:view];
    }
}

-(void) previousChapter {
    
    _chapterNumber--;
    
    // move previously rendered pages useful to the array _pagesInTheNextChapter
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(NUMBER_OF_PREFETCH_PAGES, _totalNumberOfPage)];
    _pagesInTheNextChapter = [_pageArray objectsAtIndexes:indexSet];
    
    // move previously rendered pages stored in the pages of the previous chapter array to _pageArray
    
    _pageArray = [[NSMutableArray alloc] initWithArray:_pagesInThePreviousChapter];
    _totalNumberOfPage = (int)_pageArray.count;
    _pageNumber = _totalNumberOfPage - 1;
    
    // create/render new pages intp the previous chapter array
    VCChapter *currentChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:_chapterNumber inViewController:self inViewingRect:_rectOfTextView];
    _pagesInThePreviousChapter = [currentChapter renderPagesInThePreviousChapter];
    
    
    
    if (_chapterNumber > 0 && _pagesInThePreviousChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            if ([_pagesInThePreviousChapter objectAtIndex:(_pagesInThePreviousChapter.count - 1 - i)]) {
                [_pageArray insertObject:[_pagesInThePreviousChapter objectAtIndex:(_pagesInThePreviousChapter.count - 1 - i)] atIndex:0];
                
            }
        }
    }
    
    
    if (_chapterNumber < _book.totalNumberOfChapters - 1 && _pagesInTheNextChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            if ([_pagesInTheNextChapter objectAtIndex:i]) {
                
                [_pageArray addObject:[_pagesInTheNextChapter objectAtIndex:i]];
                
            }
        }
    }
    
//    for (VCPage *p in _pageArray) {
//        NSLog(@"%s: c:%d p:%d", __PRETTY_FUNCTION__, p.chapterNumber, p.pageNumber);
//    }
    

    
    // organize new page views in the content view
    
    [VCHelperClass removeAllSubviewsInView:_contentView];

    // add new views
    for (int i = 0; i < _pageArray.count; i++) {
        
        int index = i - _pageNumber - (_chapterNumber == 0 ? 0 : NUMBER_OF_PREFETCH_PAGES);
        VCPage *page = [_pageArray objectAtIndex:i];
        UIView *view = page.view;
        [view setFrame:CGRectMake(0.0, index * _rectOfScreen.size.height, _rectOfScreen.size.width, _rectOfScreen.size.height)];
        [self.contentView addSubview:view];
    }
}

-(void)showThePageAt:(int)pageNumber {
    
//    NSLog(@"%s: c:%d p:%d", __PRETTY_FUNCTION__, _chapterNumber, pageNumber);
    
    for (int i = 0; i < _pageArray.count; i++) {
        
        int index;
        if (_chapterNumber != 0) {
            index = i - _pageNumber - NUMBER_OF_PREFETCH_PAGES;
        } else {
            index = i - _pageNumber;
        }
        
        VCPage *page = [_pageArray objectAtIndex:i];
        UIView *view = page.view;
        [view setFrame:CGRectMake(0.0, index * _rectOfScreen.size.height, _rectOfScreen.size.width, _rectOfScreen.size.height)];
    }
}

-(void) showPageWithScrollOffsetByUserTouch {
    
    for (int i = 0; i < _pageArray.count; i++) {
        VCPage *page = [_pageArray objectAtIndex:i];
        [page.view setFrame:CGRectMake(0, page.view.frame.origin.y + _deltaOffset, _rectOfScreen.size.width, _rectOfScreen.size.height)];
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

- (void)batteryStatusDidChange:(NSNotification *)notification {
    
    NSArray *batteryStatusImages = [NSArray arrayWithObjects:
                              /*Battery status is unknown*/ [UIImage imageNamed:@"battery_not_charging_icon"],
                              /*"Battery is in use (discharging)*/ [UIImage imageNamed:@"battery_not_charging_icon"],
                              /*Battery is charging*/ [UIImage imageNamed:@"battery_charging_icon"],
                              /*Battery is fully charged*/ [UIImage imageNamed:@"battery_not_charging_icon"], nil];
    UIColor *batteryIconColor = [VCHelperClass changeUIColor:_textColor alphaValueTo:0.3];

    [self.batteryImageView setImage:[VCHelperClass maskedImageNamed:[batteryStatusImages objectAtIndex:[[UIDevice currentDevice] batteryState]] color:batteryIconColor]];

}

-(void) startMonitoringBattery {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelDidChange:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusDidChange:) name:UIDeviceBatteryStateDidChangeNotification object:nil];

    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    self.batteryLabel.text = [NSString stringWithFormat:@"%.0f%%",[[UIDevice currentDevice] batteryLevel] * 100.0f];


}
-(void) batteryLevelDidChange:(NSNotification *)notification {
    self.batteryLabel.text = [NSString stringWithFormat:@"%.0f%%",[[UIDevice currentDevice] batteryLevel] * 100.0f];
}

#pragma mark - touch functions

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    NSLog(@"%s",__PRETTY_FUNCTION__);

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
//    NSLog(@"%@", NSStringFromCGPoint(point));
    
    _previousOffset = 0;
    _deltaOffset = 0;
    _lastTouchedPointY = point.y;

}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
//    NSLog(@"%@", NSStringFromCGPoint(point));
    
    CGFloat pointY = point.y;
    CGFloat yDisplacement = (pointY - _lastTouchedPointY);

    _deltaOffset = yDisplacement - _previousOffset;
    
    [self showPageWithScrollOffsetByUserTouch];

    _previousOffset = yDisplacement;

    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    NSLog(@"%s",__PRETTY_FUNCTION__);

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
    
    if (yDisplacement < 10 && yDisplacement > -10) {
        [self toggleNavigationBar];
    }
}

-(void) toggleNavigationBar {
    
    CGRect frame = self.navigationController.navigationBar.bounds;
    
    if (self.navigationController.navigationBar.hidden == YES) {
        
        self.navigationController.navigationBar.hidden = NO;
        
        [self.navigationController.navigationBar setFrame:CGRectMake(0, -20 - frame.size.height, frame.size.width, frame.size.height)];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showStatusBar:YES];
            [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, frame.size.width, frame.size.height)];

        } completion:nil];
        
    } else {

        [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, frame.size.width, frame.size.height)];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self showStatusBar:NO];
            [self.navigationController.navigationBar setFrame:CGRectMake(0,  -frame.size.height - 20, frame.size.width, frame.size.height)];
        } completion:^(BOOL finished) {
            self.navigationController.navigationBar.hidden = YES;

        }];
    }

    
}

-(void) updateProgessInfo {

    self.chapterNumberLabel.text = [NSString stringWithFormat:@"%d章", _chapterNumber + 1];
    self.pageLabel.text = [NSString stringWithFormat:@"%d頁/%d頁", _pageNumber + 1, _totalNumberOfPage];
    if (_pageNumber != 0) {
        self.chapterTitleLabel.text = [_book getChapterTitleStringFromChapterNumber:_chapterNumber];
    } else {
        self.chapterTitleLabel.text = @"";
    }
}


@end
