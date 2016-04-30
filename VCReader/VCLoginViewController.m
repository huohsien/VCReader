//
//  VCLoginViewController.m
//  VCReader
//
//  Created by victor on 4/22/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCLoginViewController.h"

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
}



-(UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (IBAction)loginButtonPressed:(id)sender {
    
    [[VCReaderAPIClient sharedClient] userLoginWithAccountName:self.accountNameTextView.text password:self.passwordTextView.text success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = responseObject;
        
        if (dict[@"error"]) {
            
            [VCTool showErrorAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
        
        } else if (dict[@"user_id"]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"user_id"] forKey:@"user id"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[VCCoreDataCenter sharedInstance] newUserWithAccoutnName:dict[@"account_name"] accountPassword:self.passwordTextView.text userID:dict[@"user_id"] email:dict[@"email"] nickName:dict[@"nick_name"] token:dict[@"token"] timestamp:dict[@"timestamp"] signupType:dict[@"signup_type"]];
                        
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
            [VCTool appDelegate].window.rootViewController = nc;
            
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        [VCTool showErrorAlertViewWithTitle:@"web error" andMessage:error.debugDescription];

    }];


}

- (IBAction)viewTapped:(id)sender {
    
    // dismiss keyboard

    [self.view endEditing:YES];
}

//-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
//}

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
//        NSLog(@"token = %@", _tencentOAuth.openId);
        
        [self.activityIndicator startAnimating];
        [_tencentOAuth getUserInfo];
        
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

- (void)getUserInfoResponse:(APIResponse*) response {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (URLREQUEST_SUCCEED == response.retCode && kOpenSDKErrorSuccess == response.detailRetCode) {
       
        NSLog(@"qq login response = %@", response.jsonResponse);
        
        [self saveImage:[self getImageFromURL:response.jsonResponse[@"figureurl_qq_2"]]];
        
        [[NSUserDefaults standardUserDefaults] setObject:[response.jsonResponse objectForKey:@"nickname"] forKey:@"nickName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970]  * 1000.0;
        [[VCReaderAPIClient sharedClient] signupWithName:@"" password:@"" nickName:[response.jsonResponse objectForKey:@"nickname"] email:@"" token:_tencentOAuth.openId timestamp:timestamp signupType:@"QQ" success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary *dict = responseObject;
            NSLog(@"%s: response = %@", __PRETTY_FUNCTION__, dict);
            
            if (dict[@"error"]) {
                
                [VCTool showErrorAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
                
            } else  {
                // success
                
                if (dict[@"user_id"]) {
                    
                    [[VCCoreDataCenter sharedInstance] newUserWithAccoutnName:@"" accountPassword:@"" userID:dict[@"user_id"] email:@"" nickName:dict[@"nick_name"] token:dict[@"token"] timestamp:dict[@"timestamp"] signupType:dict[@"signup_type"]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:dict[@"user_id"] forKey:@"user id"];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else {
                    
                    [VCTool showErrorAlertViewWithTitle:@"web error" andMessage:@"User ID Missing"];
                }
                
            }
            [self.activityIndicator stopAnimating];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [VCTool showErrorAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
            
        }];

        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
        [VCTool appDelegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [VCTool appDelegate].window.rootViewController = nc;
        [[VCTool appDelegate].window makeKeyAndVisible];
    
    } else {
        
        NSString *errMsg = [NSString stringWithFormat:@"errorMsg:%@\n%@", response.errorMsg, [response.jsonResponse objectForKey:@"msg"]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"操作失败" message:errMsg delegate:self cancelButtonTitle:@"我知道啦" otherButtonTitles: nil];
        [alert show];
    }

}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
     UIImage * result = [UIImage imageWithData:data];
    
    return result;
}

-(void) saveImage:(UIImage *)image {
    
    if (image) {
        
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"headshot.png"]];
        
        [UIImagePNGRepresentation(image) writeToFile:path options:NSAtomicWrite error:nil];
    }
}

@end
