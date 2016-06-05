//
//  VCSettingsTableViewController.m
//  VCReader
//
//  Created by victor on 4/7/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCSettingsTableViewController.h"
#import "VCLoginViewController.h"
#import "VCUserMO.h"
#import "VCCommentComposerViewController.h"

@interface VCSettingsTableViewController ()

@end

@implementation VCSettingsTableViewController {
    
    UIImage *_headshot;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"设置";
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    VCUserMO *user = [VCCoreDataCenter sharedInstance].user;
    
    if (user) {
        [self.nickNameLabel setText:user.nickName];
    }
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"headshot.png"]];

    _headshot = [UIImage imageWithContentsOfFile:path];
    if (!_headshot) {
        _headshot = [UIImage imageNamed:@"headshot_placeholder"];
    }
    [self.headshotImageView setImage:_headshot];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([cell respondsToSelector:@selector(tintColor)]) {
        
        CGFloat cornerRadius = 5.f;
        cell.backgroundColor = UIColor.clearColor;
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGRect bounds = CGRectInset(cell.bounds, 5, 0);
        BOOL addLine = NO;
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        } else if (indexPath.row == 0) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            addLine = YES;
        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        } else {
            CGPathAddRect(pathRef, nil, bounds);
            addLine = YES;
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
        
        if (addLine == YES) {
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+5, bounds.size.height-lineHeight, bounds.size.width-5, lineHeight);
            lineLayer.backgroundColor = tableView.separatorColor.CGColor;
            [layer addSublayer:lineLayer];
        }
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = UIColor.clearColor;
        cell.backgroundView = testView;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        
//        [self composeEmailWithDebugAttachment];
        
        VCCommentComposerViewController *vc = [[VCCommentComposerViewController alloc] initWithNibName:@"VCCommentComposerViewController" bundle:nil];
        [self.navigationController presentViewController:vc animated:YES completion:nil];

    }
}


- (IBAction)logoutButtonPressed:(id)sender {

    [VCTool storeObject:nil withKey:@"token"];
    [VCTool storeObject:nil withKey:@"name of the last read book"];

    [VCTool deleteFilename:@"headshot.png"];
    [[VCCoreDataCenter sharedInstance] clearAllBooksForCurrentUser];
    [[VCCoreDataCenter sharedInstance] clearCurrentUser];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    [VCTool appDelegate].window.rootViewController = nc;
}



- (void)composeEmailWithDebugAttachment {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        NSMutableData *errorLogData = [NSMutableData data];
        
        for (NSData *errorLogFileData in [VCTool errorLogData]) {
        
            [errorLogData appendData:errorLogFileData];
        }
        
        [mailViewController addAttachmentData:errorLogData mimeType:@"text/plain" fileName:@"errorLog.txt"];
        [mailViewController setSubject:@"小说神器错误回报"];
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"vhhc.studio@gmail.com"]];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
        
    }
    
    else {
        NSString *message = NSLocalizedString(@"Sorry, your issue can't be reported right now. This is most likely because no mail accounts are set up on your mobile device.", @"");
        [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}



//- (IBAction)dumpButtonPressed:(id)sender {
//
//    [[VCCoreDataCenter sharedInstance] batteryLogDump];
//}
//
//- (IBAction)clearButtonPressed:(id)sender {
//    [[VCCoreDataCenter sharedInstance] clearAllofBatteryLog];
//}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//
////    header.textLabel.textColor = [UIColor redColor];
//    header.textLabel.font = [UIFont boldSystemFontOfSize:21];
//    CGRect headerFrame = header.frame;
//    header.textLabel.frame = headerFrame;
//    header.textLabel.textAlignment = NSTextAlignmentLeft;
//}

//- (IBAction)touched:(id)sender {
//
//    [self.searchTextField resignFirstResponder];
//}

@end
