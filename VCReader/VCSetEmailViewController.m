//
//  VCSetEmailViewController.m
//  VCReader
//
//  Created by victor on 5/4/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCSetEmailViewController.h"
#import "VCEmailVerificationViewController.h"
#import "VCSignUpViewController.h"

@interface VCSetEmailViewController ()

@end

@implementation VCSetEmailViewController

@synthesize token = _token;
@synthesize type = _type;

- (void)viewDidLoad {
    [super viewDidLoad];

    
    //set status bar style
    [self setNeedsStatusBarAppearanceUpdate];
    
    //set navigation bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.title = _type;

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowEmailVerificationViewController"]) {
        
        VCEmailVerificationViewController  *viewController = segue.destinationViewController;
        viewController.token = _token;
    }
}

- (IBAction)submitEmailButtonPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [VCTool showAlertViewWithMessage:@"请填写你的电子邮箱" handler:nil];
        return;
    }

    [VCTool showActivityView];
   
    if ([_type isEqualToString:@"邮箱认证"]) {
        
        NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)([[NSDate new] timeIntervalSince1970] * 1000.0)];
        
        [[VCReaderAPIClient sharedClient] callAPI:@"user_send_email_verify_code" params:@{@"token" : _token, @"email" : self.emailTextField.text, @"timestamp" : timestamp} success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary *dict = responseObject;
            
            [VCTool hideActivityView];
            
            if (!dict[@"error"]) {
                
                [self performSegueWithIdentifier:@"ShowEmailVerificationViewController" sender:self];
                
            } else {
                
                if ([dict[@"error"][@"code"] isEqualToString:@"108"]) {
                    
                    [VCTool toastMessage:@"邮箱格式错误，请重新输入"];
                    
                } else if ([dict[@"error"][@"code"] isEqualToString:@"112"]) {
                    
                    [VCTool toastMessage:@"输入邮箱已被使用，请输入其它邮箱"];
                    
                } else {
                    
                    [VCTool showAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
                }
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [VCTool hideActivityView];
            
            [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
            
        } completion:nil];
    } else if ([_type isEqualToString:@"忘记账户密码"]) {
        
        
        [[VCReaderAPIClient sharedClient] callAPI:@"user_send_email_password" params:@{@"email" : self.emailTextField.text} success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSDictionary *dict = responseObject;
            
            [VCTool hideActivityView];
            
            if (!dict[@"error"]) {
                
                [self backToLoginViewController];
                
            } else {
                
                if ([dict[@"error"][@"code"] isEqualToString:@"108"]) {
                    
                    [VCTool toastMessage:@"邮箱格式错误，请重新输入"];
                    
                } else if ([dict[@"error"][@"code"] isEqualToString:@"111"]) {
                    
                    [VCTool toastMessage:@"找不到此邮箱，请输入注册时填写的邮箱"];
                    
                } else {
                    
                    [VCTool showAlertViewWithTitle:@"web error" andMessage:dict[@"error"][@"message"]];
                }
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [VCTool hideActivityView];
            
            [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
            
        } completion:nil];
        
    }
    
}

- (void)backToLoginViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    [VCTool appDelegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [VCTool appDelegate].window.rootViewController = nc;
    VCSignUpViewController  *vc = [nc.viewControllers firstObject];
    [vc performSegueWithIdentifier:@"ToLoginViewController" sender:self];
    
    [[VCTool appDelegate].window makeKeyAndVisible];
    
}

- (IBAction)stopButtonPressed:(id)sender {

    [self backToLoginViewController];
    
}

- (IBAction)viewTapped:(id)sender {

    // dismiss keyboard
    
    [self.view endEditing:YES];
}

@end
