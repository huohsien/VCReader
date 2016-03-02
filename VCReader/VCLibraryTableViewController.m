//
//  VCLibraryTableViewController.m
//  VCReader
//
//  Created by victor on 2/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCLibraryTableViewController.h"
#import "VCPageViewController.h"

@interface VCLibraryTableViewController ()

@end

@implementation VCLibraryTableViewController {
    
    NSArray *_bookInfoArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setNeedsStatusBarAppearanceUpdate];
    _bookInfoArray = [NSArray arrayWithObjects:@{@"bookName":@"超级学神",@"coverImageFileName":@"book1_cover"}, nil];

    NSString *nameOfLastReadBook = [[NSUserDefaults standardUserDefaults] objectForKey:@"the last read book"];
    
    if (nameOfLastReadBook) {
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VCPageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VCPageViewController"];
        VCBook *book = [[VCBook alloc] initWithBookName:nameOfLastReadBook];
        vc.currentBook = book;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.tabBarController.tabBar.hidden = NO;

}
-(UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBookContent"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        VCBook *book = [[VCBook alloc] initWithBookName:[(NSDictionary *)[_bookInfoArray objectAtIndex:indexPath.row] valueForKey:@"bookName"]];
        VCPageViewController *viewController = segue.destinationViewController;
        viewController.currentBook = book;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _bookInfoArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VCLibraryTableViewCell *cell = (VCLibraryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell.bookNameLabel setText:[(NSDictionary *)[_bookInfoArray objectAtIndex:indexPath.row] valueForKey:@"bookName"]];
    [cell.bookCoverImage setImage:[UIImage imageNamed:[(NSDictionary *)[_bookInfoArray objectAtIndex:indexPath.row] valueForKey:@"coverImageFileName"]]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

@end
