//
//  VCLoginViewController.m
//  VCReader
//
//  Created by victor on 4/22/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCLoginViewController.h"
#import "VCSetPhoneNumberViewController.h"

@interface VCLoginViewController ()

@end

@implementation VCLoginViewController

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



-(UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (IBAction)loginButtonPressed:(id)sender {
    
    [self.loginButton setEnabled:NO];
    
    [[VCReaderAPIClient sharedClient] userLoginWithAccountName:self.accountNameTextView.text password:self.passwordTextView.text success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = responseObject;
        
        if (dict[@"error"]) {
            
            [VCTool showAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
            [self.loginButton setEnabled:YES];
        
        } else if (dict[@"user_id"]) {
            
            // clean up image file which might be left from the previous session
            [VCTool deleteFilename:@"headshot"];
            
            [VCTool storeObject:dict[@"user_id"] withKey:@"user id"];
            
            [[VCCoreDataCenter sharedInstance] newUserWithAccoutnName:dict[@"account_name"] accountPassword:self.passwordTextView.text userID:dict[@"user_id"] nickName:dict[@"nick_name"] token:dict[@"token"] timestamp:dict[@"timestamp"] signupType:dict[@"signup_type"]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
            [VCTool appDelegate].window.rootViewController = nc;
            
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
        [self.loginButton setEnabled:YES];

    }];


}

- (IBAction)viewTapped:(id)sender {
    
    // dismiss keyboard

    [self.view endEditing:YES];
}
- (IBAction)signupNewAccountButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
