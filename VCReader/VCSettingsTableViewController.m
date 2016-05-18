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

@interface VCSettingsTableViewController ()

@end

@implementation VCSettingsTableViewController {
    
    UIImage *_headshot;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //set navigation bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//-(BOOL)prefersStatusBarHidden {
//    return YES;
//}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {

    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
//    header.textLabel.textColor = [UIColor redColor];
    header.textLabel.font = [UIFont boldSystemFontOfSize:21];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
}


- (IBAction)touched:(id)sender {
    
    [self.searchTextField resignFirstResponder];
}

- (IBAction)logoutButtonPressed:(id)sender {

    [VCTool storeObject:nil withKey:@"token"];
    [VCTool storeObject:nil withKey:@"name of the last read book"];

    [VCTool deleteFilename:@"headshot.png"];
    [[VCCoreDataCenter sharedInstance] clearCurrentUser];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    [VCTool appDelegate].window.rootViewController = nc;
}

- (IBAction)dumpButtonPressed:(id)sender {
    
    [[VCCoreDataCenter sharedInstance] batteryLogDump];
}
- (IBAction)clearButtonPressed:(id)sender {
    [[VCCoreDataCenter sharedInstance] clearAllofBatteryLog];
}

@end
