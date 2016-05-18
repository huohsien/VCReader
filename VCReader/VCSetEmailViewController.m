//
//  VCSetEmailViewController.m
//  VCReader
//
//  Created by victor on 5/4/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCSetEmailViewController.h"
#import "VCEmailVerificationViewController.h"

@interface VCSetEmailViewController ()

@end

@implementation VCSetEmailViewController

@synthesize token = _token;

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
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)([[NSDate new] timeIntervalSince1970] * 1000.0)];
    
    [[VCReaderAPIClient sharedClient] callAPI:@"user_send_email_verify_code" params:@{@"token" : _token, @"email" : self.emailTextField.text, @"timestamp" : timestamp} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dict = responseObject;

        [VCTool hideActivityView];

        if (!dict[@"error"]) {

            [self performSegueWithIdentifier:@"ShowEmailVerificationViewController" sender:self];

        } else {
            
            [VCTool toastMessage:dict[@"error"][@"message"]];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        [VCTool hideActivityView];

        [VCTool showAlertViewWithTitle:@"web error" andMessage:error.debugDescription];
        
    }];

}

- (IBAction)viewTapped:(id)sender {

    // dismiss keyboard
    
    [self.view endEditing:YES];
}

@end
