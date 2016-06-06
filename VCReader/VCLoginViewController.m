//
//  VCLoginViewController.m
//  VCReader
//
//  Created by victor on 4/22/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCLoginViewController.h"
#import "VCSetEmailViewController.h"

@interface VCLoginViewController ()

@end

@implementation VCLoginViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];

}




- (IBAction)loginButtonPressed:(id)sender {
    
    [VCTool showActivityView];
    
    [[VCReaderAPIClient sharedClient] userLoginWithAccountName:self.accountNameTextView.text password:self.passwordTextView.text success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [VCTool hideActivityView];
        
        NSDictionary *dict = responseObject;
        
        if (dict[@"error"]) {
            
            if ([dict[@"error"][@"code"] isEqualToString:@"102"]) {
                [VCTool showAlertViewWithMessage:@"账户密码错误，请重新输入"];
            } else {
                
                [VCTool showAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
            }
            
        
        } else if (dict[@"token"]) {
            
            // clean up image file which might be left from the previous session
            [VCTool deleteFilename:@"headshot.png"];
            
            [VCTool storeObject:dict[@"token"] withKey:@"token"];
            
            [[VCCoreDataCenter sharedInstance] setUserWithToken:dict[@"token"] accountName:dict[@"account_name"] accountPassword:self.passwordTextView.text nickName:dict[@"nick_name"]  timestamp:dict[@"timestamp"] signupType:dict[@"signup_type"]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
            [VCTool appDelegate].window.rootViewController = nc;
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
        [VCTool hideActivityView];

    }];


}
- (IBAction)forgetPasswordButtonPressed:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"EmailVerificationNavigationController"];
    VCSetEmailViewController *vc = [nc.viewControllers firstObject];
    vc.type = @"忘记账户密码";
    
    [VCTool appDelegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [VCTool appDelegate].window.rootViewController = nc;
    [[VCTool appDelegate].window makeKeyAndVisible];
}

- (IBAction)viewTapped:(id)sender {
    
    // dismiss keyboard

    [self.view endEditing:YES];
}
- (IBAction)signupNewAccountButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
