//
//  VCBookStoreViewController.m
//  VCReader
//
//  Created by victor on 4/26/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCBookStoreViewController.h"

@interface VCBookStoreViewController ()

@end

@implementation VCBookStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"书库";
    
}

@end
