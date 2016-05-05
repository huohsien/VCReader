//
//  VCSetPhoneNumberViewController.m
//  VCReader
//
//  Created by victor on 5/4/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCSetPhoneNumberViewController.h"

@interface VCSetPhoneNumberViewController ()

@end

@implementation VCSetPhoneNumberViewController

@synthesize type = _type;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.barTintColor = [UIColor redColor];
    self.navigationBar.translucent = NO;
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    self.navigationBar.tintColor = [UIColor whiteColor];

    [self.verifyCodeView setHidden:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitPhoneNumberButtonPressed:(id)sender {
    
    int length = (int)self.phoneNumberTextField.text.length;
    if ((length != (10)) || (length != (11))) {

        self.phoneNumberTextField.text = @"";
        [VCTool showAlertViewWithTitle:@"错误" andMessage:@"手机号不正确"];
        [self.view endEditing:YES];

        return;
    }
    // call web api to send sms
    //
    
    [self.setCellPhoneNumberView setHidden:YES];
    [self.verifyCodeView setHidden:NO];
    [self.view endEditing:YES];

}

- (IBAction)sendVerificationCodeButtonPressed:(id)sender {
    [self.setCellPhoneNumberView setHidden:NO];
    [self.verifyCodeView setHidden:YES];
    [self.view endEditing:YES];
}

- (IBAction)viewTapped:(id)sender {

    // dismiss keyboard
    
    [self.view endEditing:YES];
}

@end
