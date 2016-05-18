//
//  VCEmailVerificationViewController.h
//  VCReader
//
//  Created by victor on 5/10/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCEmailVerificationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;

@property (strong, nonatomic) NSString *token;

@end
