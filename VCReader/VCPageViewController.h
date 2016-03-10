//
//  VCPageViewController.h
//  VCReader
//
//  Created by victor on 1/24/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCBook.h"
#import "VCView.h"
#import "VCChapter.h"

@interface VCPageViewController : UIViewController

@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) UIColor *textColor;
@property (assign) CGFloat topMargin;
@property (assign) CGFloat horizontalMargin;
@property (assign) CGFloat bottomMargin;
@property (assign) CGFloat textLineSpacing;
@property (assign) CGFloat charactersSpacing;
@property (assign) CGFloat chapterTitleFontSize;
@property (assign) CGFloat chapterContentFontSize;
@property (strong) NSMutableDictionary *textRenderAttributionDict;

@property (strong, nonatomic) VCBook *book;
@property (assign) int chapterNumber;
@property (assign) int pageNumber;


@property (strong, nonatomic) UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *chapterNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *chapterTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *batteryImageView;
@property (weak, nonatomic) IBOutlet UIView *topStatusBarView;
@property (weak, nonatomic) IBOutlet UIView *bottomStatusBarView;


@end
