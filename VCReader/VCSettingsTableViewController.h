//
//  VCSettingsTableViewController.h
//  VCReader
//
//  Created by victor on 4/7/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MessageUI;

@interface VCSettingsTableViewController : UITableViewController<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headshotImageView;

@end
