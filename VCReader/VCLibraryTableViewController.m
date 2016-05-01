//
//  VCLibraryTableViewController.m
//  VCReader
//
//  Created by victor on 2/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCLibraryTableViewController.h"
#import "VCPageViewController.h"
#import "AppDelegate.h"

@interface VCLibraryTableViewController ()

@end

@implementation VCLibraryTableViewController {
    
    NSArray *_bookInfoArray;
    UIView *_activityView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //set status bar style
    [self setNeedsStatusBarAppearanceUpdate];
    
    //set navigation bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:21.0]}];
    self.navigationController.navigationBar.topItem.title = @"书架";

    //hide tab bar
    self.tabBarController.tabBar.hidden = NO;
    

    _bookInfoArray = [NSArray arrayWithObjects:/*@{@"bookName":@"都市巨灵神",@"coverImageFileName":@"book3_cover"},*/@{@"bookName":@"斗破苍穹",@"coverImageFileName":@"book4_cover"},/*@{@"bookName":@"官神",@"coverImageFileName":@"book5_cover"},@{@"bookName":@"寻宝美利坚",@"coverImageFileName":@"book6_cover"},@{@"bookName":@"乐尊",@"coverImageFileName":@"book7_cover"},*/@{@"bookName":@"斗罗大陆",@"coverImageFileName":@"book8_cover"}, @{@"bookName":@"大主宰",@"coverImageFileName":@"book9_cover"}/*,@{@"bookName":@"修真归来在都市",@"coverImageFileName":@"book10_cover"},@{@"bookName":@"重生完美时代",@"coverImageFileName":@"book11_cover"}*/, nil];

    NSString *nameOfLastReadBook = [VCTool getObjectWithKey:@"name of the last read book"];
    
    if (nameOfLastReadBook) {
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VCPageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VCPageViewController"];
        VCBook *book = [[VCBook alloc] initWithBookName:nameOfLastReadBook];
        vc.book = book;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

}

-(UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBookContent"])
    {

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        
        [NSThread detachNewThreadSelector:@selector(showActivityView) toTarget:self withObject:nil];
        VCBook *book = [[VCBook alloc] initWithBookName:[(NSDictionary *)[_bookInfoArray objectAtIndex:indexPath.row] valueForKey:@"bookName"]];
        [self hideActivityView];

        VCPageViewController *viewController = segue.destinationViewController;
        viewController.book = book;
    }
}

#pragma mark - activity indicator view

-(void)showActivityView
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = delegate.window;
    _activityView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height)];
    _activityView.backgroundColor = [UIColor blackColor];
    _activityView.alpha = 0.5;
    
    UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(window.bounds.size.width / 2 - 12, window.bounds.size.height / 2 - 12, 24, 24)];
    activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleBottomMargin);
    [_activityView addSubview:activityWheel];
    [window addSubview: _activityView];
    
    [[[_activityView subviews] objectAtIndex:0] startAnimating];
}

-(void)hideActivityView
{
    [[[_activityView subviews] objectAtIndex:0] stopAnimating];
    [_activityView removeFromSuperview];
    _activityView = nil;
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
//    NSLog(@"row:%ld name:%@", (long)indexPath.row, bookNameString);
    [cell.bookNameLabel setText:bookNameString];
    [cell.bookCoverImage setImage:[UIImage imageNamed:[(NSDictionary *)[_bookInfoArray objectAtIndex:indexPath.row] valueForKey:@"coverImageFileName"]]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90.0;
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

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - file manager
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
