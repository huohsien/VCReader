//
//  VCSignUpViewController.h
//  VCReader
//
//  Created by victor on 4/25/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCCoreDataCenter.h"

@interface VCSignUpViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *accountNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end
