//
//  VCLoginViewController.h
//  VCReader
//
//  Created by victor on 4/22/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "VCUserMO+CoreDataProperties.h"
#import "VCReadingStatusMO+CoreDataProperties.h"

extern NSString * const kTencentOAuthAppID;

@interface VCLoginViewController : UIViewController <TencentSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *accountNameTextView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextView;
@property (strong, nonatomic) TencentOAuth *tencentOAuth;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
