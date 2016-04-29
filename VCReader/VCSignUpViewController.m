//
//  VCSignUpViewController.m
//  VCReader
//
//  Created by victor on 4/25/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCSignUpViewController.h"
#import "VCReaderAPIClient.h"

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

    
    NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970];
    [[VCReaderAPIClient sharedClient] signUPWithName:self.accountNameTextField.text password:self.passwordTextField.text nickName:self.nickNameTextField.text email:self.emailTextField.text token:nil timestamp:timestamp signupType:@"direct" success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = responseObject;
        
        if (dict[@"error"]) {
            
            [VCHelperClass showErrorAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
            
        } else  {
            // success

            if (dict[@"user_id"]) {
                [[VCCoreDataCenter sharedInstance] newUserWithAccoutnName:self.accountNameTextField.text accountPassword:self.passwordTextField.text userID:dict[@"user_id"] email:self.emailTextField.text headshotFilePath:@"" nickName:self.nickNameTextField.text token:dict[@"token"] timestamp:[NSString stringWithFormat:@"%ld",(long)(timestamp * 1000.0)] signupType:@"direct"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [VCHelperClass showErrorAlertViewWithTitle:@"web error" andMessage:@"Did Not Return User ID"];
            }

        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [VCHelperClass showErrorAlertViewWithTitle:@"web error" andMessage:error.debugDescription];

    }];
}
- (IBAction)viewTapped:(id)sender {
    
    // dismiss keyboard
    
    [self.view endEditing:YES];
}


@end
