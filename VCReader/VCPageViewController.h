//
//  VCPageViewController.h
//  VCReader
//
//  Created by victor on 1/24/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCPageViewController : UIViewController

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) NSString *contentString;
@property (assign) CGFloat margin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
