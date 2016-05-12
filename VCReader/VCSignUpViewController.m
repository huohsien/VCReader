//
//  VCSignUpViewController.m
//  VCReader
//
//  Created by victor on 4/25/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCSignUpViewController.h"
#import "VCPhoneVerificationViewController.h"

NSString * const kTencentOAuthAppID = @"1105244329";

@interface VCSignUpViewController ()

@end

@implementation UIView (FindTheFirstResponder)
- (UIView *)findTheFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findTheFirstResponder];
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
}
@end

@implementation VCSignUpViewController

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
    
    [_accountNameTextField addTarget:self action:@selector(accountNameTextFieldEditingDidEnd) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_passwordTextField addTarget:self action:@selector(passwordTextFieldEditingDidEnd) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_nickNameTextField addTarget:self action:@selector(nickNameTextFieldEditingDidEnd) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_cellPhoneNumberTextField addTarget:self action:@selector(cellPhoneNumberTextFieldDidEnd) forControlEvents:UIControlEventEditingDidEndOnExit];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.loginButton setHidden:YES];
    
}

-(void) accountNameTextFieldEditingDidEnd {
    
    if ([self.accountNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 2) {
        
        [VCTool showAlertViewWithMessage:@"帐户名不可少於2个字！" handler:^(UIAlertAction *action) {
            
            [_accountNameTextField becomeFirstResponder];
            
        }];
        
    } else {
        
        [_passwordTextField becomeFirstResponder];

    }
}

-(void) passwordTextFieldEditingDidEnd {
    
    if ([self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 6 ||
        [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 12) {
        
        [VCTool showAlertViewWithMessage:@"密碼是6到12位字符！" handler:^(UIAlertAction *action) {
            
            [_passwordTextField becomeFirstResponder];
            
        }];

        
    } else {
        
        [_nickNameTextField becomeFirstResponder];
        
    }
}

-(void) nickNameTextFieldEditingDidEnd {
    
    
    if ([self.nickNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 2) {
        
        [VCTool showAlertViewWithMessage:@"昵称不可少於2个字！" handler:^(UIAlertAction *action) {
            
            [_nickNameTextField becomeFirstResponder];
            
        }];

        
    } else {
        
        [_cellPhoneNumberTextField becomeFirstResponder];
        
    }
}

-(void) cellPhoneNumberTextFieldDidEnd {
    
    
    if ([self.cellPhoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 10 ||
        [self.cellPhoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 11) {
        
        [VCTool showAlertViewWithMessage:@"请输入手机号：中國為11碼，台灣為10碼" handler:^(UIAlertAction *action) {
            
            [_cellPhoneNumberTextField becomeFirstResponder];
            
        }];

        
    } else {
        
        [_cellPhoneNumberTextField resignFirstResponder];
    }
}

- (IBAction)signUpButtonPressed:(id)sender {
   
    NSLog(@"%s", __PRETTY_FUNCTION__);

    if(![self checkFormValidity])
        return;
    
    NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970] * 1000.0;
    [[VCReaderAPIClient sharedClient] signupDirectlyWithName:self.accountNameTextField.text password:self.passwordTextField.text nickName:self.nickNameTextField.text timestamp:timestamp success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = responseObject;
        
        if (dict[@"error"]) {
            
            [VCTool showAlertViewWithTitle:@"错误" andMessage:dict[@"error"][@"message"]];
            
        } else  {
            // success

            if (dict[@"user_id"]) {
                    [[VCCoreDataCenter sharedInstance] newUserWithAccoutnName:dict[@"account_name"] accountPassword:dict[@"account_password"] userID:dict[@"user_id"] nickName:dict[@"nick_name"] token:dict[@"token"] timestamp:dict[@"timestamp"] signupType:@"direct"];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"PhoneVerificationNavigationController"];
                [VCTool appDelegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                [VCTool appDelegate].window.rootViewController = nc;
                [[VCTool appDelegate].window makeKeyAndVisible];
                
            } else {
                [VCTool showAlertViewWithTitle:@"web error" andMessage:@"Did Not Return User ID"];
            }

        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];

    }];
}

#define conditionAndErrorMessage(condition, message) \
if (condition) { \
    [VCTool showAlertViewWithMessage:(NSString *)CFSTR(message) handler:nil];\
    return NO;\
}

-(BOOL) checkFormValidity {
    
    conditionAndErrorMessage([self.accountNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 2, "帐户名不可少於2个字！")

    conditionAndErrorMessage([self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 6 ||
                             [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 12, "密碼是6到12位字符！")

    conditionAndErrorMessage([self.nickNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 2,"昵称不可少於2个字！")
    
    NSLog(@"%lu", [self.cellPhoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length);
    conditionAndErrorMessage([self.cellPhoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 10 &&
                             [self.cellPhoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 11,"请输入手机号：中國為11碼，台灣為10碼")
    
    return YES;
}

- (IBAction)viewTapped:(id)sender {
    
    // dismiss keyboard
    UIView *firstResponder = [self.view findTheFirstResponder];
    if (firstResponder) {
        
        [firstResponder resignFirstResponder];
        [self checkFormValidity];
        [self.loginButton setHidden:NO];
    }

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
        
        NSTimeInterval timestamp = [[NSDate new] timeIntervalSince1970]  * 1000.0;
        [[VCReaderAPIClient sharedClient] signupOrLoginToQQWithToken:_tencentOAuth.openId
                                                            nickName:[response.jsonResponse objectForKey:@"nickname"]
                                                           timestamp:timestamp
                                                             success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary *dict = responseObject;
            NSLog(@"%s: response = %@", __PRETTY_FUNCTION__, dict);
        
            [[VCCoreDataCenter sharedInstance] newUserWithAccoutnName:@"" accountPassword:@"" userID:dict[@"user_id"] nickName:dict[@"nick_name"] token:dict[@"token"] timestamp:dict[@"timestamp"] signupType:@"QQ"];
                                                                 
                                                                 
            if ([(NSString *)dict[@"verified"] isEqualToString:@"1"]) {
                
                [[VCCoreDataCenter sharedInstance] setUserVerified];
                [VCTool storeObject:dict[@"user_id"] withKey:@"user id"];
                
                // go to main navigation chain
                //
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
                [VCTool appDelegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                [VCTool appDelegate].window.rootViewController = nc;
                [[VCTool appDelegate].window makeKeyAndVisible];
                
            } else {
                
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"PhoneVerificationNavigationController"];
                [VCTool appDelegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                [VCTool appDelegate].window.rootViewController = nc;
                [[VCTool appDelegate].window makeKeyAndVisible];
                
            }
            
            
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
