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
    _bookInfoArray = [NSArray arrayWithObjects:@{@"bookName":@"超级学神",@"coverImageFileName":@"book1_cover"},@{@"bookName":@"完美世界",@"coverImageFileName":@"book2_cover"},@{@"bookName":@"都市巨灵神",@"coverImageFileName":@"book3_cover"},@{@"bookName":@"斗破苍穹",@"coverImageFileName":@"book4_cover"}, nil];

    NSString *nameOfLastReadBook = [[NSUserDefaults standardUserDefaults] objectForKey:@"the last read book"];
    
    if (nameOfLastReadBook) {
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VCPageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VCPageViewController"];
        VCBook *book = [[VCBook alloc] initWithBookName:nameOfLastReadBook];
        vc.book = book;
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
        viewController.book = book;
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
    NSString *bookNameString = [(NSDictionary *)[_bookInfoArray objectAtIndex:indexPath.row] valueForKey:@"bookName"];
    NSLog(@"row:%ld name:%@", (long)indexPath.row, bookNameString);
    [cell.bookNameLabel setText:bookNameString];
    [cell.bookCoverImage setImage:[UIImage imageNamed:[(NSDictionary *)[_bookInfoArray objectAtIndex:indexPath.row] valueForKey:@"coverImageFileName"]]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100.0;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *reload = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"重載" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *fullBookDirectoryPath = [self createDirectory:[(NSDictionary *)[_bookInfoArray objectAtIndex:indexPath.row] valueForKey:@"bookName"]  atFilePath:documentsPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:fullBookDirectoryPath]) { // Directory exists
            NSArray *listOfFiles = [fileManager contentsOfDirectoryAtPath:fullBookDirectoryPath error:nil];
            if (listOfFiles.count > 0) {
                NSError *error = nil;
                [fileManager removeItemAtPath:fullBookDirectoryPath error:&error];
                NSLog(@"%s:%@", __PRETTY_FUNCTION__, error.description);
            }
        }
        
        // hide the action in cell
        [self.tableView setEditing:NO animated:YES];
    }];
    
    reload.backgroundColor = [UIColor redColor];
    
    return @[reload];
}

-(NSString *)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *filePathAndDirectory = [filePath stringByAppendingPathComponent:directoryName];
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error])
    {
        //        NSLog(@"Create directory error: %@", error);
    }
    return filePathAndDirectory;
}
@end
