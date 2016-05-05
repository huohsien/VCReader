//
//  VCLoginViewController.m
//  VCReader
//
//  Created by victor on 4/22/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCLoginViewController.h"
#import "VCSetPhoneNumberViewController.h"

NSString * const kTencentOAuthAppID = @"1105244329";

@interface VCLoginViewController ()

@end

@implementation VCLoginViewController

@synthesize tencentOAuth = _tencentOAuth;

- (void)viewDidLoad {
    [super viewDidLoad];

    //set status bar style
    [self setNeedsStatusBarAppearanceUpdate];
    
    //set navigation bar style
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.barTintColor = [UIColor redColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    self.navigationBar.tintColor = [UIColor whiteColor];

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
            
            [[VCCoreDataCenter sharedInstance] newUserWithAccoutnName:dict[@"account_name"] accountPassword:self.passwordTextView.text userID:dict[@"user_id"] phoneNumber:dict[@"phone_number"] nickName:dict[@"nick_name"] token:dict[@"token"] timestamp:dict[@"timestamp"] signupType:dict[@"signup_type"]];
                        
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

#pragma mark - QQ


- (IBAction)qqButtonPressed:(id)sender {
    
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTencentOAuthAppID andDelegate:self];
    
    NSArray *permissions =  [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
    [self.tencentOAuth authorize:permissions inSafari:NO];
    [self.qqLoginButton setEnabled:NO];
}

#pragma mark - TencentLoginDelegate

- (void)tencentDidLogin
{
    NSLog(@"登录完成");

    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
//        NSLog(@"token = %@", _tencentOAuth.openId);
        
        [self.activityIndicator startAnimating];
        [_tencentOAuth getUserInfo];
        
    }
    else
    {
        NSLog(@"登录不成功 没有获取accesstoken");
        [self.qqLoginButton setEnabled:YES];

    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.qqLoginButton setEnabled:YES];

}

- (void)tencentDidNotNetWork
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.qqLoginButton setEnabled:YES];
    abort();

}

#pragma mark - TencentSessionDelegate

- (void)tencentDidLogout
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    abort();
}

- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    abort();

}

- (void)getUserInfoResponse:(APIResponse*) response {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (URLREQUEST_SUCCEED == response.retCode && kOpenSDKErrorSuccess == response.detailRetCode) {
       
        NSLog(@"qq login response = %@", response.jsonResponse);
        
        [VCTool saveImage:[VCTool getImageFromURL:response.jsonResponse[@"figureurl_qq_2"]]];
        
        [VCTool storeObject:[response.jsonResponse objectForKey:@"nickname"] withKey:@"nickName"];
        
        NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970]  * 1000.0;
        [[VCReaderAPIClient sharedClient] signupWithName:@"" password:@"" nickName:[response.jsonResponse objectForKey:@"nickname"] phoneNumber:@"" token:_tencentOAuth.openId timestamp:timestamp signupType:@"QQ" success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary *dict = responseObject;
            NSLog(@"%s: response = %@", __PRETTY_FUNCTION__, dict);
            
            if (dict[@"error"]) {
                
                [VCTool showAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
                
            } else  {
                // success
                
                if (dict[@"user_id"]) {
                
                    if(((NSString *)dict[@"phone_number"]).length > 0) {
                        
                        [[VCCoreDataCenter sharedInstance] newUserWithAccoutnName:@"" accountPassword:@"" userID:dict[@"user_id"] phoneNumber:dict[@"phone_number"] nickName:dict[@"nick_name"] token:dict[@"token"] timestamp:dict[@"timestamp"] signupType:dict[@"signup_type"]];
                        
                        [VCTool storeObject:dict[@"user_id"] withKey:@"user id"];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    } else {
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        VCSetPhoneNumberViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SetPhoneNumberViewController"];
                        vc.type = @"QQ";
                        
                        [self.navigationController presentViewController:vc animated:YES completion:nil];
                        
                        [self.activityIndicator stopAnimating];
                        return;
                    }
                    
                } else {
                    
                    [VCTool showAlertViewWithTitle:@"web error" andMessage:@"User ID Missing"];
                }
                
            }
            [self.activityIndicator stopAnimating];
            
            
            // go to main navigation chain
            //
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
            [VCTool appDelegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [VCTool appDelegate].window.rootViewController = nc;
            [[VCTool appDelegate].window makeKeyAndVisible];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
            [self.qqLoginButton setEnabled:YES];

        }];

    
    } else {
        
        NSString *errMsg = [NSString stringWithFormat:@"errorMsg:%@\n%@", response.errorMsg, [response.jsonResponse objectForKey:@"msg"]];
        [VCTool showAlertViewWithTitle:@"操作失败" andMessage:errMsg];
    }

}

@end
