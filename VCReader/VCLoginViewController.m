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
            
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"token"] forKey:@"token"];  //TODO: need to think about the redundancy of token being stored in both NSUserDefaults and Core Data
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"user_id"] forKey:@"user id"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
            [VCHelperClass appDelegate].window.rootViewController = nc;
            
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        [VCHelperClass showErrorAlertViewWithTitle:@"web error" andMessage:error.debugDescription];

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
        [[NSUserDefaults standardUserDefaults] setObject:_tencentOAuth.openId forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        

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
    
    if (URLREQUEST_SUCCEED == response.retCode && kOpenSDKErrorSuccess == response.detailRetCode) {
       
        NSLog(@"qq login response = %@", response.jsonResponse);
        
        [self saveImage:[self getImageFromURL:response.jsonResponse[@"figureurl_qq_2"]] withFileName:@"headshot_100" inDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        
        [[NSUserDefaults standardUserDefaults] setObject:[response.jsonResponse objectForKey:@"nickname"] forKey:@"nickName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970];
        [[VCReaderAPIClient sharedClient] signUPWithName:@"" password:@"" nickName:[response.jsonResponse objectForKey:@"nickname"] email:@"" token:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] timestamp:timestamp signupType:@"QQ" success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary *dict = responseObject;
            NSLog(@"response = %@", dict);
            
            if (dict[@"error"]) {
                
                [VCHelperClass showErrorAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
                
            } else  {
                // success
                
                if (dict[@"user_id"]) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:dict[@"user_id"] forKey:@"user id"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[VCCoreDataCenter sharedInstance] newUserWithAccoutnName:@" " accountPassword:@" " userID:dict[@"user_id"] email:@" " headshotFilePath:[[NSUserDefaults standardUserDefaults] objectForKey:@"headshot path"] nickName:[[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"] token:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] timestamp:[NSString stringWithFormat:@"%ld",(long)(timestamp * 1000.0)] signupType:@"QQ"];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else if (!dict[@"success"]) {
                    
                    [VCHelperClass showErrorAlertViewWithTitle:@"web error" andMessage:@"Did Not Return User ID"];
                }
                
            }
            [self.activityIndicator stopAnimating];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [VCHelperClass showErrorAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
            
        }];

        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
        [VCHelperClass appDelegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [VCHelperClass appDelegate].window.rootViewController = nc;
        [[VCHelperClass appDelegate].window makeKeyAndVisible];
    
    } else {
        
        NSString *errMsg = [NSString stringWithFormat:@"errorMsg:%@\n%@", response.errorMsg, [response.jsonResponse objectForKey:@"msg"]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"操作失败" message:errMsg delegate:self cancelButtonTitle:@"我知道啦" otherButtonTitles: nil];
        [alert show];
    }

}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName inDirectory:(NSString *)directoryPath {
    
    if (image) {
        
        NSString *path = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]];
        [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"headshot path"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [UIImagePNGRepresentation(image) writeToFile:path options:NSAtomicWrite error:nil];
    }
}

@end
