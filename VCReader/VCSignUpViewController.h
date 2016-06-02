//
//  VCSignUpViewController.h
//  VCReader
//
//  Created by victor on 4/25/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface VCSignUpViewController : UIViewController <TencentSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *accountNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;

@property (strong, nonatomic) TencentOAuth *tencentOAuth;
@property (weak, nonatomic) IBOutlet UIButton *qqLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
