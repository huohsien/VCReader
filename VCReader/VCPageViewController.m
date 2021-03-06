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
#import "VCReadingStatusMO+CoreDataProperties.h"
#import "VCColorPicker.h"

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
        VCLOG(@"could not scale image");
    
    
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
    
    BOOL _isEditingTextView;
    
    NSMutableArray *_pageArray;
    VCChapter *_previousChapter;
    VCChapter *_currentChapter;
    VCChapter *_nextChapter;
   
    int _chapterNumber;
    int _pageNumber;
    
    BOOL _isSyncing;
    int _animatingCount;
    
    UIImageView *_imageView;
    UIView *_toolBarView;
    UIColor *_barColor;
    UIColor *_textColorInBar;
    VCColorPicker *_colorPickerForFont;
    VCColorPicker *_colorPickerForBackground;
    
    CGFloat _currentRotationalPosition;

    
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


@synthesize dict;

- (void)updateColorScheme {
    
    // resize bg image
    _backgroundImage = [_backgroundImage imageByScalingProportionallyToSize:_rectOfScreen.size];
    // set page status bars' color
    [self.topStatusBarView setBackgroundColor:[UIColor colorWithPatternImage:_backgroundImage]];

    // crop background image to match the bottom part
    CGRect cropRect = CGRectMake(0, _backgroundImage.size.height - _bottomStatusBarView.bounds.size.height, _backgroundImage.size.width, _backgroundImage.size.height);
    [self.bottomStatusBarView setBackgroundColor:[UIColor colorWithPatternImage:[_backgroundImage crop:cropRect]]];
    
    // set color of the text in the status bars
    UIColor *statusBarTextColor = [VCTool changeUIColor:_textColor alphaValueTo:0.7];
    [self.chapterTitleLabel setTextColor:statusBarTextColor];
    [self.pageLabel setTextColor:statusBarTextColor];
    [self.batteryLabel setTextColor:statusBarTextColor];
    [self.currentTimeLabel setTextColor:statusBarTextColor];
    [self.totalBookReadProgressLabel setTextColor:statusBarTextColor];
    
    _textColorInBar = [VCTool adjustUIColor:_textColor brightenFactor:2];
    _barColor = [VCTool adjustUIColor:[_backgroundImage averageColor] brightenFactor:1.06];
    self.navigationController.navigationBar.barTintColor = _barColor;
    self.navigationController.navigationBar.tintColor = _textColorInBar;
    

    UIImage *image = [VCTool maskedImage:[UIImage imageNamed:@"sync_progress_icon"] color:_textColorInBar];
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.autoresizingMask = UIViewAutoresizingNone;
    _imageView.contentMode = UIViewContentModeCenter;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button addSubview:_imageView];
    [button addTarget:self action:@selector(syncReadingStatusDataAndShowErrorMessage) forControlEvents:UIControlEventTouchUpInside];
    _imageView.center = button.center;
    
    button.imageView.clipsToBounds = NO;
    button.imageView.contentMode = UIViewContentModeCenter;
    _currentRotationalPosition = 0;
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chapter_list_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showChapters:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:button];
    NSArray *actionButtonItems = @[item1,item2];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    [self updateBatteryIcon];
    
    [_toolBarView removeFromSuperview];
    _toolBarView = nil;
    [self addColorToolBar];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _topMargin = 0;
    _bottomMargin = 0;
    _horizontalMargin = 10;
    _textLineSpacing = 15;
    _charactersSpacing = 4.0;
    
    _rectOfScreen = [[UIScreen mainScreen] bounds];
    
    UIColor *backgroundColor = [VCTool getObjectWithKey:@"background color"];
    UIColor *fontColor = [VCTool getObjectWithKey:@"font color"];
    if (backgroundColor == nil) {
        
        _backgroundImage = [UIImage imageFromColor:[UIColor colorWithRed:13 / 255.0 green:13 / 255.0 blue:13 / 255.0 alpha:1.0] withRect:_rectOfScreen];
        [VCTool storeObject:[_backgroundImage averageColor] withKey:@"background color"];
        
    } else {
        _backgroundImage = [UIImage imageFromColor:[VCTool getObjectWithKey:@"background color"] withRect:_rectOfScreen];
    }
    if (fontColor == nil) {
        
        _textColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha: 1.0];
        [VCTool storeObject:_textColor withKey:@"font color"];
        
    } else {
        _textColor = [VCTool getObjectWithKey:@"font color"];
    }
    // init objects and vars
    //
    
    _textRenderAttributionDict = [NSMutableDictionary new];
    [_textRenderAttributionDict setObject:_textColor forKey:@"text color"];
    
    _isSyncing = NO;
    
    
    // setup UIs
    //
    
    self.title = @"";
    
    CGSize sizeOfScreen = _rectOfScreen.size;
    //    VCLOG(@"screen resolution:%@", NSStringFromCGSize(sizeOfScreen));
    
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

    [self.view bringSubviewToFront:self.topStatusBarView];
    [self.view bringSubviewToFront:self.bottomStatusBarView];
    
    
    // set page status bars' color
    [self.topStatusBarView setBackgroundColor:[UIColor colorWithPatternImage:_backgroundImage]];
    
    // crop background image to match the bottom part
    CGRect cropRect = CGRectMake(0, _backgroundImage.size.height - _bottomStatusBarView.bounds.size.height, _backgroundImage.size.width, _backgroundImage.size.height);
    [self.bottomStatusBarView setBackgroundColor:[UIColor colorWithPatternImage:[_backgroundImage crop:cropRect]]];
    
    // set color of the text in the status bars
    UIColor *statusBarTextColor = [VCTool changeUIColor:_textColor alphaValueTo:0.7];
    [self.chapterTitleLabel setTextColor:statusBarTextColor];
    [self.pageLabel setTextColor:statusBarTextColor];
    [self.batteryLabel setTextColor:statusBarTextColor];
    [self.currentTimeLabel setTextColor:statusBarTextColor];
    [self.totalBookReadProgressLabel setTextColor:statusBarTextColor];
    
    //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [VCTool storeObject:_book.bookName withKey:@"nameOfTheLastReadBook"];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    // init vars
    //
    
    _isEditingTextView = NO;
    _animatingCount = 0;
    
    // setup UIs
    //
    
    // custom UI settings for status bar and navigation bar
    
    [self showStatusBar:NO];
    
    _textColorInBar = [VCTool adjustUIColor:_textColor brightenFactor:2];
    _barColor = [VCTool adjustUIColor:[_backgroundImage averageColor] brightenFactor:1.06];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.barTintColor = _barColor;
    self.navigationController.navigationBar.tintColor = _textColorInBar;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setTranslucent:YES];

    [_toolBarView setHidden:YES];
    
    UIImage *image = [VCTool maskedImage:[UIImage imageNamed:@"sync_progress_icon"] color:_textColorInBar];
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.autoresizingMask = UIViewAutoresizingNone;
    _imageView.contentMode = UIViewContentModeCenter;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button addSubview:_imageView];
    [button addTarget:self action:@selector(syncReadingStatusDataAndShowErrorMessage) forControlEvents:UIControlEventTouchUpInside];
    _imageView.center = button.center;
    
    button.imageView.clipsToBounds = NO;
    button.imageView.contentMode = UIViewContentModeCenter;
    _currentRotationalPosition = 0;
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chapter_list_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showChapters:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:button];
    

    NSArray *actionButtonItems = @[item1,item2];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
//    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"<返回" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    
    self.tabBarController.tabBar.hidden = YES;
    
    [self addColorToolBar];
    [self addColorPickers];

    
    // turn off gesture for navigation
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    VCLOG(@"call syncReadingStatusData");
    [self syncReadingStatusDataAndShowErrorMessage:NO completion:^(BOOL finished) {
        if (finished) [self loadContent];
    }];
    
    VCLOG("call showActivityView");
    [VCTool showActivityView];
    
    [self startMonitoringBattery];
    [self StartTimerForClock];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];

    VCLOG();
    // because the view controller "color theme" here is different from default, so when being navigated out, this controller has the responsibility to restore the default color theme
    //
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        
        // detect going back in navigation chain
        //prepare the to be shown controlller with correct UI style
        
        UIViewController *vc = self.navigationController.topViewController;
        vc.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        vc.navigationController.navigationBar.barTintColor = [UIColor redColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
        vc.tabBarController.tabBar.hidden = NO;
        
        [VCTool storeObject:nil withKey:@"nameOfTheLastReadBook"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    } else {
        
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.hidden = YES;
    }
    
    
    
    [[VCCoreDataCenter sharedInstance] updateReadingStatusForBook:_book.bookName chapterNumber:_chapterNumber wordNumber:[self getWordNumberFromPageNumber:_pageNumber]];
    
    
    VCLOG(@"call syncReadingStatusData");
    [self syncReadingStatusDataAndShowErrorMessage:NO completion:nil];
    
}

-(BOOL)prefersStatusBarHidden {
    
    return _statusBarHidden;
}

-(void) goBack {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadContent {
    
    VCLOG();
    dispatch_async(dispatch_get_main_queue(), ^{
        
        VCReadingStatusMO *readingStatus = [[VCCoreDataCenter sharedInstance] getReadingStatusForBook:_book.bookName];
        _chapterNumber = readingStatus.chapterNumber;
        _currentChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:_chapterNumber inViewController:self inViewingRect:_rectOfTextView];
        _pageNumber = [self getPageNumberFromWordNumber:readingStatus.wordNumber];
        
        [self initPages]; // execute only once

        [self updateProgessInfo];
        [VCTool hideActivityView];
    });
    
}

- (void)showStatusBar:(BOOL)show {
    
    [UIView animateWithDuration:0.3 animations:^{
        _statusBarHidden = !show;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

-(void) applicationDidBecomeActive:(NSNotification *)notification {

    VCLOG(@"call syncReadingStatusData");

    [self syncReadingStatusDataAndShowErrorMessage:NO completion:^(BOOL finished) {
        if (finished) [self loadContent];
    }];

}


-(void) applicationWillResignActive:(NSNotification *)notification {
    
    VCLOG();
    
    if ([VCTool getObjectWithKey:@"token"]) {
        [[VCCoreDataCenter sharedInstance] updateReadingStatusForBook:_book.bookName chapterNumber:_chapterNumber wordNumber:[self getWordNumberFromPageNumber:_pageNumber]];
    }
}

#pragma mark - animation

- (void) animateImageView {
    
    CGFloat rotationRate = M_PI / 0.4;
    CGFloat rotationUnitTime = 0.1;
    [UIView animateWithDuration:rotationUnitTime delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        _imageView.transform = CGAffineTransformMakeRotation( _currentRotationalPosition + rotationUnitTime * rotationRate);
    } completion:^(BOOL finished) {
        
        _currentRotationalPosition += rotationUnitTime * rotationRate;
        
        if (_animatingCount > 0) {
            // if flag still set, keep spinning with constant speed
            [self animateImageView];
        }
    }];
}

- (void) startSpin {
    
    _animatingCount++;
    if (_animatingCount > 0) {
        VCLOG(@"animating count increases by 1. current count = %d",_animatingCount);
        [self animateImageView];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    _animatingCount--;
    VCLOG(@"animating count decreases by 1. current count = %d",_animatingCount);
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
    
    // hide nav bar when moving pages
    [self hideBars];
    
    // handle the case of the last page of the book
    if (_chapterNumber == _book.totalNumberOfChapters - 1 && _pageNumber == _currentChapter.pageArray.count - 1) {
        
        VCLOG(@"hit the last page of the book");
        
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showThePageAt:_pageNumber];
            
        } completion:nil];
        return;
    }
    
    _pageNumber++;
    
    // store reading status locally
    if (_pageNumber <= _currentChapter.pageArray.count - 1) {
        [[VCCoreDataCenter sharedInstance] updateReadingStatusForBook:_book.bookName chapterNumber:_chapterNumber wordNumber:[self getWordNumberFromPageNumber:_pageNumber]];
    }
    
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        [self showThePageAt:_pageNumber];
        
    } completion:^(BOOL finished) {
    
        // prefetch the pages of the new chapter. set up new page and chapter number
        if (_pageNumber > _currentChapter.pageArray.count - 1) {
            
            [self nextChapter];
            
        }
        
        [self updateProgessInfo];
        
    }];
    
}

-(void)swipeDown:(id)sender {
    
    // hide nav bar when moving pages
    [self hideBars];
    
    // handle the case of the first page of the book
    if (_chapterNumber == 0 && _pageNumber == 0) {
     
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showThePageAt:_pageNumber];
            
        } completion:nil];
        return;
    }
    _pageNumber--;

    // store reading status locally
    if (_pageNumber >= 0) {
        [[VCCoreDataCenter sharedInstance] updateReadingStatusForBook:_book.bookName chapterNumber:_chapterNumber wordNumber:[self getWordNumberFromPageNumber:_pageNumber]];
    }
    
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        [self showThePageAt:_pageNumber];
        
    } completion:^(BOOL finished) {
        
        if (_pageNumber < 0){
            
            // prefetch the pages of the new chapter. set up new page and chapter number
            [self previousChapter];
        }
        
        [self updateProgessInfo];
        
    }];
    
    

}

#pragma mark - chapters and pages related

-(int) getPageNumberFromWordNumber:(int)wordNumber {
    
    for (int i = 1; i < _currentChapter.firstWordCountOfEachPage.count; i++) {
        
        if (wordNumber < [[_currentChapter.firstWordCountOfEachPage objectAtIndex:i] intValue]) {
            return  i - 1;
        }
//        VCLOG(@"word number = %d", [[_currentChapter.firstWordCountOfEachPage objectAtIndex:i] intValue]);
    }
    
    return (int)_currentChapter.firstWordCountOfEachPage.count - 1;
}

-(int) getWordNumberFromPageNumber:(int)pageNumber {

    return [[_currentChapter.firstWordCountOfEachPage objectAtIndex:pageNumber] intValue];
}

- (void)updateFontColorForCurrentPage {

    NSUInteger index = NUMBER_OF_PREFETCH_PAGES + _pageNumber;
    VCPage *page = [_pageArray objectAtIndex:index];
    [page.textView setTextColor:_textColor];
}

-(void) initPages {
    
    _currentChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:_chapterNumber inViewController:self inViewingRect:_rectOfTextView];
    _previousChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:(_chapterNumber - 1) inViewController:self inViewingRect:_rectOfTextView];
    _nextChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:(_chapterNumber + 1) inViewController:self inViewingRect:_rectOfTextView];
    
    //render pages in the Current and the adjacent chapters and store pages of the current chapter and prefetched pages in the previous and next chapter into _pageArray
    
    
    _pageArray = [NSMutableArray arrayWithArray:_currentChapter.pageArray];
    
    
    if (_chapterNumber > 0 && _previousChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            [_pageArray insertObject:[_previousChapter.pageArray objectAtIndex:(_previousChapter.pageArray.count - 1 - i)] atIndex:0];
                
        }
    }
    

    
    if (_chapterNumber < _book.totalNumberOfChapters - 1 && _nextChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            [_pageArray addObject:[_nextChapter.pageArray objectAtIndex:i]];
                
        }
    }
    
//    for (VCPage *p in _pageArray) {
//        VCLOG(@"c:%d p:%d", p.chapterNumber, p.pageNumber);
//    }
    

    [VCTool removeAllSubviewsInView:self.contentView];
    
    // add all pages to the content view
    //
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


    _previousChapter = _currentChapter;
    _currentChapter = _nextChapter;
    
    _nextChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:(_chapterNumber + 1) inViewController:self inViewingRect:_rectOfTextView];
    
    _pageArray = [NSMutableArray arrayWithArray:_currentChapter.pageArray];
    
    if (_chapterNumber > 0 && _previousChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            [_pageArray insertObject:[_previousChapter.pageArray objectAtIndex:(_previousChapter.pageArray.count - 1 - i)] atIndex:0];
            
        }
    }
    
    
    if (_chapterNumber < _book.totalNumberOfChapters - 1 && _nextChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
                [_pageArray addObject:[_nextChapter.pageArray objectAtIndex:i]];
        }
    }
    
//    for (VCPage *p in _pageArray) {
//        VCLOG(@"c:%d p:%d", p.chapterNumber, p.pageNumber);
//    }
    
    [[VCCoreDataCenter sharedInstance] updateReadingStatusForBook:_book.bookName chapterNumber:_chapterNumber wordNumber:[self getWordNumberFromPageNumber:_pageNumber]];

    
    // organize new page views in the content view
    
    [VCTool removeAllSubviewsInView:_contentView];
    
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
    _pageNumber = (int) _previousChapter.pageArray.count - 1;


    _nextChapter = _currentChapter;
    _currentChapter = _previousChapter;
    
    _previousChapter = [[VCChapter alloc] initForVCBook:_book OfChapterNumber:(_chapterNumber - 1) inViewController:self inViewingRect:_rectOfTextView];
    
    _pageArray = [NSMutableArray arrayWithArray:_currentChapter.pageArray];

    
    if (_chapterNumber > 0 && _previousChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            [_pageArray insertObject:[_previousChapter.pageArray objectAtIndex:(_previousChapter.pageArray.count - 1 - i)] atIndex:0];
            
        }
    }
    
    
    if (_chapterNumber < _book.totalNumberOfChapters - 1 && _nextChapter) {
        
        for (int i = 0; i < NUMBER_OF_PREFETCH_PAGES; i++) {
            
            [_pageArray addObject:[_nextChapter.pageArray objectAtIndex:i]];
        }
    }
    
//    for (VCPage *p in _pageArray) {
//        VCLOG(@"c:%d p:%d", p.chapterNumber, p.pageNumber);
//    }
    
    [[VCCoreDataCenter sharedInstance] updateReadingStatusForBook:_book.bookName chapterNumber:_chapterNumber wordNumber:[self getWordNumberFromPageNumber:_pageNumber]];

    
    // organize new page views in the content view
    
    [VCTool removeAllSubviewsInView:_contentView];

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
    
//    VCLOG(@"c:%d p:%d", _chapterNumber, pageNumber);
    
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

#pragma mark - syncing between core data and web server

-(void) syncReadingStatusDataAndShowErrorMessage {

    [self syncReadingStatusDataAndShowErrorMessage:YES completion:nil];

}

-(void) syncReadingStatusDataAndShowErrorMessage:(BOOL)showErrorMessage completion:(void (^)(BOOL finished))completion {
    
    if (_isSyncing == YES) {
        
        return;
    }
    _isSyncing = YES;
    
    VCLOG();

    if (!_book) return;
    
    [self startSpin];
    VCLOG(@"callAPI");
    [[VCReaderAPIClient sharedClient] callAPI:@"user_status_get" params:@{@"token" : [VCTool getObjectWithKey:@"token"], @"book_name" : _book.bookName} showErrorMessage:showErrorMessage success:^(NSURLSessionDataTask *task, id responseObject) {
        
        self.dict = responseObject;
        
        if (dict[@"error"]) {
            
            if ([dict[@"error"][@"code"] isEqualToString:@"101"]) {
                
                VCLOG(@"there is no datum on the server");
                
                VCReadingStatusMO *readingStatus = [[VCCoreDataCenter sharedInstance] getReadingStatusForBook:_book.bookName];
                
                if (readingStatus) {
                    
                    VCLOG(@"there are data in core data. Upload data to server");
                    
                    NSString *chapter = [NSString stringWithFormat:@"%d", readingStatus.chapterNumber];
                    NSString *word = [NSString stringWithFormat:@"%d", readingStatus.wordNumber];
                    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)readingStatus.timestamp];
                    
                    [self startSpin];
                    VCLOG(@"callAPI");
                    [[VCReaderAPIClient sharedClient] callAPI:@"user_status_add" params:@{@"token" : [VCTool getObjectWithKey:@"token"], @"book_name" : _book.bookName, @"current_reading_chapter" : chapter, @"current_reading_word" : word, @"timestamp" : timestamp} showErrorMessage:YES  success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        readingStatus.synced = YES;
                        [[VCCoreDataCenter sharedInstance] saveContext];
                        
                        VCLOG(@"finish upload data to server. Now load page and ready for user to read");
                        _isSyncing = NO;
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                            
                        VCLOG(@"Failure: %@", error.debugDescription);
                        
                        [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
                        _isSyncing = NO;

                    } completion:^(BOOL finished) {
                        [self stopSpin];
                    }];
                    
                } else {
                    
                    VCLOG(@"no reading record in either server or core data");
                    [[VCCoreDataCenter sharedInstance] initReadingStatusForBook:_book.bookName isDummy:NO];
                    
                    VCLOG(@"ready for user to read a new book");
                    _isSyncing = NO;
                }
                
            }  else if ([dict[@"error"][@"code"] isEqualToString:@"100"]) {
                
                VCLOG(@"The book is not found on the server");
                [self.navigationController popViewControllerAnimated:YES];
                _isSyncing = NO;

            } else {
                
                VCLOG(@"dict=%@", dict);
                _isSyncing = NO;
            }
            
        } else if (dict[@"token"]) {
        
            NSTimeInterval timestampFromServer = [dict[@"timestamp"] doubleValue];
            VCReadingStatusMO *readingStatus = [[VCCoreDataCenter sharedInstance] getReadingStatusForBook:_book.bookName];
            
            if (readingStatus) {
                
                if (readingStatus.timestamp > timestampFromServer) {
                    
                    VCLOG(@"what were stored in core data are the lastest data. so update server");
                    
                    NSString *chapter = [NSString stringWithFormat:@"%d", readingStatus.chapterNumber];
                    NSString *word = [NSString stringWithFormat:@"%d", readingStatus.wordNumber];
                    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)readingStatus.timestamp];
                    
                    [self startSpin];
                    VCLOG(@"callAPI");
                    [[VCReaderAPIClient sharedClient] callAPI:@"user_status_add" params:@{@"token" : [VCTool getObjectWithKey:@"token"], @"book_name" : _book.bookName, @"current_reading_chapter" : chapter, @"current_reading_word" : word, @"timestamp" : timestamp} showErrorMessage:YES success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        VCLOG(@"server data updated. change synced flag to YES and load page");
                        
                        readingStatus.synced = YES;
                        [[VCCoreDataCenter sharedInstance] saveContext];
                        
                        VCLOG(@"finish syncing server with core data. ready for users to read");
                        
                        _isSyncing = NO;

                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                        VCLOG(@"Failure: %@", error.debugDescription);
                        
                        [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
                        _isSyncing = NO;
                        
                    } completion:^(BOOL finished) {
                        [self stopSpin];
                    }];
                    
                } else {
                    
                    VCLOG(@"what were stored in the server are the lastest data so update core data");
                    
                    NSTimeInterval timestampFromServer = [dict[@"timestamp"] doubleValue];
                    [[VCCoreDataCenter sharedInstance] updateReadingStatusForBook:dict[@"book_name"] chapterNumber:[dict[@"chapter"] intValue] wordNumber:[dict[@"word"] intValue] timestampFromServer:timestampFromServer];
                    
                    VCLOG(@"finish syncing core data with data in server. ready for users to read");
                    
                    _isSyncing = NO;

                }
                
            } else {
                
                VCLOG(@"no core data record but got data in the server. first init a core data record");
                
                [[VCCoreDataCenter sharedInstance] initReadingStatusForBook:dict[@"book_name"] isDummy:YES];
                [[VCCoreDataCenter sharedInstance] updateReadingStatusForBook:dict[@"book_name"] chapterNumber:[dict[@"chapter"] intValue] wordNumber:[dict[@"word"] intValue] timestampFromServer:timestampFromServer];
                
                VCLOG(@"finish syncing core data with data in server. ready for users to read");
                
                _isSyncing = NO;

            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        VCLOG(@"Failure: %@\n response =%@", error.debugDescription, errResponse);
        _isSyncing = NO;

    } completion:^(BOOL finished) {
        if (completion) completion(finished);
        [self stopSpin];
    }];

}

#pragma mark time functions

-(void)updateTimeOnClock {
    
    self.currentTimeLabel.text = [self getCurrentTimeShortString];
    
//    VCLOG(@"update clock view");
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
    
    
    [self updateTimeOnClock];
    
    int seconds = [[self getCurrentTimeSeconds] intValue];
    if (seconds != 0) {
        [self performSelector:@selector(StartTimerForClock) withObject:nil afterDelay:(60 - seconds)];
//        VCLOG(@"compensation delay - %d", (60 - seconds));
        return;
    }
    
//    VCLOG(@"start timer");
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:60
                                             target:self
                                           selector:@selector(updateTimeOnClock)
                                           userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark battery fuctions

-(void) updateBatteryIcon {
    
    NSArray *batteryStatusImages = [NSArray arrayWithObjects:
                                    /*Battery status is unknown*/ [UIImage imageNamed:@"battery_not_charging_icon"],
                                    /*"Battery is in use (discharging)*/ [UIImage imageNamed:@"battery_not_charging_icon"],
                                    /*Battery is charging*/ [UIImage imageNamed:@"battery_charging_icon"],
                                    /*Battery is fully charged*/ [UIImage imageNamed:@"battery_not_charging_icon"], nil];
    UIColor *batteryIconColor = [VCTool changeUIColor:_textColor alphaValueTo:1.0];
    
    UIImage *maskImage = [batteryStatusImages objectAtIndex:[[UIDevice currentDevice] batteryState]];
    UIImage *image = [VCTool maskedImage:maskImage color:batteryIconColor];
    UIImage *batteryLevelIcon = [[UIDevice currentDevice] batteryState] != UIDeviceBatteryStateCharging ? [self adjustBatteryImage:image accordingToLevel:[[UIDevice currentDevice] batteryLevel]] : image;
    [self.batteryImageView setImage:batteryLevelIcon];
    
}

-(void) updateBatteryPercentage {
    
    CGFloat batteryLevel = [[UIDevice currentDevice] batteryLevel];
    
    if (batteryLevel >=0 && batteryLevel <=1.0) {
        
        self.batteryLabel.text = [NSString stringWithFormat:@"%.0f%%", batteryLevel * 100.0f];
        
        if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {

            [[VCCoreDataCenter sharedInstance] logBatteryLevel:batteryLevel timestamp:[[NSDate new] timeIntervalSince1970]];

        }

        
    } else {
        
        self.batteryLabel.text = [NSString stringWithFormat:@"%.0f%%", 1.0 * 100.0f];
    }
    
}

-(void) batteryStatusDidChange:(NSNotification *)notification {
    
    [self updateBatteryIcon];
}

-(void) startMonitoringBattery {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelDidChange:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusDidChange:) name:UIDeviceBatteryStateDidChangeNotification object:nil];

    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    [self updateBatteryPercentage];

    [self updateBatteryIcon];
    
}
-(void) batteryLevelDidChange:(NSNotification *)notification {

    
    [self updateBatteryPercentage];

    [self updateBatteryIcon];

}

-(UIImage *) adjustBatteryImage:(UIImage *)image accordingToLevel:(CGFloat)level {

    if (level < 0 || level >= 1.0) {
        return image;
    }
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGRect toBeErasedRect = CGRectMake((3.0 + 20.0 * level) / 2.0, 3.0 / 2.0, 20.0 * (1 - level) / 2.0, 8.0 / 2.0);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetRGBFillColor(c, 1.0, 1.0, 1.0, 1.0);
    CGContextSetBlendMode(c, kCGBlendModeDestinationOut);
    CGContextFillRect(c, toBeErasedRect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

#pragma mark - edit text

-(void) startEditingInTheTextView {
    
    VCPage *page = [_pageArray objectAtIndex:NUMBER_OF_PREFETCH_PAGES + _pageNumber];
    VCTextView *textView = page.textView;
    [textView setEditable:YES];
    [textView setSelectable:YES];
    [textView becomeFirstResponder];
    
}



#pragma mark - touch functions

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    
    _previousOffset = 0;
    _deltaOffset = 0;
    _lastTouchedPointX = point.x;
    _lastTouchedPointY = point.y;
    _startTime = CACurrentMediaTime();

}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    
    _elapsedTime = CACurrentMediaTime() - _startTime;
    
//    if (_elapsedTime > 1.5 && _isEditingTextView == NO) {
//        
//        _isEditingTextView = YES;
//        
//        if (self.navigationController.navigationBar.hidden == NO) {
//            [self toggleBars];
//        }
//        
//        [self startEditingInTheTextView];
//    }
//    CGFloat pointX = point.x;
    CGFloat pointY = point.y;
//    CGFloat xDisplacement = (pointX - _lastTouchedPointX);
    CGFloat yDisplacement = (pointY - _lastTouchedPointY);

    _deltaOffset = yDisplacement - _previousOffset;
    
    [self showPageWithScrollOffsetByUserTouch];

    _previousOffset = yDisplacement;

    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    

    CGFloat pointX = point.x;
    CGFloat pointY = point.y;
    CGFloat xDisplacement = (pointX - _lastTouchedPointX);
    CGFloat yDisplacement = (pointY - _lastTouchedPointY);
    
    
    if (yDisplacement < -10 && xDisplacement < 300) {
        [self swipeUp:nil];
    }
    if (yDisplacement > 10 && xDisplacement < 300) {
        [self swipeDown:nil];
    }
    if (xDisplacement > 300) {
        
        self.navigationController.navigationBar.hidden = NO;
        [self showStatusBar:YES];
        CGSize size = self.navigationController.navigationBar.frame.size;
        VCLOG(@"%@", NSStringFromCGSize(size));
        [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, size.width, size.height)];
        [self.navigationController popViewControllerAnimated:YES];
    }

    if (yDisplacement < 10 && yDisplacement > -10 && _elapsedTime < 1.5 && _isEditingTextView == NO && xDisplacement < 300) {
        
        if (_colorPickerForFont.frame.origin.y < _rectOfScreen.size.height || _colorPickerForBackground.frame.origin.y < _rectOfScreen.size.height) {

            [self colorPickerCancelled];

        } else {
            
            [self toggleBars];
        }
    }
}
- (void)colorPickerCancelled {
    
    VCLOG(@"restore color from the persistent storage");
    
    //restore bg color
    UIColor *backgroundColor = [VCTool getObjectWithKey:@"background color"];
    _backgroundImage = [UIImage imageFromColor:backgroundColor withRect:_rectOfScreen];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:self.backgroundImage]];
    [_colorPickerForBackground setColor:backgroundColor];
    [_colorPickerForBackground updateUIAccordingToColor];
    
    //restore font color
    _textColor = [VCTool getObjectWithKey:@"font color"];
    [self updateFontColorForCurrentPage];
    [_colorPickerForFont setColor:_textColor];
    [_colorPickerForFont updateUIAccordingToColor];
    
    [self updateColorScheme];
    [self hideColorPickers];
}

- (void)hideColorPickers {
    
    [self hideColorPicker:_colorPickerForFont];
    [self hideColorPicker:_colorPickerForBackground];
}

#pragma mark - navigation bar

-(void) toggleBars {
    
    CGRect frame = self.navigationController.navigationBar.bounds;
    
    if (self.navigationController.navigationBar.hidden == YES) {
        // show bars
        
        self.navigationController.navigationBar.hidden = NO;
        [_toolBarView setHidden:NO];

        // prepare the animation for both the navi and the tool bars appearing from outside visible screen
        [self.navigationController.navigationBar setFrame:CGRectMake(0, -20 - frame.size.height, frame.size.width, frame.size.height)];
        [_toolBarView setFrame:CGRectMake(0, _rectOfScreen.size.height, _toolBarView.frame.size.width, _toolBarView.frame.size.height)];

        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showStatusBar:YES];
            [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, frame.size.width, frame.size.height)];
            [_toolBarView setFrame:CGRectMake(0, _rectOfScreen.size.height - _toolBarView.frame.size.height, _toolBarView.frame.size.width, _toolBarView.frame.size.height)];
            
        } completion:nil];
        
    } else {
        //hide bars

        // prepare the animation for both the navi and the tool bars disappearing from the visible screen
        [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, frame.size.width, frame.size.height)];
        [_toolBarView setFrame:CGRectMake(0, _rectOfScreen.size.height - _toolBarView.frame.size.height, _toolBarView.frame.size.width, _toolBarView.frame.size.height)];

        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showStatusBar:NO];
            [self.navigationController.navigationBar setFrame:CGRectMake(0,  -frame.size.height - 20, frame.size.width, frame.size.height)];
            [_toolBarView setFrame:CGRectMake(0, _rectOfScreen.size.height, _toolBarView.frame.size.width, _toolBarView.frame.size.height)];
            
        } completion:^(BOOL finished) {
            self.navigationController.navigationBar.hidden = YES;
            [_toolBarView setHidden:YES];

        }];
    }

    
}

-(void) hideBars {
    
    CGRect frame = self.navigationController.navigationBar.bounds;
    
    if (self.navigationController.navigationBar.hidden == NO) {
        
        [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, frame.size.width, frame.size.height)];
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self showStatusBar:NO];
            [self.navigationController.navigationBar setFrame:CGRectMake(0,  -frame.size.height - 20, frame.size.width, frame.size.height)];
            [_toolBarView setFrame:CGRectMake(0, _rectOfScreen.size.height, _toolBarView.frame.size.width, _toolBarView.frame.size.height)];

        } completion:^(BOOL finished) {
            self.navigationController.navigationBar.hidden = YES;
            [_toolBarView setHidden:YES];
            
        }];
    }

}

#pragma mark - color picker show and hide or toggle

-(void) toggleColorPickers {
    
    [self toggleColorPicker:_colorPickerForFont];
    [self toggleColorPicker:_colorPickerForBackground];
}

-(void) toggleColorPicker:(VCColorPicker *)colorPicker {
    
    CGRect frame = colorPicker.frame;
    
    if (frame.origin.y <= _rectOfScreen.size.height) {
        // show bars
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [colorPicker setFrame:CGRectMake(0, _rectOfScreen.size.height - colorPicker.frame.size.height, colorPicker.frame.size.width, colorPicker.frame.size.height)];
            
        } completion:nil];
        
    } else {
        //hide bars

        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [colorPicker setFrame:CGRectMake(0, _rectOfScreen.size.height, colorPicker.frame.size.width, colorPicker.frame.size.height)];
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
}

-(void) hideColorPicker:(VCColorPicker *)colorPicker {
    
    CGRect frame = colorPicker.frame;
    
    if (frame.origin.y == _rectOfScreen.size.height - colorPicker.frame.size.height) {
        
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [colorPicker setFrame:CGRectMake(0, _rectOfScreen.size.height, colorPicker.frame.size.width, colorPicker.frame.size.height)];

        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - tool bar

-(void) addColorToolBar {
    
    if (_toolBarView) return;
    
    CGFloat width = _rectOfScreen.size.width;
    CGFloat padding = 4.0;
    CGFloat margin = 16.0;
    UIButton *fontColorButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, margin, (width - 2 * margin - (2 - 1) * padding) / 2, 21.0f + margin * 2)];
    [fontColorButton setTitle:@"字体颜色" forState:UIControlStateNormal];
    [fontColorButton setTitleColor:_textColorInBar forState:UIControlStateNormal];
    fontColorButton.layer.cornerRadius = 8;
    fontColorButton.layer.borderWidth = 1;
    fontColorButton.layer.borderColor = _textColorInBar.CGColor;
    [fontColorButton addTarget:self action:@selector(showColorPickerForFont:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *backgroundColorButton = [[UIButton alloc] initWithFrame:CGRectMake(margin + fontColorButton.bounds.size.width + padding, margin, (width - 2 * margin - (2 - 1) * padding) / 2, 21.0f + margin * 2)];
    [backgroundColorButton setTitle:@"背景颜色" forState:UIControlStateNormal];
    [backgroundColorButton setTitleColor:_textColorInBar forState:UIControlStateNormal];
    backgroundColorButton.layer.cornerRadius = 8;
    backgroundColorButton.layer.borderWidth = 1;
    backgroundColorButton.layer.borderColor = _textColorInBar.CGColor;
    [backgroundColorButton addTarget:self action:@selector(showColorPickerForBackground:) forControlEvents:UIControlEventTouchUpInside];

    CGFloat height = 2 * margin + fontColorButton.frame.size.height;
    _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, _rectOfScreen.size.height + height, width, height)];
    [_toolBarView setBackgroundColor:_barColor];
    
    [_toolBarView addSubview:fontColorButton];
    [_toolBarView addSubview:backgroundColorButton];
    [self.view addSubview:_toolBarView];
    [self.view bringSubviewToFront:_toolBarView];
}

- (void)showColorPickerForFont:(UIButton *)button {
    [self showColorPicker:_colorPickerForFont];
}

- (void)showColorPickerForBackground:(UIButton *)button {
    [self showColorPicker:_colorPickerForBackground];
}

- (void)showColorPicker:(VCColorPicker *)colorPicker {
    
    [self toggleColorPicker:colorPicker];
    [self toggleBars];
}

#pragma mark - color picker wheel control

- (void) addColorPickers {
    
    CGFloat width = _rectOfScreen.size.width;
    CGFloat height = _rectOfScreen.size.height * 0.5;

    _colorPickerForFont = [[VCColorPicker alloc] initWithFrame:CGRectMake(0, _rectOfScreen.size.height, width, height)];
    _colorPickerForFont.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_colorPickerForFont];
    [self.view bringSubviewToFront:_colorPickerForFont];

    [_colorPickerForFont addTarget:self
                     action:@selector(colorPickerForFontValueChanged:)
           forControlEvents:UIControlEventValueChanged];
    [_colorPickerForFont addTarget:self
                     action:@selector(colorPickerForFontColorConfirmed:)
           forControlEvents:VCColorPickerControlEventButtonClicked];
    [_colorPickerForFont setColor:_textColor];
    
    _colorPickerForBackground = [[VCColorPicker alloc] initWithFrame:CGRectMake(0, _rectOfScreen.size.height, width, height)];
    _colorPickerForBackground.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_colorPickerForBackground];
    [self.view bringSubviewToFront:_colorPickerForBackground];
    
    [_colorPickerForBackground addTarget:self
                     action:@selector(colorPickerForBackgroundValueChanged:)
           forControlEvents:UIControlEventValueChanged];
    [_colorPickerForBackground addTarget:self
                     action:@selector(colorPickerForBackgroundColorConfirmed:)
           forControlEvents:VCColorPickerControlEventButtonClicked];
    [_colorPickerForBackground setColor:[_backgroundImage averageColor]];

}

- (void)colorPickerForFontValueChanged:(VCColorPicker *)picker {
    
    _textColor = _colorPickerForFont.color;

    [self updateFontColorForCurrentPage];
    [self updateColorScheme];
}

- (void)colorPickerForFontColorConfirmed:(VCColorPicker *)picker {

    VCLOG(@"color picker button clicked");
    _textColor = _colorPickerForFont.color;
    [_textRenderAttributionDict setObject:_textColor forKey:@"text color"];
    [self initPages];
    [self updateColorScheme];
    [VCTool storeObject:_textColor withKey:@"font color"];
    [self hideColorPickers];
}

- (void)colorPickerForBackgroundValueChanged:(VCColorPicker *)picker {
    
    _backgroundImage = [UIImage imageFromColor:_colorPickerForBackground.color withRect:_rectOfScreen];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:self.backgroundImage]];
    [self updateColorScheme];

}

- (void)colorPickerForBackgroundColorConfirmed:(VCColorPicker *)picker {
    
    VCLOG(@"color picker button clicked");
    
    _backgroundImage = [UIImage imageFromColor:_colorPickerForBackground.color withRect:_rectOfScreen];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:self.backgroundImage]];
    [self updateColorScheme];
    [VCTool storeObject:[_backgroundImage averageColor] withKey:@"background color"];
    [self hideColorPickers];
}
#pragma mark -  UI of reading status

-(void) updateProgessInfo {

    NSString *numberOfWordsString = [VCTool getDatafromBook:_book.bookName withField:@"numberOfWords"];
    long numberOfWords = [numberOfWordsString intValue];
    
    NSArray *wordCountOfTheBookForTheFirstWordInChapterArray = [VCTool getDatafromBook:_book.bookName withField:@"wordCountOfTheBookForTheFirstWordInChapters"];
    NSString *wordCountOfTheBookForTheFirstWordInTheChapter = [wordCountOfTheBookForTheFirstWordInChapterArray objectAtIndex:_chapterNumber];
    long currentReadWordPosition = [wordCountOfTheBookForTheFirstWordInTheChapter intValue] + [self getWordNumberFromPageNumber:_pageNumber];
    
    float progress = (float)currentReadWordPosition / (float)numberOfWords * 100.0f;
    
    [self.totalBookReadProgressLabel setText:[NSString stringWithFormat:@"%3.1f%%", progress]];
    
    self.pageLabel.text = [NSString stringWithFormat:@"%d页/%d页", _pageNumber + 1, (int)_currentChapter.pageArray.count];
    
    if (_pageNumber != 0) {
        self.chapterTitleLabel.text = [_book getChapterTitleStringFromChapterNumber:_chapterNumber];
    } else {
        self.chapterTitleLabel.text = @"";
    }
}

@end
