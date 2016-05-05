//
//  VCSetPhoneNumberViewController.h
//  VCReader
//
//  Created by victor on 5/4/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCSetPhoneNumberViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *setCellPhoneNumberView;
@property (weak, nonatomic) IBOutlet UIView *verifyCodeView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (strong, nonatomic) NSString *type;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@end
