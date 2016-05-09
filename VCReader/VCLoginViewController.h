//
//  VCLoginViewController.h
//  VCReader
//
//  Created by victor on 4/22/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCUserMO+CoreDataProperties.h"
#import "VCReadingStatusMO+CoreDataProperties.h"

extern NSString * const kTencentOAuthAppID;

@interface VCLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *accountNameTextView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
