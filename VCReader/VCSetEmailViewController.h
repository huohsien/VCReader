//
//  VCSetEmailViewController.h
//  VCReader
//
//  Created by victor on 5/4/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCSetEmailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) NSString *token;

@end
