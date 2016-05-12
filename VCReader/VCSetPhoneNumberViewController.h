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
@property (weak, nonatomic) IBOutlet UITextField *cellPhoneNumberTextField;
@property (strong, nonatomic) NSString *type;
@end
