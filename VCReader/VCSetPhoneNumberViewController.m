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

    
    //set status bar style
    [self setNeedsStatusBarAppearanceUpdate];
    
    //set navigation bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

}



- (IBAction)submitPhoneNumberButtonPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    int length = (int)self.phoneNumberTextField.text.length;
    
    if (length != 10 && length != 11) {

        self.phoneNumberTextField.text = @"";
        [VCTool showAlertViewWithTitle:@"错误" andMessage:@"手机号不正确"];

    } else {
        
        [self.navigationController performSegueWithIdentifier:@"ShowPhoneVerificationViewController" sender:self];
    }

}

- (IBAction)viewTapped:(id)sender {

    // dismiss keyboard
    
    [self.view endEditing:YES];
}

@end
