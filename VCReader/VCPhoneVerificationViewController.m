//
//  VCPhoneVerificationViewController.m
//  VCReader
//
//  Created by victor on 5/10/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCPhoneVerificationViewController.h"

@interface VCPhoneVerificationViewController ()

@end

@implementation VCPhoneVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //set status bar style
    [self setNeedsStatusBarAppearanceUpdate];
    
    //set navigation bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}



@end
