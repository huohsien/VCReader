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

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *textColor;
@property (assign) CGFloat topMargin;
@property (assign) CGFloat horizontalMargin;
@property (assign) CGFloat bottomMargin;
@property (assign) CGFloat textLineSpacing;
@property (assign) CGFloat charactersSpacing;
@property (assign) CGFloat chapterTitleFontSize;
@property (assign) CGFloat chapterContentFontSize;

//@property (strong, nonatomic) UIView *contentView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;

@property (strong, nonatomic) VCBook *currentBook;

@end
