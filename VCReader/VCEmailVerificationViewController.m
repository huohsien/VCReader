//
//  VCPhoneVerificationViewController.m
//  VCReader
//
//  Created by victor on 5/10/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCEmailVerificationViewController.h"

@interface VCEmailVerificationViewController ()

@end

@implementation VCEmailVerificationViewController

@synthesize token = _token;

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
- (IBAction)verifyButtonPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([self.verifyCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 6) {
        [VCTool showAlertViewWithMessage:@"验证码应为6个数字" handler:nil];
        return;
    }
    
    [VCTool showActivityView];
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)([[NSDate new] timeIntervalSince1970] * 1000.0)];
    
    [[VCReaderAPIClient sharedClient] callAPI:@"user_check_email_verify_code" params:@{@"code" : self.verifyCodeTextField.text, @"token" : _token, @"timestamp" : timestamp} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = responseObject;
       
        [VCTool hideActivityView];
        
        if (!dict[@"error"]) {
            
            [[VCCoreDataCenter sharedInstance] setUserVerified];
            [VCTool storeObject:_token withKey:@"token"];
            
            // go to main navigation chain
            //
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
            [VCTool appDelegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [VCTool appDelegate].window.rootViewController = nc;
            [[VCTool appDelegate].window makeKeyAndVisible];
            
            
        } else {
            [VCTool toastMessage:@"验证失败，重新发送"];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [VCTool hideActivityView];
        
        [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
    } completion:nil];
}



@end
