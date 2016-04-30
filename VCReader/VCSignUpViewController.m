//
//  VCSignUpViewController.m
//  VCReader
//
//  Created by victor on 4/25/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCSignUpViewController.h"

@interface VCSignUpViewController ()

@end

@implementation VCSignUpViewController

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

- (IBAction)signUpButtonPressed:(id)sender {
   
    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970] * 1000.0;
    [[VCReaderAPIClient sharedClient] signupWithName:self.accountNameTextField.text password:self.passwordTextField.text nickName:self.nickNameTextField.text email:self.emailTextField.text token:nil timestamp:timestamp signupType:@"direct" success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = responseObject;
        
        if (dict[@"error"]) {
            
            [VCTool showErrorAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
            
        } else  {
            // success

            if (dict[@"user_id"]) {
                    [[VCCoreDataCenter sharedInstance] newUserWithAccoutnName:dict[@"account_name"] accountPassword:dict[@"account_password"] userID:dict[@"user_id"] email:dict[@"email"] nickName:dict[@"nick_name"] token:dict[@"token"] timestamp:dict[@"timestamp"] signupType:dict[@"signup_type"]];
                

                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [VCTool showErrorAlertViewWithTitle:@"web error" andMessage:@"Did Not Return User ID"];
            }

        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [VCTool showErrorAlertViewWithTitle:@"web error" andMessage:error.debugDescription];

    }];
}
- (IBAction)viewTapped:(id)sender {
    
    // dismiss keyboard
    
    [self.view endEditing:YES];
}


@end
