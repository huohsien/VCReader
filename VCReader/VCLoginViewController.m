//
//  VCLoginViewController.m
//  VCReader
//
//  Created by victor on 4/22/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCLoginViewController.h"
#import "VCReaderAPIClient.h"

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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    

    NSString *tokenString = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    
    if (tokenString) {
        
        [self performSegueWithIdentifier:@"toHomeViewController" sender:self];
    } 

}



-(UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (IBAction)loginButtonPressed:(id)sender {
    
    [[VCReaderAPIClient sharedClient] userLoginWithAccountName:self.accountNameTextView.text password:self.passwordTextView.text success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = responseObject;
        
        if (dict[@"error"]) {
            
            [VCHelperClass showErrorAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
        
        } else {
            
            [[NSUserDefaults standardUserDefaults] setObject:self.accountNameTextView.text forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setObject:self.accountNameTextView.text forKey:@"nickname"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSegueWithIdentifier:@"toHomeViewController" sender:self];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        [VCHelperClass showErrorAlertViewWithTitle:@"web error" andMessage:error.debugDescription];

    }];


}

- (IBAction)dismissKeyboard:(id)sender {
    
    [self.view endEditing:YES];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}

- (IBAction)qqButtonPressed:(id)sender {
    
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTencentOAuthAppID andDelegate:self];
    
    NSArray *permissions =  [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
    [self.tencentOAuth authorize:permissions inSafari:NO];
}

#pragma mark - TencentLoginDelegate

- (void)tencentDidLogin
{
    NSLog(@"登录完成");

    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
        NSLog(@"token = %@", _tencentOAuth.accessToken);
    }
    else
    {
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{

}

- (void)tencentDidNotNetWork
{

}

#pragma mark - TencentSessionDelegate

- (void)tencentDidLogout
{

}

- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message
{

}

@end
